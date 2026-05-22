import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/recipes_data.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import '../main.dart';
import 'recipe_detail_screen.dart';
import 'ai_chat_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(
        index: _tab,
        children: const [_RecipesTab(), AiChatScreen(), FavoritesScreen()],
      ),
      bottomNavigationBar: _BottomNav(current: _tab, onTap: (i) => setState(() => _tab = i)),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavBtn(icon: Icons.menu_book_rounded, label: 'Рецепты', active: current == 0, onTap: () => onTap(0)),
              // центральная кнопка ШефАИ
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: 250.ms,
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: current == 1
                                ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                                : [AppTheme.primary, AppTheme.secondary],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(
                            color: (current == 1 ? const Color(0xFF6366F1) : AppTheme.primary).withOpacity(0.4),
                            blurRadius: 16, offset: const Offset(0, 4),
                          )],
                        ),
                        child: const Center(child: Text('👨‍🍳', style: TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(height: 2),
                      Text('ШефАИ', style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: current == 1 ? const Color(0xFF6366F1) : AppTheme.grey,
                      )),
                    ],
                  ),
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
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: active ? AppTheme.primary : AppTheme.grey),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: active ? AppTheme.primary : AppTheme.grey,
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RECIPES TAB
// ─────────────────────────────────────────────
class _RecipesTab extends StatelessWidget {
  const _RecipesTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(child: _buildSearchBar(context)),
        SliverToBoxAdapter(child: _buildCategories(context)),
        SliverToBoxAdapter(child: _buildFeatured(context)),
        SliverToBoxAdapter(child: _buildSectionTitle('Все рецепты')),
        _buildGrid(context),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverSafeArea(
      bottom: false,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Привет, шеф! 👋', style: TextStyle(fontSize: 13, color: AppTheme.grey, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    const Text('Что готовим\nсегодня?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.dark, height: 1.15)),
                  ],
                ),
              ),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('👨‍🍳', style: TextStyle(fontSize: 24))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final data = context.watch<RecipesData>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: TextField(
          onChanged: data.setSearch,
          decoration: InputDecoration(
            hintText: 'Рецепт, ингредиент, категория...',
            hintStyle: TextStyle(color: AppTheme.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final data = context.watch<RecipesData>();
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: RecipesData.categoryList.length,
        itemBuilder: (ctx, i) {
          final cat = RecipesData.categoryList[i];
          final name = cat['name'] as String;
          final icon = cat['icon'] as String;
          final color = cat['color'] as Color;
          final selected = data.selectedCategory == name;
          return GestureDetector(
            onTap: () => data.setCategory(name),
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(name, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.dark,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatured(BuildContext context) {
    final recipe = context.watch<RecipesData>().allRecipes.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Реальное фото
                CachedNetworkImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.lightGrey),
                  errorWidget: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [recipe.categoryColor, recipe.categoryColor.withOpacity(0.7)]),
                    ),
                    child: Center(child: Text(recipe.categoryIcon, style: const TextStyle(fontSize: 80))),
                  ),
                ),
                // Тёмный градиент снизу
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                // Бейдж и текст
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Рецепт дня', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _FeatChip(icon: Icons.timer_outlined, text: '${recipe.totalTime} мин'),
                          const SizedBox(width: 8),
                          _FeatChip(icon: Icons.local_fire_department_outlined, text: '${recipe.calories} ккал'),
                          const SizedBox(width: 8),
                          _FeatChip(icon: Icons.bar_chart_rounded, text: recipe.difficulty),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.dark)),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final recipes = context.watch<RecipesData>().filteredRecipes;
    if (recipes.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                const Text('🔍', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                const Text('Ничего не найдено', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Попробуй другой запрос', style: TextStyle(color: AppTheme.grey)),
              ],
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => RecipeCard(
            recipe: recipes[i],
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipes[i]))),
          ).animate().fadeIn(delay: (i * 40).ms).slideY(begin: 0.1, end: 0),
          childCount: recipes.length,
        ),
      ),
    );
  }
}

class _FeatChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RECIPE CARD
// ─────────────────────────────────────────────
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: recipe.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: recipe.categoryColor.withOpacity(0.15),
                        child: Center(child: Text(recipe.categoryIcon, style: const TextStyle(fontSize: 40))),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: recipe.categoryColor.withOpacity(0.15),
                        child: Center(child: Text(recipe.categoryIcon, style: const TextStyle(fontSize: 40))),
                      ),
                    ),
                    // Градиент снизу фото
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Кнопка избранного
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => context.read<FavoritesService>().toggle(recipe.id),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: isFav ? Colors.red : AppTheme.grey,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                    // Категория
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: recipe.categoryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(recipe.category, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    // Время внизу фото
                    Positioned(
                      bottom: 8, left: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                          const SizedBox(width: 3),
                          Text('${recipe.totalTime} мин', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Инфо
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.dark, height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_outlined, size: 13, color: Color(0xFFFF6B35)),
                        const SizedBox(width: 2),
                        Text('${recipe.calories} ккал', style: TextStyle(fontSize: 11, color: AppTheme.grey, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: recipe.difficulty == 'Легко'
                                ? const Color(0xFF4CAF50).withOpacity(0.12)
                                : recipe.difficulty == 'Средне'
                                    ? const Color(0xFFFFC107).withOpacity(0.15)
                                    : const Color(0xFFE53935).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(recipe.difficulty, style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: recipe.difficulty == 'Легко'
                                ? const Color(0xFF4CAF50)
                                : recipe.difficulty == 'Средне'
                                    ? const Color(0xFFE6A817)
                                    : const Color(0xFFE53935),
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
