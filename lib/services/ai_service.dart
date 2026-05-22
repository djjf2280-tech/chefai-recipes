import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isInitialized = false;

  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama3-70b-8192';
  // Ключ подставляется при сборке через --dart-define
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  final List<Map<String, String>> _history = [];

  static const String _systemPrompt =
    'Ты — Шеф Максим, харизматичный шеф-повар с 20-летним опытом. '
    'Работал в ресторанах Парижа, Токио и Москвы. Влюблён в еду.\n\n'
    'ХАРАКТЕР:\n'
    '- Говоришь с теплотой и страстью о еде\n'
    '- Восклицаешь "О, это моё любимое!" или "Ах, классика!"\n'
    '- Делишься историями: "Однажды в Париже я попробовал..."\n'
    '- Ворчишь если делают неправильно: "Нет-нет-нет, так не делают!\"\n'
    '- Хвалишь хорошие решения: "Отличный выбор, ты чувствуешь вкус!"\n\n'
    'СТРОГИЕ ПРАВИЛА:\n'
    '1. Отвечаешь ТОЛЬКО на темы еды, готовки, рецептов, ингредиентов, кухонного оборудования, ресторанов\n'
    '2. Если просят о чём-то НЕ связанном с едой — мягко отказывай и возвращай к кулинарии. '
    'Примеры: "Я шеф, а не программист 😄 Но зато знаю рецепт тирамису!" '
    'или "На кухне говорим только о еде! Кстати, пробовал домашнюю пасту?"\n'
    '3. Отвечаешь ТОЛЬКО на русском языке\n'
    '4. Используешь эмодзи уместно 🍳👨‍🍳✨\n'
    '5. Ответы конкретные — ты учишь готовить\n'
    '6. Рецепты давай структурировано с ингредиентами и шагами\n'
    '7. Заканчивай ответы с энтузиазмом или советом';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isInitialized => _isInitialized;

  AiService() { _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _isInitialized = true;
    _messages.add(ChatMessage(
      text: '👨‍🍳 Приветствую тебя на моей кухне!\n\n'
          'Я — Шеф Максим. 20 лет я готовлю в лучших ресторанах мира, и теперь я здесь — только для тебя!\n\n'
          '🍽️ Рецепты любой кухни мира\n'
          '🔥 Секреты и техники приготовления\n'
          '🛒 Подбор и замена ингредиентов\n'
          '🍷 Сочетания продуктов\n'
          '⏱️ Быстрые блюда и праздничные меню\n\n'
          'Ну что, что готовим сегодня? ✨',
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
      final response = await _callGroq();
      _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
      _history.add({'role': 'assistant', 'content': response});
      if (_history.length > 12) _history.removeRange(0, 2);
    } catch (e) {
      String errorText;
      final es = e.toString();
      if (es.contains('401')) {
        errorText = '🔑 Ошибка API ключа. Обратись к разработчику.';
      } else if (es.contains('429')) {
        errorText = '⏳ Слишком много запросов. Подожди минуту и попробуй снова.';
      } else if (es.contains('timeout') || es.contains('SocketException') || es.contains('Failed host')) {
        errorText = '📡 Нет соединения с интернетом. Проверь подключение.';
      } else {
        errorText = '⚠️ Что-то пошло не так. Попробуй ещё раз.';
      }
      _messages.add(ChatMessage(text: errorText, isUser: false, timestamp: DateTime.now(), isError: true));
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<String> _callGroq() async {
    final msgs = [{'role': 'system', 'content': _systemPrompt}, ..._history];
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'},
      body: jsonEncode({'model': _model, 'messages': msgs, 'temperature': 0.85, 'max_tokens': 1024}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'] as String;
    } else if (response.statusCode == 401) {
      throw Exception('401');
    } else if (response.statusCode == 429) {
      throw Exception('429');
    } else {
      throw Exception('HTTP ${response.statusCode}');
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  ChatMessage({required this.text, required this.isUser, required this.timestamp, this.isError = false});
}