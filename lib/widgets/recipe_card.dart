import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import '../main.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesService>().isFavorite(recipe.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Фото
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(children: [
                Positioned.fill(
                  child: Image.asset(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  ),
                ),
                // Тёмный градиент снизу
                Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                    stops: const [0.5, 1.0],
                  ),
                ))),
                // Кнопка избранного
                Positioned(top: 8, right: 8, child: GestureDetector(
                  onTap: () => context.read<FavoritesService>().toggle(recipe.id),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isFav ? Colors.red.shade500 : Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: Colors.white, size: 16),
                  ),
                )),
                // Категория
                Positioned(top: 8, left: 8, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: recipe.categoryColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(recipe.category,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                )),
                // Кухня
                if (recipe.cuisine.isNotEmpty)
                  Positioned(bottom: 8, left: 8, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: Text(recipe.cuisine,
                        style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w600)),
                  )),
              ]),
            ),
          ),
          // Информация
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppTheme.dark, height: 1.25),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(children: [
                  Icon(Icons.timer_outlined, size: 11, color: Colors.grey.shade400),
                  const SizedBox(width: 2),
                  Text('${recipe.totalTime}м',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(width: 7, height: 7,
                      decoration: BoxDecoration(color: recipe.difficultyColor, shape: BoxShape.circle)),
                  const SizedBox(width: 3),
                  Text(recipe.difficulty,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 4),
                Text('🔥 ${recipe.calories} ккал',
                    style: TextStyle(fontSize: 10, color: AppTheme.primary.withOpacity(0.85), fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    decoration: BoxDecoration(gradient: LinearGradient(
      colors: [recipe.categoryColor.withOpacity(0.5), recipe.categoryColor],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    )),
    child: Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 52))),
  );
}
