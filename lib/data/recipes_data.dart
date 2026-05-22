import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipesData extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'Все';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setCategory(String c) { _selectedCategory = c; notifyListeners(); }

  List<String> get categories => [
    'Все', '🍳 Завтрак', '🍱 Обед', '🌙 Ужин',
    '🥨 Закуски', '🥣 Суп', '🍰 Десерты', '🥤 Напитки',
    '🇮🇹 Итальянская', '🇯🇵 Японская', '🇲🇽 Мексиканская',
    '🇹🇭 Тайская', '🇮🇳 Индийская', '🇫🇷 Французская',
  ];

  List<Recipe> get allRecipes => _recipes;

  List<Recipe> get filteredRecipes {
    var list = _recipes;
    if (_selectedCategory != 'Все') {
      final cat = _selectedCategory.replaceAll(RegExp(r'[^\w\sа-яА-Я]'), '').trim();
      list = list.where((r) =>
        r.category.contains(cat) ||
        r.cuisine.contains(cat) ||
        _selectedCategory.contains(r.category) ||
        _selectedCategory.contains(r.cuisine)
      ).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) =>
        r.title.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q) ||
        r.cuisine.toLowerCase().contains(q) ||
        r.tags.any((t) => t.toLowerCase().contains(q)) ||
        r.ingredients.any((i) => i.name.toLowerCase().contains(q))
      ).toList();
    }
    return list;
  }

  static const List<Recipe> _recipes = [
    // ===== ЗАВТРАКИ =====
    Recipe(
      id: 'панкейки', title: 'Пышные американские панкейки',
      description: 'Воздушные блинчики на кефире с кленовым сиропом — идеальный завтрак.',
      category: 'Завтрак', cuisine: 'Американская', emoji: '🥞',
      cookTime: 15, prepTime: 10, calories: 320, difficulty: 'Легко', servings: 4,
      categoryColor: Color(0xFFFF6B35), cuisineColor: Color(0xFF3B82F6),
      tags: ['завтрак', 'сладкое', 'быстро'],
      ingredients: [
        Ingredient(name: 'Мука пшеничная', amount: '200', unit: 'г', emoji: '🌾'),
        Ingredient(name: 'Кефир', amount: '250', unit: 'мл', emoji: '🥛'),
        Ingredient(name: 'Яйца', amount: '2', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Сахар', amount: '2', unit: 'ст.л.', emoji: '🍬'),
        Ingredient(name: 'Разрыхлитель', amount: '1', unit: 'ч.л.', emoji: '✨'),
        Ingredient(name: 'Сливочное масло', amount: '30', unit: 'г', emoji: '🧈'),
      ],
      steps: [
        'Смешай муку, сахар, соль и разрыхлитель.',
        'Взбей яйца с кефиром и растопленным маслом.',
        'Соедини сухое и жидкое — пара комочков допустима.',
        'Дай тесту постоять 5 минут.',
        'Жарь на среднем огне по 2 минуты с каждой стороны.',
        'Подавай с кленовым сиропом и ягодами!',
      ],
      tips: '💡 Не перемешивай слишком активно — комочки исчезнут при жарке и панкейки будут пышнее.',
    ),

    Recipe(
      id: 'авокадо', title: 'Авокадо-тост с яйцом пашот',
      description: 'Кремовый авокадо, нежное яйцо, хрустящий хлеб — завтрак уровня кафе.',
      category: 'Завтрак', cuisine: 'Американская', emoji: '🥑',
      cookTime: 10, prepTime: 5, calories: 280, difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFF4CAF50), cuisineColor: Color(0xFF3B82F6),
      tags: ['завтрак', 'ПП', 'авокадо'],
      ingredients: [
        Ingredient(name: 'Хлеб зерновой', amount: '2', unit: 'ломтика', emoji: '🍞'),
        Ingredient(name: 'Авокадо', amount: '1', unit: 'шт', emoji: '🥑'),
        Ingredient(name: 'Яйца', amount: '2', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Лимонный сок', amount: '1', unit: 'ч.л.', emoji: '🍋'),
        Ingredient(name: 'Чили хлопья', amount: 'щепотка', unit: '', emoji: '🌶️'),
        Ingredient(name: 'Уксус', amount: '1', unit: 'ст.л.', emoji: '🫙'),
      ],
      steps: [
        'Поджарь хлеб до золотистой корочки.',
        'Разомни авокадо с лимоном и солью.',
        'Вскипяти воду с уксусом, создай воронку ложкой.',
        'Аккуратно опусти яйцо, вари 3 минуты.',
        'Намажь авокадо на тост, положи яйцо.',
        'Посыпь чили и морской солью.',
      ],
      tips: '💡 Яйцо должно быть свежим и холодным — так белок лучше держит форму.',
    ),

    Recipe(
      id: 'овсянка', title: 'Овсянка с карамельным бананом',
      description: 'Сытная каша с карамелизированными бананами и орехами.',
      category: 'Завтрак', cuisine: 'Европейская', emoji: '🫙',
      cookTime: 10, prepTime: 2, calories: 350, difficulty: 'Легко', servings: 2,
      categoryColor: Color(0xFFFFB347), cuisineColor: Color(0xFF8B5CF6),
      tags: ['завтрак', 'ПП', 'быстро', 'веган'],
      ingredients: [
        Ingredient(name: 'Овсяные хлопья', amount: '100', unit: 'г', emoji: '🌾'),
        Ingredient(name: 'Молоко', amount: '300', unit: 'мл', emoji: '🥛'),
        Ingredient(name: 'Банан', amount: '2', unit: 'шт', emoji: '🍌'),
        Ingredient(name: 'Коричневый сахар', amount: '2', unit: 'ст.л.', emoji: '🍯'),
        Ingredient(name: 'Корица', amount: '½', unit: 'ч.л.', emoji: '✨'),
        Ingredient(name: 'Орехи', amount: 'горсть', unit: '', emoji: '🥜'),
      ],
      steps: [
        'Доведи молоко до кипения, всыпь хлопья.',
        'Вари 5-7 минут, помешивая.',
        'Нарежь бананы, карамелизируй с сахаром и корицей 2 мин.',
        'Разложи кашу, выложи бананы, посыпь орехами.',
      ],
      tips: '💡 Хлопья долгой варки дают кремовую текстуру.',
    ),

    // ===== ОБЕДЫ =====
    Recipe(
      id: 'паста', title: 'Паста Карбонара',
      description: 'Классика Рима — нежный соус из яиц, пармезана и хрустящей панчетты.',
      category: 'Обед', cuisine: 'Итальянская', emoji: '🍝',
      cookTime: 20, prepTime: 10, calories: 680, difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFFFF6B35), cuisineColor: Color(0xFF10B981),
      tags: ['обед', 'итальянская', 'паста', 'классика'],
      ingredients: [
        Ingredient(name: 'Спагетти', amount: '200', unit: 'г', emoji: '🍝'),
        Ingredient(name: 'Панчетта или бекон', amount: '150', unit: 'г', emoji: '🥓'),
        Ingredient(name: 'Яйца', amount: '3', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Пармезан', amount: '80', unit: 'г', emoji: '🧀'),
        Ingredient(name: 'Чёрный перец', amount: '1', unit: 'ч.л.', emoji: '🫙'),
        Ingredient(name: 'Чеснок', amount: '2', unit: 'зубчика', emoji: '🧄'),
      ],
      steps: [
        'Вари спагетти аль денте. Сохрани стакан воды от пасты.',
        'Взбей яйца с пармезаном и перцем.',
        'Обжарь панчетту с чесноком до хруста.',
        'ВЫКЛЮЧИ огонь! Добавь пасту к панчетте.',
        'Влей яичный соус, быстро мешай добавляя воду от пасты.',
        'Подавай немедленно с пармезаном и перцем.',
      ],
      tips: '⚠️ Никогда не добавляй яйца при включённом огне — получится яичница! Жар пасты сам приготовит соус.',
    ),

    Recipe(
      id: 'цезарь', title: 'Куриный Цезарь',
      description: 'Король салатов: сочная курица, хрустящие крутоны, фирменная заправка.',
      category: 'Обед', cuisine: 'Американская', emoji: '🥗',
      cookTime: 20, prepTime: 15, calories: 450, difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFF4CAF50), cuisineColor: Color(0xFF3B82F6),
      tags: ['обед', 'салат', 'курица', 'ПП'],
      ingredients: [
        Ingredient(name: 'Куриная грудка', amount: '300', unit: 'г', emoji: '🍗'),
        Ingredient(name: 'Салат ромэн', amount: '1', unit: 'кочан', emoji: '🥬'),
        Ingredient(name: 'Пармезан', amount: '50', unit: 'г', emoji: '🧀'),
        Ingredient(name: 'Хлеб', amount: '2', unit: 'ломтика', emoji: '🍞'),
        Ingredient(name: 'Майонез', amount: '3', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Лимонный сок', amount: '2', unit: 'ст.л.', emoji: '🍋'),
        Ingredient(name: 'Горчица', amount: '1', unit: 'ч.л.', emoji: '🫙'),
      ],
      steps: [
        'Нарежь хлеб кубиками, запеки с маслом при 180°С 10 мин.',
        'Обжарь курицу с специями по 7 мин с каждой стороны.',
        'Смешай майонез, лимон, горчицу, чеснок — заправка готова.',
        'Порви ромэн, перемешай с заправкой.',
        'Нарежь курицу, добавь крутоны и пармезан.',
      ],
      tips: '💡 Анчоус в заправке — секрет ресторанного вкуса (без рыбного привкуса).',
    ),

    Recipe(
      id: 'стейк', title: 'Стейк Рибай медиум',
      description: 'Сочный стейк с хрустящей корочкой и маслом с розмарином.',
      category: 'Обед', cuisine: 'Американская', emoji: '🥩',
      cookTime: 15, prepTime: 5, calories: 580, difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFFE53935), cuisineColor: Color(0xFF3B82F6),
      tags: ['обед', 'мясо', 'стейк', 'гриль'],
      ingredients: [
        Ingredient(name: 'Стейк рибай', amount: '500', unit: 'г', emoji: '🥩'),
        Ingredient(name: 'Розмарин', amount: '2', unit: 'веточки', emoji: '🌿'),
        Ingredient(name: 'Чеснок', amount: '3', unit: 'зубчика', emoji: '🧄'),
        Ingredient(name: 'Сливочное масло', amount: '50', unit: 'г', emoji: '🧈'),
        Ingredient(name: 'Соль крупная', amount: 'по вкусу', unit: '', emoji: '🧂'),
        Ingredient(name: 'Чёрный перец', amount: 'по вкусу', unit: '', emoji: '🫙'),
      ],
      steps: [
        'Достань мясо за 30 мин до готовки — должно быть комнатной температуры.',
        'Обсуши бумажным полотенцем. Посоли обильно.',
        'Разогрей сковороду до дыма. Добавь масло.',
        'Жарь по 3-4 мин с каждой стороны не двигая.',
        'Добавь масло, чеснок, розмарин. Поливай стейк маслом 2 мин.',
        'Дай отдохнуть под фольгой 5 мин. Режь поперёк волокон.',
      ],
      tips: '🌡️ Медиум — 62°С внутри. Дай мясу отдохнуть — соки равномерно распределятся.',
    ),

    // ===== УЖИНЫ =====
    Recipe(
      id: 'лосось', title: 'Лосось в медово-соевом маринаде',
      description: 'Нежный лосось с карамельной корочкой — ужин уровня ресторана за 20 минут.',
      category: 'Ужин', cuisine: 'Азиатская', emoji: '🐟',
      cookTime: 15, prepTime: 10, calories: 420, difficulty: 'Легко', servings: 2,
      categoryColor: Color(0xFFFF7043), cuisineColor: Color(0xFFF59E0B),
      tags: ['ужин', 'рыба', 'ПП', 'быстро'],
      ingredients: [
        Ingredient(name: 'Филе лосося', amount: '400', unit: 'г', emoji: '🐟'),
        Ingredient(name: 'Мёд', amount: '2', unit: 'ст.л.', emoji: '🍯'),
        Ingredient(name: 'Соевый соус', amount: '3', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Чеснок', amount: '2', unit: 'зубчика', emoji: '🧄'),
        Ingredient(name: 'Имбирь', amount: '1', unit: 'ч.л.', emoji: '🫚'),
        Ingredient(name: 'Кунжут', amount: '1', unit: 'ст.л.', emoji: '✨'),
      ],
      steps: [
        'Смешай мёд, соевый соус, чеснок и имбирь.',
        'Залей лосось на 10 минут.',
        'Раскали сковороду, жарь кожей вниз 4 мин.',
        'Переверни, жарь ещё 3 мин.',
        'Полей маринадом, карамелизируй 1 мин.',
        'Посыпь кунжутом, подавай с лимоном.',
      ],
      tips: '💡 Розовый центр — это идеально! Не пересуши лосось.',
    ),

    Recipe(
      id: 'тако', title: 'Куриные тако',
      description: 'Мексиканские тако с пряной курицей, авокадо-сальсой и кинзой.',
      category: 'Ужин', cuisine: 'Мексиканская', emoji: '🌮',
      cookTime: 20, prepTime: 15, calories: 490, difficulty: 'Легко', servings: 4,
      categoryColor: Color(0xFFFFC107), cuisineColor: Color(0xFFEF4444),
      tags: ['ужин', 'мексиканская', 'курица', 'авокадо'],
      ingredients: [
        Ingredient(name: 'Куриное филе', amount: '500', unit: 'г', emoji: '🍗'),
        Ingredient(name: 'Тортильи', amount: '8', unit: 'шт', emoji: '🫓'),
        Ingredient(name: 'Авокадо', amount: '2', unit: 'шт', emoji: '🥑'),
        Ingredient(name: 'Помидоры черри', amount: '200', unit: 'г', emoji: '🍅'),
        Ingredient(name: 'Лайм', amount: '2', unit: 'шт', emoji: '🍋'),
        Ingredient(name: 'Паприка + кумин', amount: '1', unit: 'ч.л.', emoji: '🫙'),
        Ingredient(name: 'Кинза', amount: 'пучок', unit: '', emoji: '🌿'),
      ],
      steps: [
        'Замаринуй курицу в паприке, кумине, чесноке и соке лайма.',
        'Обжарь на сильном огне полосками 5-7 мин.',
        'Разомни авокадо с лаймом, солью и кинзой.',
        'Прогрей тортильи на сухой сковороде.',
        'Собери: авокадо → курица → томаты → кинза.',
      ],
      tips: '💡 Не трогай курицу первые 3 мин — так образуется корочка и сок остаётся внутри.',
    ),

    Recipe(
      id: 'рамен', title: 'Рамен с яйцом и чашу',
      description: 'Ароматный японский суп с пшеничной лапшой, мягким яйцом и свининой.',
      category: 'Ужин', cuisine: 'Японская', emoji: '🍜',
      cookTime: 30, prepTime: 15, calories: 520, difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFFE91E63), cuisineColor: Color(0xFFEC4899),
      tags: ['ужин', 'японская', 'суп', 'лапша'],
      ingredients: [
        Ingredient(name: 'Лапша рамен', amount: '200', unit: 'г', emoji: '🍜'),
        Ingredient(name: 'Свинина чашу', amount: '200', unit: 'г', emoji: '🥩'),
        Ingredient(name: 'Яйца', amount: '2', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Мисо-паста', amount: '2', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Куриный бульон', amount: '800', unit: 'мл', emoji: '🫙'),
        Ingredient(name: 'Соевый соус', amount: '2', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Зелёный лук', amount: '3', unit: 'пера', emoji: '🌱'),
        Ingredient(name: 'Нори', amount: '2', unit: 'листа', emoji: '🌿'),
      ],
      steps: [
        'Свари яйца 6.5 мин (мягкое). Остуди в ледяной воде, очисти.',
        'Замаринуй яйца в соевом соусе + мирин 1 час.',
        'Обжарь свинину со всех сторон, запеки при 180°С 30 мин.',
        'Нагрей бульон, добавь мисо-пасту и соевый соус.',
        'Свари лапшу по инструкции.',
        'Собери: лапша + бульон + свинина + яйцо + нори + лук.',
      ],
      tips: '💡 Маринованное яйцо — душа рамена. Не пропускай этот шаг!',
    ),

    // ===== СУПЫ =====
    Recipe(
      id: 'борщ', title: 'Борщ классический',
      description: 'Наваристый борщ на говяжьем бульоне — душа русской кухни.',
      category: 'Суп', cuisine: 'Русская', emoji: '🍲',
      cookTime: 120, prepTime: 20, calories: 280, difficulty: 'Средне', servings: 6,
      categoryColor: Color(0xFFE53935), cuisineColor: Color(0xFF1D4ED8),
      tags: ['суп', 'русская', 'говядина', 'свёкла'],
      ingredients: [
        Ingredient(name: 'Говядина на кости', amount: '600', unit: 'г', emoji: '🥩'),
        Ingredient(name: 'Свёкла', amount: '2', unit: 'шт', emoji: '🫚'),
        Ingredient(name: 'Капуста', amount: '300', unit: 'г', emoji: '🥬'),
        Ingredient(name: 'Картофель', amount: '3', unit: 'шт', emoji: '🥔'),
        Ingredient(name: 'Морковь', amount: '1', unit: 'шт', emoji: '🥕'),
        Ingredient(name: 'Томатная паста', amount: '2', unit: 'ст.л.', emoji: '🍅'),
        Ingredient(name: 'Уксус 9%', amount: '1', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Сметана', amount: 'для подачи', unit: '', emoji: '🥛'),
      ],
      steps: [
        'Залей говядину холодной водой, вари 1.5 часа снимая пену.',
        'Туши тёртую свёклу с томатпастой и уксусом 10 мин.',
        'Обжарь лук и морковь до золотистого цвета.',
        'В бульон добавь картофель, через 10 мин — капусту.',
        'Через 7 мин добавь зажарку и свёклу. Вари 5 мин.',
        'Добавь мясо, чеснок, лавровый лист. Настаивай 30 мин.',
      ],
      tips: '💡 Уксус в свёкле — секрет яркого цвета! Борщ на второй день всегда вкуснее.',
    ),

    Recipe(
      id: 'томям', title: 'Том Ям с креветками',
      description: 'Огненный тайский суп с кокосовым молоком и тигровыми креветками.',
      category: 'Суп', cuisine: 'Тайская', emoji: '🦐',
      cookTime: 25, prepTime: 15, calories: 320, difficulty: 'Средне', servings: 2,
      categoryColor: Color(0xFFFF5722), cuisineColor: Color(0xFFD97706),
      tags: ['суп', 'тайская', 'острое', 'морепродукты'],
      ingredients: [
        Ingredient(name: 'Тигровые креветки', amount: '300', unit: 'г', emoji: '🦐'),
        Ingredient(name: 'Кокосовое молоко', amount: '400', unit: 'мл', emoji: '🥥'),
        Ingredient(name: 'Куриный бульон', amount: '500', unit: 'мл', emoji: '🫙'),
        Ingredient(name: 'Лемонграсс', amount: '2', unit: 'стебля', emoji: '🌿'),
        Ingredient(name: 'Чили', amount: '2', unit: 'шт', emoji: '🌶️'),
        Ingredient(name: 'Рыбный соус', amount: '2', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Лайм', amount: '2', unit: 'шт', emoji: '🍋'),
        Ingredient(name: 'Грибы шиитаке', amount: '100', unit: 'г', emoji: '🍄'),
      ],
      steps: [
        'Разбей лемонграсс, нарежь имбирь монетками. Вари в бульоне 10 мин.',
        'Добавь кокосовое молоко, доведи до кипения.',
        'Добавь грибы, вари 5 мин.',
        'Добавь креветки, вари 3 мин до розового цвета.',
        'Заправь рыбным соусом и соком лайма.',
        'Подавай с кинзой. Лемонграсс и имбирь не едят!',
      ],
      tips: '💡 Баланс 4 вкусов: острый + кислый + солёный + сладкий. Это и есть Том Ям.',
    ),

    Recipe(
      id: 'карри', title: 'Карри с курицей',
      description: 'Ароматное индийское карри с кокосовым молоком и нутом.',
      category: 'Ужин', cuisine: 'Индийская', emoji: '🍛',
      cookTime: 35, prepTime: 10, calories: 480, difficulty: 'Легко', servings: 4,
      categoryColor: Color(0xFFFF9800), cuisineColor: Color(0xFFB45309),
      tags: ['ужин', 'индийская', 'курица', 'острое'],
      ingredients: [
        Ingredient(name: 'Куриное филе', amount: '600', unit: 'г', emoji: '🍗'),
        Ingredient(name: 'Кокосовое молоко', amount: '400', unit: 'мл', emoji: '🥥'),
        Ingredient(name: 'Нут', amount: '200', unit: 'г', emoji: '🫘'),
        Ingredient(name: 'Помидоры', amount: '3', unit: 'шт', emoji: '🍅'),
        Ingredient(name: 'Лук', amount: '2', unit: 'шт', emoji: '🧅'),
        Ingredient(name: 'Карри-паста', amount: '2', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Имбирь + чеснок', amount: '1', unit: 'ст.л.', emoji: '🧄'),
        Ingredient(name: 'Рис басмати', amount: '300', unit: 'г', emoji: '🍚'),
      ],
      steps: [
        'Обжарь лук до золотистого, добавь чеснок и имбирь.',
        'Добавь карри-пасту, жарь 2 мин до аромата.',
        'Добавь нарезанные помидоры, туши 5 мин.',
        'Добавь курицу, обжарь со всех сторон.',
        'Влей кокосовое молоко и нут. Туши 20 мин.',
        'Подавай с рисом басмати и кинзой.',
      ],
      tips: '💡 Карри-паста раскрывается при жарке в масле — не пропускай этот шаг!',
    ),

    // ===== ЯПОНСКАЯ =====
    Recipe(
      id: 'суши', title: 'Суши-ролл Калифорния',
      description: 'Классический ролл с крабом, авокадо и огурцом в икре тобико.',
      category: 'Обед', cuisine: 'Японская', emoji: '🍣',
      cookTime: 30, prepTime: 30, calories: 380, difficulty: 'Сложно', servings: 2,
      categoryColor: Color(0xFFEC4899), cuisineColor: Color(0xFFEC4899),
      tags: ['японская', 'суши', 'ролл', 'морепродукты'],
      ingredients: [
        Ingredient(name: 'Рис для суши', amount: '300', unit: 'г', emoji: '🍚'),
        Ingredient(name: 'Крабовые палочки', amount: '6', unit: 'шт', emoji: '🦀'),
        Ingredient(name: 'Авокадо', amount: '1', unit: 'шт', emoji: '🥑'),
        Ingredient(name: 'Огурец', amount: '1', unit: 'шт', emoji: '🥒'),
        Ingredient(name: 'Нори', amount: '3', unit: 'листа', emoji: '🌿'),
        Ingredient(name: 'Рисовый уксус', amount: '3', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Икра тобико', amount: '50', unit: 'г', emoji: '✨'),
        Ingredient(name: 'Кунжут', amount: '2', unit: 'ст.л.', emoji: '✨'),
      ],
      steps: [
        'Свари рис, заправь рисовым уксусом с сахаром и солью. Охлади.',
        'Нарежь авокадо и огурец тонкими полосками.',
        'На бамбуковый коврик положи нори, сверху рис.',
        'Переверни нори рисом вниз. Выложи начинку.',
        'Сверни в плотный ролл, обваляй в тобико и кунжуте.',
        'Нарежь острым ножом. Подавай с соевым соусом и васаби.',
      ],
      tips: '💡 Смачивай нож в воде перед каждым разрезом — так ролл не распадается.',
    ),

    // ===== ФРАНЦУЗСКАЯ =====
    Recipe(
      id: 'пицца', title: 'Пицца Маргарита',
      description: 'Настоящая неаполитанская пицца с моцареллой и базиликом.',
      category: 'Ужин', cuisine: 'Итальянская', emoji: '🍕',
      cookTime: 15, prepTime: 60, calories: 560, difficulty: 'Средне', servings: 4,
      categoryColor: Color(0xFFEF4444), cuisineColor: Color(0xFF10B981),
      tags: ['ужин', 'итальянская', 'пицца', 'выпечка'],
      ingredients: [
        Ingredient(name: 'Мука 00', amount: '400', unit: 'г', emoji: '🌾'),
        Ingredient(name: 'Дрожжи сухие', amount: '7', unit: 'г', emoji: '✨'),
        Ingredient(name: 'Моцарелла', amount: '250', unit: 'г', emoji: '🧀'),
        Ingredient(name: 'Томатный соус', amount: '200', unit: 'мл', emoji: '🍅'),
        Ingredient(name: 'Свежий базилик', amount: 'пучок', unit: '', emoji: '🌿'),
        Ingredient(name: 'Оливковое масло', amount: '2', unit: 'ст.л.', emoji: '🫒'),
        Ingredient(name: 'Соль', amount: '1', unit: 'ч.л.', emoji: '🧂'),
      ],
      steps: [
        'Замеси тесто: мука + дрожжи + вода + масло + соль.',
        'Оставь подходить 1 час в тепле.',
        'Разогрей духовку до максимума (250°С+) с противнем внутри.',
        'Раскатай тесто тонко, намажь томатный соус.',
        'Выложи рваную моцареллу.',
        'Выпекай 10-15 мин до корочки. Добавь базилик при подаче.',
      ],
      tips: '💡 Чем горячее духовка — тем лучше пицца. Камень для пиццы даёт идеальную корочку.',
    ),

    // ===== ЗАКУСКИ =====
    Recipe(
      id: 'брускетта', title: 'Брускетта с томатами',
      description: 'Итальянская классика — хрустящий хлеб с томатами и базиликом.',
      category: 'Закуски', cuisine: 'Итальянская', emoji: '🥖',
      cookTime: 10, prepTime: 10, calories: 180, difficulty: 'Легко', servings: 4,
      categoryColor: Color(0xFFEF5350), cuisineColor: Color(0xFF10B981),
      tags: ['закуска', 'итальянская', 'томаты', 'быстро'],
      ingredients: [
        Ingredient(name: 'Багет', amount: '1', unit: 'шт', emoji: '🥖'),
        Ingredient(name: 'Помидоры', amount: '4', unit: 'шт', emoji: '🍅'),
        Ingredient(name: 'Базилик', amount: 'пучок', unit: '', emoji: '🌿'),
        Ingredient(name: 'Чеснок', amount: '2', unit: 'зубчика', emoji: '🧄'),
        Ingredient(name: 'Оливковое масло', amount: '3', unit: 'ст.л.', emoji: '🫒'),
        Ingredient(name: 'Бальзамик', amount: '1', unit: 'ст.л.', emoji: '🫙'),
      ],
      steps: [
        'Нарежь багет, полей маслом, запеки 8 мин при 180°С.',
        'Нарежь томаты, посоли, дай 5 мин, слей сок.',
        'Добавь базилик и масло к томатам.',
        'Натри хлеб чесноком.',
        'Выложи томаты, сбрызни бальзамиком.',
      ],
      tips: '💡 Обязательно слей сок с томатов — иначе хлеб размокнет!',
    ),

    Recipe(
      id: 'хумус', title: 'Домашний хумус',
      description: 'Кремовый нутовый хумус с тахини — в 10 раз вкуснее магазинного.',
      category: 'Закуски', cuisine: 'Ближневосточная', emoji: '🫙',
      cookTime: 5, prepTime: 10, calories: 160, difficulty: 'Легко', servings: 6,
      categoryColor: Color(0xFFFFB347), cuisineColor: Color(0xFF92400E),
      tags: ['закуска', 'нут', 'ПП', 'веган'],
      ingredients: [
        Ingredient(name: 'Нут консервированный', amount: '400', unit: 'г', emoji: '🫘'),
        Ingredient(name: 'Тахини', amount: '3', unit: 'ст.л.', emoji: '🫙'),
        Ingredient(name: 'Лимонный сок', amount: '3', unit: 'ст.л.', emoji: '🍋'),
        Ingredient(name: 'Чеснок', amount: '1', unit: 'зубчик', emoji: '🧄'),
        Ingredient(name: 'Оливковое масло', amount: '2', unit: 'ст.л.', emoji: '🫒'),
        Ingredient(name: 'Лёд', amount: '4', unit: 'кубика', emoji: '🧊'),
      ],
      steps: [
        'Пробивай в блендере нут, тахини, лимон, чеснок и лёд 4 мин.',
        'Посоли по вкусу.',
        'Выложи в тарелку, сделай ямку.',
        'Полей маслом, посыпь паприкой и зирой.',
      ],
      tips: '💡 Лёд — секрет шелковистого хумуса! Дай взбиваться дольше — лучше текстура.',
    ),

    // ===== ДЕСЕРТЫ =====
    Recipe(
      id: 'фондан', title: 'Шоколадный фондан',
      description: 'Горячий кекс с жидкой шоколадной начинкой — покоряет с первой ложки.',
      category: 'Десерты', cuisine: 'Французская', emoji: '🍫',
      cookTime: 12, prepTime: 15, calories: 450, difficulty: 'Средне', servings: 4,
      categoryColor: Color(0xFF5D4037), cuisineColor: Color(0xFF7C3AED),
      tags: ['десерт', 'шоколад', 'французская', 'выпечка'],
      ingredients: [
        Ingredient(name: 'Тёмный шоколад 70%', amount: '150', unit: 'г', emoji: '🍫'),
        Ingredient(name: 'Сливочное масло', amount: '100', unit: 'г', emoji: '🧈'),
        Ingredient(name: 'Яйца', amount: '4', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Сахар', amount: '80', unit: 'г', emoji: '🍬'),
        Ingredient(name: 'Мука', amount: '40', unit: 'г', emoji: '🌾'),
        Ingredient(name: 'Мороженое', amount: 'для подачи', unit: '', emoji: '🍨'),
      ],
      steps: [
        'Разогрей духовку 200°С. Смажь формочки маслом и присыпь какао.',
        'Растопи шоколад с маслом на водяной бане.',
        'Взбей яйца с сахаром добела.',
        'Соедини шоколад с яйцами, добавь муку.',
        'Разлей по формочкам, охлади 10 мин.',
        'Выпекай 10-12 мин. Центр должен дрожать!',
      ],
      tips: '⚡ Критично: не перепеки! Если центр не дрожит — жидкая начинка уже затвердела.',
    ),

    Recipe(
      id: 'тирамису', title: 'Тирамису',
      description: 'Нежный итальянский десерт из маскарпоне и савоярди без выпечки.',
      category: 'Десерты', cuisine: 'Итальянская', emoji: '☕',
      cookTime: 0, prepTime: 30, calories: 380, difficulty: 'Средне', servings: 6,
      categoryColor: Color(0xFF8D6E63), cuisineColor: Color(0xFF10B981),
      tags: ['десерт', 'итальянская', 'кофе', 'без выпечки'],
      ingredients: [
        Ingredient(name: 'Маскарпоне', amount: '500', unit: 'г', emoji: '🧀'),
        Ingredient(name: 'Савоярди', amount: '300', unit: 'г', emoji: '🫓'),
        Ingredient(name: 'Яйца', amount: '4', unit: 'шт', emoji: '🥚'),
        Ingredient(name: 'Сахар', amount: '100', unit: 'г', emoji: '🍬'),
        Ingredient(name: 'Эспрессо', amount: '300', unit: 'мл', emoji: '☕'),
        Ingredient(name: 'Амаретто или ром', amount: '50', unit: 'мл', emoji: '🍷'),
        Ingredient(name: 'Какао', amount: '2', unit: 'ст.л.', emoji: '🫙'),
      ],
      steps: [
        'Взбей желтки с сахаром добела 5 мин.',
        'Добавь маскарпоне, перемешай до однородности.',
        'Взбей белки в крепкую пену.',
        'Аккуратно вмешай белки в крем.',
        'Обмакни савоярди в кофе+ром (0.5 секунды!), выложи в форму.',
        'Нанеси крем, повтори слои. Посыпь какао.',
        'Убери в холодильник на 4+ часа.',
      ],
      tips: '💡 0.5 секунды в кофе — не дольше! Иначе савоярди раскиснут.',
    ),

    // ===== НАПИТКИ =====
    Recipe(
      id: 'матча', title: 'Матча латте',
      description: 'Бархатный зелёный напиток с японским чаем и вспененным молоком.',
      category: 'Напитки', cuisine: 'Японская', emoji: '🍵',
      cookTime: 5, prepTime: 3, calories: 120, difficulty: 'Легко', servings: 1,
      categoryColor: Color(0xFF66BB6A), cuisineColor: Color(0xFFEC4899),
      tags: ['напиток', 'японская', 'матча', 'ПП'],
      ingredients: [
        Ingredient(name: 'Порошок матча', amount: '2', unit: 'ч.л.', emoji: '🌿'),
        Ingredient(name: 'Вода 80°С', amount: '60', unit: 'мл', emoji: '💧'),
        Ingredient(name: 'Молоко', amount: '200', unit: 'мл', emoji: '🥛'),
        Ingredient(name: 'Мёд', amount: '1', unit: 'ч.л.', emoji: '🍯'),
      ],
      steps: [
        'Просей матча через сито.',
        'Добавь воду 80°С (не кипяток!), взбей венчиком до пены.',
        'Добавь мёд, перемешай.',
        'Подогрей молоко до 65°С, вспени.',
        'Влей молоко в матча.',
      ],
      tips: '💡 80°С, не кипяток — сохраняет антиоксиданты и убирает горечь.',
    ),

    Recipe(
      id: 'смузи', title: 'Смузи Тропический рай',
      description: 'Освежающий смузи с манго, ананасом и кокосом — стакан лета.',
      category: 'Напитки', cuisine: 'Американская', emoji: '🥭',
      cookTime: 0, prepTime: 5, calories: 190, difficulty: 'Легко', servings: 2,
      categoryColor: Color(0xFFFFCA28), cuisineColor: Color(0xFF3B82F6),
      tags: ['напиток', 'смузи', 'манго', 'веган'],
      ingredients: [
        Ingredient(name: 'Манго замороженное', amount: '200', unit: 'г', emoji: '🥭'),
        Ingredient(name: 'Ананас', amount: '150', unit: 'г', emoji: '🍍'),
        Ingredient(name: 'Кокосовое молоко', amount: '150', unit: 'мл', emoji: '🥥'),
        Ingredient(name: 'Банан', amount: '1', unit: 'шт', emoji: '🍌'),
        Ingredient(name: 'Лайм', amount: '½', unit: 'шт', emoji: '🍋'),
      ],
      steps: [
        'Сложи всё в блендер.',
        'Взбивай на максимуме 2 минуты.',
        'Попробуй — добавь мёд если нужно.',
        'Разлей по стаканам, укрась фруктами.',
      ],
      tips: '💡 Замороженное манго даёт кремовую текстуру без льда.',
    ),
  ];
}
