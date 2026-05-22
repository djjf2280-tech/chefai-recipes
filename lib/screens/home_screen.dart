import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/recipes_data.dart';
import '../services/favorites_service.dart';
import '../models/recipe.dart';
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
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const _RecipesTab(),
    const AiChatScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0EB),
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBtn(icon: Icons.grid_view_rounded, label: 'Рецепты', active: currentIndex == 0, onTap: () => onTap(0)),
              // Центральная кнопка AI
              GestureDetector(
                onTap: () => onTap(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: currentIndex == 1
                          ? [AppTheme.primary, AppTheme.secondary]
                          : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (currentIndex == 1 ? AppTheme.primary : const Color(0xFF1A1A2E)).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text('ШефАИ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              _NavBtn(icon: Icons.favorite_rounded, label: 'Избранное', active: currentIndex == 2, onTap: () => onTap(2)),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppTheme.primary : Colors.grey.shade400, size: 24),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              color: active ? AppTheme.primary : Colors.grey.shade400,
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }
}

// =================== ВКЛАДКА РЕЦЕПТОВ ===================

class _RecipesTab extends StatelessWidget {
  const _RecipesTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(child: _buildSearch(context)),
        SliverToBoxAdapter(child: _buildCategories(context)),
        SliverToBoxAdapter(child: _buildFeatured(context)),
        SliverToBoxAdapter(child: _buildSectionTitle('Все рецепты')),
        _buildGrid(context),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Привет, Шеф! 👋',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Что\nприготовим?',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.dark, height: 1.1, letterSpacing: -1),
                ),
              ],
            ),
          ),
          // Аватар
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Center(child: Text('👨‍🍳', style: TextStyle(fontSize: 26))),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final data = context.watch<RecipesData>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: TextField(
          onChanged: data.setSearch,
          style: const TextStyle(fontSize: 15, color: AppTheme.dark),
          decoration: InputDecoration(
            hintText: 'Поиск рецептов, ингредиентов...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
            ),
            suffixIcon: data.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                    onPressed: () => data.setSearch(''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final data = context.watch<RecipesData>();
    const catEmojis = {
      'Все': '🍽️', 'Завтрак': '☀️', 'Обед': '🍱',
      'Ужин': '🌙', 'Закуски': '🥨', 'Суп': '🥣',
      'Десерты': '🍰', 'Напитки': '🥤',
    };
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: data.categories.length,
        itemBuilder: (ctx, i) {
          final cat = data.categories[i];
          final selected = data.selectedCategory == cat;
          return GestureDetector(
            onTap: () => data.setCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.dark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [BoxShadow(color: AppTheme.dark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(catEmojis[cat] ?? '🍴', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(cat, style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
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
    final recipe = context.read<RecipesData>().allRecipes.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, prog) {
                      if (prog == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [recipe.categoryColor.withOpacity(0.7), recipe.categoryColor],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 80))),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [recipe.categoryColor.withOpacity(0.7), recipe.categoryColor]),
                      ),
                      child: Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 80))),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⭐', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 5),
                        Text('Рецепт дня', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _FeaturedChip('⏱ ${recipe.totalTime} мин'),
                          const SizedBox(width: 8),
                          _FeaturedChip('🔥 ${recipe.calories} ккал'),
                          const SizedBox(width: 8),
                          _FeaturedChip('${recipe.difficultyEmoji} ${recipe.difficulty}'),
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
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.dark)),
          const Spacer(),
          Consumer<RecipesData>(
            builder: (_, data, __) => Text(
              '${data.filteredRecipes.length} рецептов',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final recipes = context.watch<RecipesData>().filteredRecipes;
    if (recipes.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(children: [
              const Text('🔍', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('Ничего не найдено', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.dark)),
              const SizedBox(height: 8),
              Text('Попробуй другой запрос', style: TextStyle(color: Colors.grey.shade500)),
            ]),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => RecipeCard(
            recipe: recipes[i],
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipes[i]))),
          ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1, end: 0),
          childCount: recipes.length,
        ),
      ),
    );
  }
}

class _FeaturedChip extends StatelessWidget {
  final String text;
  const _FeaturedChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
