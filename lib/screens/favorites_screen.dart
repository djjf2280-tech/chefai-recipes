import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/favorites_service.dart';
import '../data/recipes_data.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../main.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesService>().favorites;
    final all = context.watch<RecipesData>().allRecipes;
    final favRecipes = all.where((r) => favs.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('❤️ Избранное', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.dark, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(
                      favRecipes.isEmpty ? 'Пока пусто' : '${favRecipes.length} сохранённых рецептов',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (favRecipes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('❤️', style: TextStyle(fontSize: 56))),
                      ),
                      const SizedBox(height: 24),
                      const Text('Нет избранных рецептов', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.dark)),
                      const SizedBox(height: 8),
                      Text('Нажми ❤️ на рецепте, чтобы сохранить', style: TextStyle(color: Colors.grey.shade500, fontSize: 14), textAlign: TextAlign.center),
                    ],
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => RecipeCard(
                      recipe: favRecipes[i],
                      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: favRecipes[i]))),
                    ).animate().fadeIn(delay: (i * 60).ms),
                    childCount: favRecipes.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
