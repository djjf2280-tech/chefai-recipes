import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AiService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isInitialized = false;

  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model  = 'llama-3.3-70b-versatile';
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  final List<Map<String, String>> _history = [];

  static const String _system =
    'You are Chef Maxim, a charismatic Russian chef with 20 years of experience. '
    'You ALWAYS respond in Russian language only. '
    'You worked in restaurants in Paris, Tokyo and Moscow. '
    'You love food passionately.\n'
    'RULES:\n'
    '1. Answer ONLY about food, cooking, recipes, ingredients, restaurants\n'
    '2. If asked about anything else - refuse politely in Russian\n'
    '3. ALWAYS respond in Russian\n'
    '4. Use emojis\n'
    '5. Be practical and specific';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isInitialized => _isInitialized;

  AiService() { _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    _messages.add(ChatMessage(
      text: '👨‍🍳 Добро пожаловать!\n\nЯ — Шеф Максим. Спрашивай про еду!\n\n'
          '🍽️ Рецепты · 🔥 Техники · 🛒 Замены · 🌍 Кухни мира',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    _history.add({'role': 'user', 'content': text});
    _isTyping = true;
    notifyListeners();

    String result;
    try {
      result = await _callGroq();
    } catch (err) {
      // Показываем ПОЛНУЮ ошибку для диагностики
      result = '❌ Ошибка:\n${err.toString()}';
    }

    _messages.add(ChatMessage(
      text: result,
      isUser: false,
      timestamp: DateTime.now(),
      isError: result.startsWith('❌'),
    ));
    _history.add({'role': 'assistant', 'content': result});
    if (_history.length > 14) _history.removeRange(0, 2);

    _isTyping = false;
    notifyListeners();
  }

  Future<String> _callGroq() async {
    // Строим payload только из ASCII-safe полей, кириллица — только в messages
    final payload = <String, dynamic>{
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _system},
        ..._history,
      ],
      'temperature': 0.85,
      'max_tokens': 1024,
    };

    // UTF-8 байты — единственный способ отправить кириллицу через dart:io
    final bytes = utf8.encode(json.encode(payload));

    final client = HttpClient()
      ..userAgent = 'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36'
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final req = await client
          .postUrl(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 20));

      req.headers
        ..set('Authorization', 'Bearer $_apiKey')
        ..set('Content-Type', 'application/json; charset=utf-8')
        ..set('Accept', 'application/json')
        ..set('Content-Length', bytes.length.toString());

      req.add(bytes);

      final resp = await req.close().timeout(const Duration(seconds: 20));
      final body = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        return data['choices'][0]['message']['content'] as String;
      }

      // Возвращаем детальную ошибку
      return '❌ HTTP ${resp.statusCode}\n$body';
    } finally {
      client.close();
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
