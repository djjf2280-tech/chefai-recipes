import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;   // реальное фото Unsplash
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
  final String categoryIcon;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
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
    required this.categoryIcon,
  });

  int get totalTime => cookTime + prepTime;
}

class Ingredient {
  final String name;
  final String amount;
  final String unit;
  final String emoji;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.emoji = '🥄',
  });
}
