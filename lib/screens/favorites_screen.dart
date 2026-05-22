import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../data/recipes_data.dart';
import '../main.dart';
import 'home_screen.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favIds = context.watch<FavoritesService>().favorites;
    final favs = context.watch<RecipesData>().allRecipes.where((r) => favIds.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Избранное', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.dark)),
                    const SizedBox(height: 4),
                    Text('${favs.length} рецептов сохранено', style: TextStyle(color: AppTheme.grey, fontSize: 14)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (favs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
                        child: const Center(child: Text('❤️', style: TextStyle(fontSize: 50))),
                      ),
                      const SizedBox(height: 20),
                      const Text('Нет избранных', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.dark)),
                      const SizedBox(height: 8),
                      Text('Нажми ❤️ на рецепте чтобы сохранить', style: TextStyle(color: AppTheme.grey, fontSize: 14), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => RecipeCard(
                      recipe: favs[i],
                      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: favs[i]))),
                    ),
                    childCount: favs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
