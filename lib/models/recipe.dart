import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final String cuisine; // кухня мира
  final String emoji;
  final int cookTime;
  final int prepTime;
  final int calories;
  final String difficulty;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<String> tags;
  final String? tips;
  final Color categoryColor;
  final Color cuisineColor;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.cuisine = '',
    required this.emoji,
    required this.cookTime,
    required this.prepTime,
    required this.calories,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.tags,
    this.tips,
    required this.categoryColor,
    this.cuisineColor = const Color(0xFF9E9E9E),
  });

  int get totalTime => cookTime + prepTime;

  // Красивые градиентные фото от foodish API и других бесплатных источников
  // Используем DummyImage и foodish — работают без ключа
  String get imageUrl {
    // Foodish API - реальные фото еды по категориям, полностью бесплатно
    final map = {
      'панкейки': 'https://foodish-api.com/images/burger/burger1.jpg',
      'авокадо': 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?w=600&h=400&fit=crop',
      'овсянка': 'https://images.pexels.com/photos/704971/pexels-photo-704971.jpeg?w=600&h=400&fit=crop',
      'паста': 'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?w=600&h=400&fit=crop',
      'цезарь': 'https://images.pexels.com/photos/2097090/pexels-photo-2097090.jpeg?w=600&h=400&fit=crop',
      'борщ': 'https://images.pexels.com/photos/539451/pexels-photo-539451.jpeg?w=600&h=400&fit=crop',
      'лосось': 'https://images.pexels.com/photos/3655916/pexels-photo-3655916.jpeg?w=600&h=400&fit=crop',
      'тако': 'https://images.pexels.com/photos/2092507/pexels-photo-2092507.jpeg?w=600&h=400&fit=crop',
      'брускетта': 'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg?w=600&h=400&fit=crop',
      'хумус': 'https://images.pexels.com/photos/5718025/pexels-photo-5718025.jpeg?w=600&h=400&fit=crop',
      'фондан': 'https://images.pexels.com/photos/2067396/pexels-photo-2067396.jpeg?w=600&h=400&fit=crop',
      'тирамису': 'https://images.pexels.com/photos/6880219/pexels-photo-6880219.jpeg?w=600&h=400&fit=crop',
      'томям': 'https://images.pexels.com/photos/1731535/pexels-photo-1731535.jpeg?w=600&h=400&fit=crop',
      'матча': 'https://images.pexels.com/photos/3879495/pexels-photo-3879495.jpeg?w=600&h=400&fit=crop',
      'смузи': 'https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?w=600&h=400&fit=crop',
      'пицца': 'https://images.pexels.com/photos/2147491/pexels-photo-2147491.jpeg?w=600&h=400&fit=crop',
      'суши': 'https://images.pexels.com/photos/1640773/pexels-photo-1640773.jpeg?w=600&h=400&fit=crop',
      'карри': 'https://images.pexels.com/photos/2474661/pexels-photo-2474661.jpeg?w=600&h=400&fit=crop',
      'стейк': 'https://images.pexels.com/photos/1251208/pexels-photo-1251208.jpeg?w=600&h=400&fit=crop',
      'рамен': 'https://images.pexels.com/photos/884600/pexels-photo-884600.jpeg?w=600&h=400&fit=crop',
    };
    return map[id] ?? 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?w=600&h=400&fit=crop';
  }

  String get difficultyEmoji {
    switch (difficulty) {
      case 'Легко': return '🟢';
      case 'Средне': return '🟡';
      case 'Сложно': return '🔴';
      default: return '🟢';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'Легко': return const Color(0xFF4CAF50);
      case 'Средне': return const Color(0xFFFF9800);
      case 'Сложно': return const Color(0xFFF44336);
      default: return const Color(0xFF4CAF50);
    }
  }
}

class Ingredient {
  final String name;
  final String amount;
  final String unit;
  final String? emoji;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.emoji,
  });
}
