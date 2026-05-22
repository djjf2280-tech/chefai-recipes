import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipesData extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'Все';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setCategory(String c) { _selectedCategory = c; notifyListeners(); }

  static const List<Map<String, dynamic>> categoryList = [
    {'name': 'Все',      'icon': '🍽️', 'color': Color(0xFFFF6B35)},
    {'name': 'Завтрак',  'icon': '🥞', 'color': Color(0xFFFFB347)},
    {'name': 'Обед',     'icon': '🍝', 'color': Color(0xFFFF6B35)},
    {'name': 'Ужин',     'icon': '🥩', 'color': Color(0xFF5C6BC0)},
    {'name': 'Суп',      'icon': '🍲', 'color': Color(0xFFE53935)},
    {'name': 'Десерты',  'icon': '🍰', 'color': Color(0xFFEC407A)},
    {'name': 'Напитки',  'icon': '🥤', 'color': Color(0xFF26A69A)},
    {'name': 'Закуски',  'icon': '🥗', 'color': Color(0xFF66BB6A)},
  ];

  List<String> get categories => categoryList.map((c) => c['name'] as String).toList();

  List<Recipe> get allRecipes => _recipes;

  List<Recipe> get filteredRecipes {
    var list = _recipes;
    if (_selectedCategory != 'Все') {
      list = list.where((r) => r.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) =>
        r.title.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q) ||
        r.tags.any((t) => t.toLowerCase().contains(q)) ||
        r.ingredients.any((i) => i.name.toLowerCase().contains(q))
      ).toList();
    }
    return list;
  }

  static const List<Recipe> _recipes = [
    Recipe(
      id: '1',
      title: 'Американские панкейки',
      description: 'Воздушные блинчики на кефире с кленовым сиропом',
      category: 'Завтрак',
      imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600&q=80',
      cookTime: 15, prepTime: 10, calories: 320,
      difficulty: 'Легко', servings: 4,
      categoryColor: Color(0xFFFFB347),
      categoryIcon: '🥞',
      tags: ['панкейки', 'завтрак', 'сладкое'],
      ingredients: [
        Ingredient(name: 'Мука', amount: '200', unit: 'г', emoji: '🌾'),
        Ingredient(name: 'Кефир', amount: '250', unit: 'мл', emoji: '🥛'),
        Ingredient(name: 'Яйца', amount: '2', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Сахар', amount: '2', unit: 'ст.л.', emoji: '🍬'),
        Ingredient(name: 'Разрыхлитель', amount: '1', unit: 'ч.л.', emoji: '✨'),
        Ingredient(name: 'Масло сливочное', amount: '30', unit: 'г', emoji: '🧈'),
      ],
      steps: [
        'Смешай муку, сахар, соль и разрыхлитель в большой миске.',
        'Взбей яйца с кефиром и растопленным маслом.',
        'Соедини сухие и жидкие ингредиенты — не перемешивай слишком активно!',
        'Дай тесту постоять 5 минут.',
        'Жарь на разогретой сковороде по 2 мин с каждой стороны.',
        'Подавай с кленовым сиропом и ягодами.',
      ],
      tips: '💡 Секрет пышности: комочки в тесте — это нормально! Они исчезнут при жарке.',
    ),

    Recipe(
      id: '2',
      title: 'Авокадо-тост с пашот',
      description: 'Трендовый завтрак: кремовый авокадо и нежное яйцо',
      category: 'Завтрак',
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80',
      cookTime: 10, prepTime: 5, calories: 280,
      difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFF66BB6A),
      categoryIcon: '🥑',
      tags: ['авокадо', 'яйцо', 'тост', 'ПП'],
      ingredients: [
        Ingredient(name: 'Хлеб зерновой', amount: '2', unit: 'ломтика', emoji: '🍞'),
        Ingredient(name: 'Авокадо', amount: '1', unit: 'шт', emoji: '🥑'),
        Ingredient(name: 'Яйца', amount: '2', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Лимонный сок', amount: '1', unit: 'ч.л.', emoji: '🍋'),
        Ingredient(name: 'Чили хлопья', amount: 'по вкусу', unit: '', emoji: '🌶️'),
        Ingredient(name: 'Уксус 9%', amount: '1', unit: 'ст.л.', emoji: '🫙'),
      ],
      steps: [
        'Поджарь хлеб до золотистой корочки.',
        'Разомни авокадо вилкой, добавь лимонный сок и соль.',
        'Вскипяти воду с уксусом, создай воронку ложкой.',
        'Опусти яйцо в воронку, вари 3 минуты.',
        'Намажь авокадо на тост, положи яйцо сверху.',
        'Посыпь хлопьями чили и морской солью.',
      ],
      tips: '💡 Яйцо должно быть холодным и свежим — так белок лучше держит форму.',
    ),

    Recipe(
      id: '3',
      title: 'Паста Карбонара',
      description: 'Классическая римская паста с кремовым соусом',
      category: 'Обед',
      imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=600&q=80',
      cookTime: 20, prepTime: 10, calories: 680,
      difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFFFF6B35),
      categoryIcon: '🍝',
      tags: ['паста', 'итальянская', 'карбонара'],
      ingredients: [
        Ingredient(name: 'Спагетти', amount: '200', unit: 'г', emoji: '🍝'),
        Ingredient(name: 'Панчетта', amount: '150', unit: 'г', emoji: '🥓'),
        Ingredient(name: 'Яйца', amount: '3', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Пармезан', amount: '80', unit: 'г', emoji: '🧀'),
        Ingredient(name: 'Чёрный перец', amount: '1', unit: 'ч.л.', emoji: '🫙'),
        Ingredient(name: 'Чеснок', amount: '2', unit: 'зубчика', emoji: '🧄'),
      ],
      steps: [
        'Вари спагетти аль денте. Сохрани стакан воды от пасты.',
        'Взбей яйца с пармезаном и чёрным перцем.',
        'Обжарь панчетту с чесноком до хруста.',
        'Слей пасту, добавь к панчетте. Выключи огонь!',
        'Влей яично-сырную смесь, быстро перемешай.',
        'Подливай воду от пасты до кремовости.',
      ],
      tips: '⚠️ Никогда не добавляй яйца при включённом огне — получится яичница!',
    ),

    Recipe(
      id: '4',
      title: 'Цезарь с курицей',
      description: 'Классический салат с хрустящими крутонами',
      category: 'Обед',
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=600&q=80',
      cookTime: 20, prepTime: 15, calories: 450,
      difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFF66BB6A),
      categoryIcon: '🥗',
      tags: ['цезарь', 'салат', 'курица'],
      ingredients: [
        Ingredient(name: 'Куриная грудка', amount: '300', unit: 'г', emoji: '🍗'),
        Ingredient(name: 'Салат ромэн', amount: '1', unit: 'кочан', emoji: '🥬'),
        Ingredient(name: 'Пармезан', amount: '50', unit: 'г', emoji: '🧀'),
        Ingredient(name: 'Хлеб белый', amount: '2', unit: 'ломтика', emoji: '🍞'),
        Ingredient(name: 'Майонез', amount: '3', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Лимонный сок', amount: '2', unit: 'ст.л.', emoji: '🍋'),
      ],
      steps: [
        'Нарежь хлеб кубиками, запекай 180°С 10 мин.',
        'Натри курицу специями, обжарь 7 мин с каждой стороны.',
        'Смешай майонез, лимон, чеснок и горчицу — заправка.',
        'Порви ромэн, смешай с заправкой.',
        'Добавь нарезанную курицу, крутоны и пармезан.',
      ],
      tips: '💡 Для ресторанного вкуса: добавь 1 анчоус в заправку.',
    ),

    Recipe(
      id: '5',
      title: 'Борщ классический',
      description: 'Наваристый борщ на говяжьем бульоне',
      category: 'Суп',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      cookTime: 120, prepTime: 20, calories: 280,
      difficulty: 'Средне', servings: 6,
      categoryColor: Color(0xFFE53935),
      categoryIcon: '🍲',
      tags: ['борщ', 'суп', 'говядина'],
      ingredients: [
        Ingredient(name: 'Говядина', amount: '600', unit: 'г', emoji: '🥩'),
        Ingredient(name: 'Свёкла', amount: '2', unit: 'шт', emoji: '🫚'),
        Ingredient(name: 'Капуста', amount: '300', unit: 'г', emoji: '🥬'),
        Ingredient(name: 'Картофель', amount: '3', unit: 'шт', emoji: '🥔'),
        Ingredient(name: 'Морковь', amount: '1', unit: 'шт', emoji: '🥕'),
        Ingredient(name: 'Томатная паста', amount: '2', unit: 'ст.л.', emoji: '🍅'),
        Ingredient(name: 'Уксус', amount: '1', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Сметана', amount: 'для подачи', unit: '', emoji: '🥛'),
      ],
      steps: [
        'Вари говядину 1.5 часа, снимай пену.',
        'Потуши свёклу с томатпастой и уксусом 10 минут.',
        'Обжарь лук и морковь до золотистого.',
        'Добавь картофель в бульон, вари 10 минут.',
        'Добавь капусту, вари ещё 7 минут.',
        'Добавь зажарку и свёклу, вари 5 минут.',
        'Настаивай 30 минут перед подачей.',
      ],
      tips: '💡 Уксус в свёкле — секрет яркого красного цвета!',
    ),

    Recipe(
      id: '6',
      title: 'Том Ям с креветками',
      description: 'Огненный тайский суп с кокосовым молоком',
      category: 'Суп',
      imageUrl: 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600&q=80',
      cookTime: 25, prepTime: 15, calories: 320,
      difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFFFF5722),
      categoryIcon: '🦐',
      tags: ['том ям', 'тайская', 'острое'],
      ingredients: [
        Ingredient(name: 'Креветки', amount: '300', unit: 'г', emoji: '🦐'),
        Ingredient(name: 'Кокосовое молоко', amount: '400', unit: 'мл', emoji: '🥥'),
        Ingredient(name: 'Бульон', amount: '500', unit: 'мл', emoji: '🫙'),
        Ingredient(name: 'Лемонграсс', amount: '2', unit: 'стебля', emoji: '🌿'),
        Ingredient(name: 'Чили', amount: '2', unit: 'шт', emoji: '🌶️'),
        Ingredient(name: 'Рыбный соус', amount: '2', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Лайм', amount: '2', unit: 'шт', emoji: '🍋'),
      ],
      steps: [
        'Разомни лемонграсс. Вскипяти бульон с лемонграссом и чили.',
        'Добавь кокосовое молоко, доведи до кипения.',
        'Добавь грибы, вари 5 минут.',
        'Добавь креветки, вари 3 минуты.',
        'Добавь рыбный соус и сок лайма.',
        'Подавай с кинзой.',
      ],
      tips: '💡 4 вкуса: острый, кислый, солёный, сладкий — регулируй баланс!',
    ),

    Recipe(
      id: '7',
      title: 'Лосось в медовом маринаде',
      description: 'Нежный лосось с карамельной корочкой за 20 минут',
      category: 'Ужин',
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600&q=80',
      cookTime: 15, prepTime: 10, calories: 420,
      difficulty: 'Легко', servings: 2,
      categoryColor: Color(0xFF5C6BC0),
      categoryIcon: '🐟',
      tags: ['лосось', 'рыба', 'ПП', 'быстро'],
      ingredients: [
        Ingredient(name: 'Лосось', amount: '400', unit: 'г', emoji: '🐟'),
        Ingredient(name: 'Мёд', amount: '2', unit: 'ст.л.', emoji: '🍯'),
        Ingredient(name: 'Соевый соус', amount: '3', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Чеснок', amount: '2', unit: 'зубчика', emoji: '🧄'),
        Ingredient(name: 'Имбирь', amount: '1', unit: 'ч.л.', emoji: '🫚'),
        Ingredient(name: 'Лимон', amount: '½', unit: 'шт', emoji: '🍋'),
        Ingredient(name: 'Кунжут', amount: '1', unit: 'ст.л.', emoji: '✨'),
      ],
      steps: [
        'Смешай мёд, соевый соус, чеснок и имбирь.',
        'Замаринуй лосось на 10 минут.',
        'Разогрей сковороду до дыма.',
        'Жарь лосось кожей вниз 4 минуты — не двигай!',
        'Переверни, жарь ещё 3 минуты.',
        'Полей маринадом, карамелизируй 1-2 минуты.',
      ],
      tips: '💡 Розовый центр лосося — это идеально, не пересушивай!',
    ),

    Recipe(
      id: '8',
      title: 'Тако с курицей',
      description: 'Мексиканские тако с пряной курицей и гуакамоле',
      category: 'Ужин',
      imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600&q=80',
      cookTime: 20, prepTime: 15, calories: 490,
      difficulty: 'Легко', servings: 4,
      categoryColor: Color(0xFFFFC107),
      categoryIcon: '🌮',
      tags: ['тако', 'мексиканская', 'курица'],
      ingredients: [
        Ingredient(name: 'Куриное филе', amount: '500', unit: 'г', emoji: '🍗'),
        Ingredient(name: 'Тортильи', amount: '8', unit: 'шт', emoji: '🫓'),
        Ingredient(name: 'Авокадо', amount: '2', unit: 'шт', emoji: '🥑'),
        Ingredient(name: 'Черри томаты', amount: '200', unit: 'г', emoji: '🍅'),
        Ingredient(name: 'Паприка', amount: '1', unit: 'ч.л.', emoji: '🫙'),
        Ingredient(name: 'Лайм', amount: '2', unit: 'шт', emoji: '🍋'),
        Ingredient(name: 'Сметана', amount: '4', unit: 'ст.л.', emoji: '🥛'),
      ],
      steps: [
        'Нарежь курицу, замаринуй в паприке и соке лайма.',
        'Разомни авокадо с соком лайма и солью — гуакамоле.',
        'Обжарь курицу на сильном огне до корочки.',
        'Прогрей тортильи на сухой сковороде.',
        'Собери тако: гуакамоле → курица → томаты.',
        'Полей сметаной и соком лайма.',
      ],
      tips: '💡 Сильный огонь и не трогать — секрет сочной курицы!',
    ),

    Recipe(
      id: '9',
      title: 'Шоколадный фондан',
      description: 'Горячий кекс с жидкой шоколадной начинкой',
      category: 'Десерты',
      imageUrl: 'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=600&q=80',
      cookTime: 12, prepTime: 15, calories: 450,
      difficulty: 'Средне', servings: 4,
      categoryColor: Color(0xFFEC407A),
      categoryIcon: '🍫',
      tags: ['шоколад', 'фондан', 'десерт'],
      ingredients: [
        Ingredient(name: 'Тёмный шоколад', amount: '150', unit: 'г', emoji: '🍫'),
        Ingredient(name: 'Масло сливочное', amount: '100', unit: 'г', emoji: '🧈'),
        Ingredient(name: 'Яйца', amount: '4', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Сахар', amount: '80', unit: 'г', emoji: '🍬'),
        Ingredient(name: 'Мука', amount: '40', unit: 'г', emoji: '🌾'),
        Ingredient(name: 'Мороженое', amount: 'для подачи', unit: '', emoji: '🍨'),
      ],
      steps: [
        'Разогрей духовку до 200°С. Смажь формочки.',
        'Растопи шоколад с маслом на водяной бане.',
        'Взбей яйца с сахаром добела.',
        'Соедини шоколад с яйцами, добавь муку.',
        'Разлей по формочкам, убери в холодильник на 10 мин.',
        'Выпекай 10-12 минут — центр должен дрожать!',
      ],
      tips: '⚡ Не перепеки! Жидкий центр — это цель.',
    ),

    Recipe(
      id: '10',
      title: 'Тирамису',
      description: 'Нежный итальянский десерт с маскарпоне',
      category: 'Десерты',
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600&q=80',
      cookTime: 0, prepTime: 30, calories: 380,
      difficulty: 'Средне', servings: 6,
      categoryColor: Color(0xFF8D6E63),
      categoryIcon: '☕',
      tags: ['тирамису', 'итальянская', 'без выпечки'],
      ingredients: [
        Ingredient(name: 'Маскарпоне', amount: '500', unit: 'г', emoji: '🧀'),
        Ingredient(name: 'Савоярди', amount: '300', unit: 'г', emoji: '🫓'),
        Ingredient(name: 'Яйца', amount: '4', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Сахар', amount: '100', unit: 'г', emoji: '🍬'),
        Ingredient(name: 'Эспрессо', amount: '300', unit: 'мл', emoji: '☕'),
        Ingredient(name: 'Какао', amount: '2', unit: 'ст.л.', emoji: '🫙'),
      ],
      steps: [
        'Взбей желтки с сахаром добела.',
        'Добавь маскарпоне, перемешай.',
        'Взбей белки в крепкую пену, аккуратно вмешай.',
        'Быстро обмакивай савоярди в кофе (0.5 сек).',
        'Выкладывай слоями: печенье → крем → печенье → крем.',
        'Посыпь какао, убери на ночь в холодильник.',
      ],
      tips: '💡 Десерт настоящий только после ночи в холодильнике!',
    ),

    Recipe(
      id: '11',
      title: 'Матча латте',
      description: 'Бархатный зелёный напиток с японским чаем',
      category: 'Напитки',
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=600&q=80',
      cookTime: 5, prepTime: 3, calories: 120,
      difficulty: 'Легко', servings: 1,
      categoryColor: Color(0xFF26A69A),
      categoryIcon: '🍵',
      tags: ['матча', 'латте', 'японский'],
      ingredients: [
        Ingredient(name: 'Порошок матча', amount: '2', unit: 'ч.л.', emoji: '🌿'),
        Ingredient(name: 'Горячая вода', amount: '60', unit: 'мл', emoji: '💧'),
        Ingredient(name: 'Молоко', amount: '200', unit: 'мл', emoji: '🥛'),
        Ingredient(name: 'Мёд', amount: '1', unit: 'ч.л.', emoji: '🍯'),
      ],
      steps: [
        'Просей матча через сито в чашку.',
        'Добавь воду 80°С (не кипяток!).',
        'Взбей венчиком в движении W до пены.',
        'Добавь мёд, размешай.',
        'Вспени горячее молоко (65°С).',
        'Медленно влей молоко в матча.',
      ],
      tips: '💡 80°С, не кипяток — иначе матча горчит!',
    ),

    Recipe(
      id: '12',
      title: 'Брускетта с томатами',
      description: 'Итальянская классика: хлеб, томаты, базилик',
      category: 'Закуски',
      imageUrl: 'https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?w=600&q=80',
      cookTime: 10, prepTime: 10, calories: 180,
      difficulty: 'Легко', servings: 4,
      categoryColor: Color(0xFF66BB6A),
      categoryIcon: '🥖',
      tags: ['брускетта', 'итальянская', 'томаты'],
      ingredients: [
        Ingredient(name: 'Багет', amount: '1', unit: 'шт', emoji: '🥖'),
        Ingredient(name: 'Помидоры', amount: '4', unit: 'шт', emoji: '🍅'),
        Ingredient(name: 'Базилик', amount: 'пучок', unit: '', emoji: '🌿'),
        Ingredient(name: 'Чеснок', amount: '2', unit: 'зубчика', emoji: '🧄'),
        Ingredient(name: 'Оливковое масло', amount: '3', unit: 'ст.л.', emoji: '🫒'),
        Ingredient(name: 'Бальзамик', amount: '1', unit: 'ст.л.', emoji: '🫙'),
      ],
      steps: [
        'Нарежь багет косо, полей маслом.',
        'Запекай 180°С 8 минут до хруста.',
        'Нарежь томаты, посоли, оставь на 5 минут.',
        'Слей сок, добавь базилик и масло.',
        'Натри хлеб чесноком.',
        'Выложи томаты, сбрызни бальзамиком.',
      ],
      tips: '💡 Слей сок с томатов — иначе хлеб размокнет!',
    ),
  ];
}
