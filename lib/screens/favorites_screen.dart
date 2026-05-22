import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final allRecipes = context.watch<RecipesData>().allRecipes;
    final favRecipes = allRecipes.where((r) => favs.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Избранное',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${favRecipes.length} рецептов сохранено',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (favRecipes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('❤️', style: TextStyle(fontSize: 80)),
                      SizedBox(height: 20),
                      Text(
                        'Нет избранных рецептов',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.dark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Нажми ❤️ на рецепте, чтобы сохранить',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => RecipeCard(
                      recipe: favRecipes[i],
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailScreen(recipe: favRecipes[i]),
                        ),
                      ),
                    ),
                    childCount: favRecipes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
