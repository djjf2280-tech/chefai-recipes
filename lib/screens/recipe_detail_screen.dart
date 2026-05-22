import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import '../main.dart';
import 'ai_chat_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _servings = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _servings = widget.recipe.servings;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _mult => _servings / widget.recipe.servings;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isFav = context.watch<FavoritesService>().isFavorite(recipe.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: CustomScrollView(
        slivers: [
          // Hero фото
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: recipe.categoryColor,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => context.read<FavoritesService>().toggle(recipe.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFav ? Colors.red.withOpacity(0.9) : Colors.black38,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                  recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [recipe.categoryColor.withOpacity(0.7), recipe.categoryColor]),
                      ),
                      child: Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 100))),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.5)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0EB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              margin: const EdgeInsets.only(top: -28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Категория и сложность
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: recipe.categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(recipe.category, style: TextStyle(color: recipe.categoryColor, fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: recipe.difficultyColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 7, height: 7, decoration: BoxDecoration(color: recipe.difficultyColor, shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text(recipe.difficulty, style: TextStyle(color: recipe.difficultyColor, fontWeight: FontWeight.w800, fontSize: 12)),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Название
                        Text(recipe.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.dark, height: 1.1, letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        Text(recipe.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
                        const SizedBox(height: 20),

                        // Статы
                        _buildStats(recipe),
                        const SizedBox(height: 16),

                        // Пересчёт порций
                        _buildServings(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Табы
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.all(5),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.dark,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: '🥕 Состав'),
                          Tab(text: '👨‍🍳 Шаги'),
                          Tab(text: '💡 Советы'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 420,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildIngredients(recipe),
                        _buildSteps(recipe),
                        _buildTips(recipe),
                      ],
                    ),
                  ),

                  // Кнопка AI
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AiChatScreen(
                          initialMessage: 'Расскажи подробнее про рецепт "${recipe.title}". Какие секреты у этого блюда?',
                        ),
                      )),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: const Color(0xFF1A1A2E).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('✨', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 10),
                            Text('Спросить Шефа Максима', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Recipe recipe) {
    return Row(
      children: [
        _StatBox(emoji: '⏱', value: '${recipe.totalTime}', label: 'минут', color: const Color(0xFF2196F3)),
        const SizedBox(width: 12),
        _StatBox(emoji: '🔥', value: '${recipe.calories}', label: 'ккал', color: AppTheme.primary),
        const SizedBox(width: 12),
        _StatBox(emoji: '👥', value: '${recipe.servings}', label: 'порций', color: const Color(0xFF9C27B0)),
        const SizedBox(width: 12),
        _StatBox(emoji: '📋', value: '${recipe.ingredients.length}', label: 'ингред.', color: const Color(0xFF009688)),
      ],
    );
  }

  Widget _buildServings() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          const Text('Порций', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const Spacer(),
          GestureDetector(
            onTap: () { if (_servings > 1) setState(() => _servings--); },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.remove_rounded, size: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('$_servings', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)),
          ),
          GestureDetector(
            onTap: () => setState(() => _servings++),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(Recipe recipe) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.ingredients.length,
      itemBuilder: (ctx, i) {
        final ing = recipe.ingredients[i];
        final amount = _multAmount(ing.amount, _mult);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: recipe.categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(ing.emoji ?? '🥄', style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.dark))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: recipe.categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('$amount ${ing.unit}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: recipe.categoryColor)),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildSteps(Recipe recipe) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.steps.length,
      itemBuilder: (ctx, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                  ),
                  child: Text(recipe.steps[i], style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.dark)),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildTips(Recipe recipe) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          if (recipe.tips != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
              ),
              child: Text(recipe.tips!, style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.dark)),
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏷️ Теги', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: recipe.tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: recipe.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('#$t', style: TextStyle(color: recipe.categoryColor, fontSize: 12, fontWeight: FontWeight.w700)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _multAmount(String amount, double mult) {
    if (mult == 1.0) return amount;
    final n = double.tryParse(amount.replaceAll(',', '.'));
    if (n == null) return amount;
    final r = n * mult;
    return r == r.roundToDouble() ? r.toInt().toString() : r.toStringAsFixed(1);
  }
}

class _StatBox extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _StatBox({required this.emoji, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}
