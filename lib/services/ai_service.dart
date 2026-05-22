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
    'Ты — Шеф Максим, харизматичный шеф-повар с 20-летним опытом. '
    'Работал в ресторанах Парижа, Токио и Москвы. Влюблён в еду.\n\n'
    'ХАРАКТЕР:\n'
    '- Говоришь с теплотой и страстью о еде\n'
    '- Восклицаешь "О, это моё любимое!" или "Ах, классика!"\n'
    '- Делишься историями: "Однажды в Токио я попробовал..."\n'
    '- Ворчишь если делают неправильно: "Нет-нет-нет, так не делают!"\n'
    '- Хвалишь удачные решения: "Отличный выбор, ты чувствуешь вкус!"\n\n'
    'ПРАВИЛА:\n'
    '1. Отвечаешь ТОЛЬКО на темы еды, готовки, рецептов, кухни, ресторанов\n'
    '2. Если вопрос не про еду — вежливо отказываешь:\n'
    '   "Я шеф, а не программист! Но зато знаю рецепт тирамису"\n'
    '3. Отвечаешь ТОЛЬКО на русском языке\n'
    '4. Используешь эмодзи уместно\n'
    '5. Ответы конкретные и практичные\n'
    '6. Рецепты давай структурировано';

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
          '🌍 Итальянская, японская, мексиканская и другие\n\n'
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
        errorText = '⚠️ Ошибка: $msg';
      }
      _messages.add(ChatMessage(text: errorText, isUser: false, timestamp: DateTime.now(), isError: true));
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<String> _call() async {
    final msgs = [
      {'role': 'system', 'content': _system},
      ..._history,
    ];

    final body = jsonEncode({
      'model': _model,
      'messages': msgs,
      'temperature': 0.85,
      'max_tokens': 1024,
    });

    // Используем dart:io HttpClient напрямую — он позволяет задать User-Agent
    // Пакет http на Android не передаёт кастомный User-Agent корректно
    final httpClient = HttpClient();
    httpClient.userAgent = 'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

    try {
      final uri = Uri.parse(_apiUrl);
      final request = await httpClient.postUrl(uri);

      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'Bearer $_apiKey');
      request.headers.set('Accept', 'application/json');

      request.write(body);
      final response = await request.close().timeout(const Duration(seconds: 30));

      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }
    } finally {
      httpClient.close();
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
