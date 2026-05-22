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
    '4. Use emojis naturally\n'
    '5. Be practical and specific\n'
    '6. Format recipes with ingredients and steps';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isInitialized => _isInitialized;

  AiService() { _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    _messages.add(ChatMessage(
      text: '👨‍🍳 Добро пожаловать на мою кухню!\n\n'
          'Я — Шеф Максим. 20 лет готовлю в лучших ресторанах мира!\n\n'
          '🍽️ Рецепты любой кухни мира\n'
          '🔥 Секреты и техники приготовления\n'
          '🛒 Замена ингредиентов\n'
          '🌍 Итальянская, японская, мексиканская...\n\n'
          'Что готовим сегодня? ✨',
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
      final msg = err.toString();
      if (msg.contains('403')) {
        result = '📡 Нет соединения. Проверь интернет и попробуй ещё раз.';
      } else if (msg.contains('429')) {
        result = '⏳ Слишком много запросов. Подожди минуту.';
      } else if (msg.contains('SocketException') || msg.contains('timeout')) {
        result = '📡 Нет интернета. Проверь подключение.';
      } else {
        result = '⚠️ Что-то пошло не так. Попробуй ещё раз.';
      }
    }

    _messages.add(ChatMessage(
      text: result,
      isUser: false,
      timestamp: DateTime.now(),
      isError: result.startsWith('📡') || result.startsWith('⏳') || result.startsWith('⚠️'),
    ));
    _history.add({'role': 'assistant', 'content': result});
    if (_history.length > 14) _history.removeRange(0, 2);

    _isTyping = false;
    notifyListeners();
  }

  Future<String> _callGroq() async {
    final payload = <String, dynamic>{
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _system},
        ..._history,
      ],
      'temperature': 0.85,
      'max_tokens': 1024,
    };

    final bytes = utf8.encode(json.encode(payload));

    // КЛЮЧЕВОЙ ФИС: persistentConnection = false
    // Без этого HttpClient переиспользует TCP соединение и Cloudflare
    // теряет заголовки Auth на втором запросе → 403 Forbidden
    final client = HttpClient()
      ..userAgent = 'Mozilla/5.0 (Linux; Android 14; Mobile) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/124.0.0.0 Mobile Safari/537.36'
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 1);

    try {
      final req = await client
          .postUrl(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 20));

      // Отключаем keep-alive — каждый запрос новое соединение
      // Это гарантирует что все заголовки передаются каждый раз
      req.persistentConnection = false;

      req.headers
        ..set('Authorization', 'Bearer $_apiKey')
        ..set('Content-Type', 'application/json; charset=utf-8')
        ..set('Accept', 'application/json')
        ..set('Content-Length', bytes.length.toString())
        ..set('Connection', 'close');

      req.add(bytes);

      final resp = await req.close().timeout(const Duration(seconds: 20));
      final body = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        return data['choices'][0]['message']['content'] as String;
      }

      throw Exception('HTTP ${resp.statusCode}: $body');
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
