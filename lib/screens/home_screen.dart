import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/recipes_data.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'ai_chat_screen.dart';
import 'favorites_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: _idx,
        children: const [_RecipesTab(), AiChatScreen(), FavoritesScreen()],
      ),
      bottomNavigationBar: _BottomBar(current: _idx, onTap: (i) => setState(() => _idx = i)),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBtn(icon: Icons.grid_view_rounded, label: 'Рецепты', active: current == 0, onTap: () => onTap(0)),
              GestureDetector(
                onTap: () => onTap(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: current == 1
                          ? [AppTheme.primary, AppTheme.secondary]
                          : [AppTheme.dark, const Color(0xFF16213E)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(
                      color: (current == 1 ? AppTheme.primary : AppTheme.dark).withOpacity(0.35),
                      blurRadius: 12, offset: const Offset(0, 4),
                    )],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('✨', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 6),
                    Text('ШефАИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  ]),
                ),
              ),
              _NavBtn(icon: Icons.favorite_rounded, label: 'Избранное', active: current == 2, onTap: () => onTap(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: active ? AppTheme.primary : Colors.grey.shade400, size: 22),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
          color: active ? AppTheme.primary : Colors.grey.shade400,
          fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        )),
      ]),
    ),
  );
}

// ===================== РЕЦЕПТЫ =====================
class _RecipesTab extends StatelessWidget {
  const _RecipesTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          _buildSearch(context),
          _buildCategories(context),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Добро пожаловать! 👋', style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        const Text('Что готовим?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.dark, letterSpacing: -0.5)),
      ])),
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Center(child: Text('👨‍🍳', style: TextStyle(fontSize: 24))),
      ),
    ]),
  );

  Widget _buildSearch(BuildContext ctx) {
    final data = ctx.watch<RecipesData>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: TextField(
          onChanged: data.setSearch,
          style: const TextStyle(fontSize: 14, color: AppTheme.dark),
          decoration: InputDecoration(
            hintText: 'Поиск рецептов, ингредиентов...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
            suffixIcon: data.searchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey), onPressed: () => data.setSearch(''))
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext ctx) {
    final data = ctx.watch<RecipesData>();
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: data.categories.length,
        itemBuilder: (ctx, i) {
          final cat = data.categories[i];
          final selected = data.selectedCategory == cat;
          return GestureDetector(
            onTap: () => data.setCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.dark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: selected ? AppTheme.dark.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                  blurRadius: selected ? 10 : 4, offset: const Offset(0, 2),
                )],
              ),
              child: Text(cat, style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext ctx) {
    final recipes = ctx.watch<RecipesData>().filteredRecipes;
    if (recipes.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        const Text('Ничего не найдено', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.dark)),
        const SizedBox(height: 6),
        Text('Попробуй другой запрос', style: TextStyle(color: Colors.grey.shade500)),
      ]));
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildFeatured(ctx, recipes.first)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (c, i) => RecipeCard(
                recipe: recipes[i],
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipes[i]))),
              ).animate().fadeIn(delay: (i * 50).ms).slideY(begin: 0.08, end: 0, duration: 300.ms),
              childCount: recipes.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatured(BuildContext ctx, recipe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: GestureDetector(
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(children: [
              Positioned.fill(child: Image.asset(
                recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _imgPlaceholder(recipe),
              )),
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.78)],
                  stops: const [0.35, 1.0],
                ),
              ))),
              Positioned(top: 14, left: 14, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.secondary, borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('⭐ ', style: TextStyle(fontSize: 12)),
                  Text('Рецепт дня', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                ]),
              )),
              Positioned(bottom: 14, left: 14, right: 14, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 8, color: Colors.black54)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    _chip('⏱ ${recipe.totalTime} мин'),
                    const SizedBox(width: 6),
                    _chip('🔥 ${recipe.calories} ккал'),
                    const SizedBox(width: 6),
                    _chip('${recipe.difficultyEmoji} ${recipe.difficulty}'),
                  ]),
                ],
              )),
            ]),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  Widget _imgPlaceholder(recipe) => Container(
    decoration: BoxDecoration(gradient: LinearGradient(colors: [recipe.categoryColor.withOpacity(0.7), recipe.categoryColor])),
    child: Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 72))),
  );
}
