import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final String cuisine;
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

  // Локальный asset — фото встроены в APK, работают без интернета
  String get imageUrl => 'assets/food/$id.jpg';

  String get difficultyEmoji {
    switch (difficulty) {
      case 'Легко':  return '🟢';
      case 'Средне': return '🟡';
      case 'Сложно': return '🔴';
      default:       return '🟢';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'Легко':  return const Color(0xFF4CAF50);
      case 'Средне': return const Color(0xFFFF9800);
      case 'Сложно': return const Color(0xFFF44336);
      default:       return const Color(0xFF4CAF50);
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
