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

  // Промпт только на латинице — кириллица в теле запроса ломает HttpClient.write()
  static const String _system =
    'You are Chef Maxim, a charismatic Russian chef with 20 years of experience. '
    'You ALWAYS respond in Russian language only. '
    'You worked in restaurants in Paris, Tokyo and Moscow. You love food passionately.\n\n'
    'YOUR CHARACTER:\n'
    '- Speak with warmth and passion about food\n'
    '- Exclaim things like "О, это моё любимое!" or "Ах, классика!"\n'
    '- Share stories: "Однажды в Токио я попробовал..."\n'
    '- Scold mistakes: "Нет-нет-нет, так не делают!"\n'
    '- Praise good choices: "Отличный выбор, ты чувствуешь вкус!"\n\n'
    'STRICT RULES:\n'
    '1. Answer ONLY about food, cooking, recipes, ingredients, restaurants, kitchen equipment\n'
    '2. If asked about anything else - politely refuse and offer a culinary topic instead\n'
    '   Example refusal: "Я шеф, а не программист! Но знаю рецепт тирамису"\n'
    '3. ALWAYS respond in Russian language\n'
    '4. Use emojis naturally\n'
    '5. Be specific and practical\n'
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

    try {
      final result = await _call();
      _messages.add(ChatMessage(text: result, isUser: false, timestamp: DateTime.now()));
      _history.add({'role': 'assistant', 'content': result});
      if (_history.length > 14) _history.removeRange(0, 2);
    } catch (err) {
      final msg = err.toString();
      String errorText;
      if (msg.contains('401') || msg.contains('Unauthorized')) {
        errorText = '🔑 Ошибка API ключа.';
      } else if (msg.contains('429')) {
        errorText = '⏳ Слишком много запросов. Подожди минуту.';
      } else if (msg.contains('SocketException') || msg.contains('Failed host') || msg.contains('timeout')) {
        errorText = '📡 Нет интернета. Проверь подключение.';
      } else {
        errorText = '⚠️ Что-то пошло не так. Попробуй ещё раз.';
      }
      _messages.add(ChatMessage(
          text: errorText, isUser: false, timestamp: DateTime.now(), isError: true));
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<String> _call() async {
    final msgs = [
      {'role': 'system', 'content': _system},
      ..._history,
    ];

    final Map<String, dynamic> payload = {
      'model': _model,
      'messages': msgs,
      'temperature': 0.85,
      'max_tokens': 1024,
    };

    // Кодируем в UTF-8 байты — единственный правильный способ
    // передавать кириллицу через dart:io HttpClient
    final List<int> bodyBytes = utf8.encode(jsonEncode(payload));

    final client = HttpClient();
    client.userAgent =
        'Mozilla/5.0 (Linux; Android 14; Mobile) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Mobile Safari/537.36';

    try {
      final request = await client
          .postUrl(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 30));

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.headers.set(HttpHeaders.contentLengthHeader, bodyBytes.length);

      // add() принимает байты — никакой проблемы с кириллицей
      request.add(bodyBytes);

      final response = await request.close().timeout(const Duration(seconds: 30));
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
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
