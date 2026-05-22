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
  // Локальный asset — работает без интернета!
  String get imageUrl => 'assets/food/$id.jpg';


