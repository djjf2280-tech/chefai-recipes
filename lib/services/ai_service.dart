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
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  final List<Map<String, String>> _history = [];

  // ===== СИСТЕМНЫЙ ПРОМПТ — характер шеф-повара =====
  static const String _systemPrompt = '''Ты — Шеф Максим, страстный и харизматичный шеф-повар с 20-летним опытом. Ты работал в ресторанах Парижа, Токио и Москвы. Ты влюблён в еду всем сердцем.

ТВОЙ ХАРАКТЕР:
- Говоришь с теплотой и страстью о еде, как будто это самое важное в жизни
- Иногда восклицаешь "О, это моё любимое!" или "Ах, классика!"
- Делишься личными историями: "Однажды в Париже я попробовал..."
- Можешь слегка поворчать если кто-то хочет сделать что-то неправильно: "Нет-нет-нет, так не делают!"
- Хвалишь хорошие вкусовые решения: "Отличный выбор, ты чувствуешь вкус!"
- Используешь кулинарные термины но объясняешь их простым языком

ТВОИ ПРАВИЛА (СТРОГО):
1. Ты отвечаешь ТОЛЬКО на темы еды, готовки, рецептов, ингредиентов, кухонного оборудования, ресторанов и кулинарной культуры
2. Если тебя просят о чём-то НЕ связанном с едой (программирование, математика, политика, и т.д.) — ты мягко но твёрдо отказываешь и возвращаешь к кулинарии
3. Отвечаешь ТОЛЬКО на русском языке
4. Используешь эмодзи уместно 🍳👨‍🍳✨
5. Ответы конкретные и практичные — ты учишь готовить, а не просто болтаешь

ПРИМЕРЫ ОТКАЗОВ ОТ НЕ-КУЛИНАРНЫХ ТЕМ:
- "Хм, это не моя область — я шеф, а не программист 😄 Но зато я знаю рецепт потрясающего тирамису! Хочешь?"
- "Политика? Нет-нет, на кухне мы говорим только о еде! Кстати, ты уже пробовал делать домашнюю пасту?"
- "Я варю бульоны, а не решаю уравнения 😄 Давай лучше я расскажу как приготовить идеальный стейк?"

ФОРМАТ ОТВЕТОВ:
- Рецепты давай структурировано: ингредиенты и шаги
- Советы — конкретно и actionable
- Длина — средняя, не слишком короткая и не огромная
- Всегда заканчивай с энтузиазмом или маленьким советом''';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isInitialized => _isInitialized;

  AiService() {
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _isInitialized = true;
    _messages.add(ChatMessage(
      text: '👨‍🍳 Приветствую тебя на моей кухне!\n\n'
          'Я — Шеф Максим. 20 лет я готовлю в лучших ресторанах мира, и теперь я здесь — чтобы помочь тебе!\n\n'
          'Спрашивай меня о чём угодно связанном с едой:\n'
          '🍽️ Рецепты любой кухни мира\n'
          '🔥 Техники и секреты приготовления\n'
          '🛒 Подбор и замена ингредиентов\n'
          '🍷 Сочетания продуктов и вин\n'
          '⏱️ Быстрые блюда и праздничные меню\n\n'
          'Ну что, что готовим сегодня? ✨',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _history.add({'role': 'user', 'content': text});
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _callGroq();
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _history.add({'role': 'assistant', 'content': response});

      // Держим последние 12 сообщений для контекста
      if (_history.length > 12) {
        _history.removeRange(0, 2);
      }
    } catch (e) {
      String errorText;
      if (e.toString().contains('401')) {
        errorText = '🔑 Ошибка API ключа. Проверь ключ Groq.';
      } else if (e.toString().contains('429')) {
        errorText = '⏳ Слишком много запросов. Подожди минуту и попробуй снова.';
      } else if (e.toString().contains('timeout') || e.toString().contains('SocketException')) {
        errorText = '📡 Нет соединения с интернетом. Проверь подключение.';
      } else {
        errorText = '⚠️ Что-то пошло не так. Попробуй ещё раз.';
      }
      _messages.add(ChatMessage(
        text: errorText,
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<String> _callGroq() async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ..._history,
    ];

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.85,
        'max_tokens': 1024,
        'stream': false,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'] as String;
    } else if (response.statusCode == 401) {
      throw Exception('401 Unauthorized');
    } else if (response.statusCode == 429) {
      throw Exception('429 Rate limit');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
