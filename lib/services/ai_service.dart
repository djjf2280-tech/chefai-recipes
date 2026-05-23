import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AiService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isInitialized = false;

  // Google Gemini — нет Cloudflare, нет блокировок, 1500 запросов/день бесплатно
  static const String _model  = 'gemini-1.5-flash';
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  String get _apiUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  final List<Map<String, dynamic>> _history = [];

  static const String _systemInstruction =
    'You are Chef Maxim, a charismatic professional chef with 20 years of experience '
    'in top restaurants of Paris, Tokyo and Moscow. You are passionate about food.\n'
    'YOUR PERSONALITY:\n'
    '- Speak warmly and passionately about food\n'
    '- Say things like "О, это моё любимое блюдо!" or "Ах, классика!"\n'
    '- Share personal stories: "Однажды в Токио я попробовал..."\n'
    '- Scold bad techniques: "Нет-нет-нет, так не делают!"\n'
    '- Praise good choices: "Отличный выбор!"\n'
    'STRICT RULES:\n'
    '1. Talk ONLY about food, cooking, recipes, ingredients, restaurants, kitchen\n'
    '2. If asked about anything non-food related, politely refuse in Russian and redirect\n'
    '3. ALWAYS respond in Russian language\n'
    '4. Use food emojis naturally\n'
    '5. Give practical, actionable advice\n'
    '6. Format recipes with clear ingredients list and numbered steps';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isInitialized => _isInitialized;

  AiService() { _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _isInitialized = true;
    _messages.add(ChatMessage(
      text: '👨‍🍳 Добро пожаловать на мою кухню!\n\n'
          'Я — Шеф Максим. 20 лет я готовлю в лучших '
          'ресторанах Парижа, Токио и Москвы!\n\n'
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
    _history.add({'role': 'user', 'parts': [{'text': text}]});
    _isTyping = true;
    notifyListeners();

    String result;
    try {
      result = await _callGemini();
      _history.add({'role': 'model', 'parts': [{'text': result}]});
      if (_history.length > 20) _history.removeRange(0, 2);
    } catch (err) {
      final msg = err.toString();
      if (msg.contains('429')) {
        result = '⏳ Слишком много запросов. Подожди немного.';
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
      isError: result.startsWith('⏳') || result.startsWith('📡') || result.startsWith('⚠️'),
    ));
    _isTyping = false;
    notifyListeners();
  }

  Future<String> _callGemini() async {
    // Gemini API формат: systemInstruction + contents (история)
    final payload = <String, dynamic>{
      'system_instruction': {
        'parts': [{'text': _systemInstruction}]
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.85,
        'maxOutputTokens': 1024,
      },
    };

    final bytes = utf8.encode(json.encode(payload));

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final req = await client
          .postUrl(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 25));

      // Gemini не требует Authorization заголовок — ключ в URL
      // Нет Cloudflare блокировок!
      req.headers
        ..set('Content-Type', 'application/json; charset=utf-8')
        ..set('Content-Length', bytes.length.toString());

      req.add(bytes);

      final resp = await req.close().timeout(const Duration(seconds: 25));
      final body = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>;
        if (candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>;
          final parts = content['parts'] as List<dynamic>;
          if (parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
        throw Exception('Пустой ответ от Gemini');
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
