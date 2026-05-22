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

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
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

  double get _multiplier => _servings / widget.recipe.servings;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final favorites = context.watch<FavoritesService>();
    final isFav = favorites.isFavorite(recipe.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: recipe.categoryColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.dark, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => favorites.toggle(recipe.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.red : Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      recipe.categoryColor,
                      recipe.categoryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 100),
                      ).animate().scale(
                            delay: 100.ms,
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F4F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: recipe.categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.category,
                            style: TextStyle(
                              color: recipe.categoryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Title
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.dark,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          recipe.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Stats row
                        _buildStatsRow(recipe),

                        const SizedBox(height: 20),

                        // Servings control
                        _buildServingsControl(),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      padding: const EdgeInsets.all(4),
                      tabs: const [
                        Tab(text: '🥕 Состав'),
                        Tab(text: '👨‍🍳 Шаги'),
                        Tab(text: '💡 Советы'),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildIngredientsTab(recipe),
                        _buildStepsTab(recipe),
                        _buildTipsTab(recipe),
                      ],
                    ),
                  ),

                  // AI Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiChatScreen(
                            initialMessage:
                                'Расскажи подробнее о рецепте "${recipe.title}". Какие секреты и советы есть по его приготовлению?',
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Спросить ШефАИ об этом рецепте'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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

  Widget _buildStatsRow(Recipe recipe) {
    return Row(
      children: [
        _StatCard(
          icon: '⏱️',
          value: '${recipe.totalTime}',
          unit: 'мин',
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: '🔥',
          value: '${recipe.calories}',
          unit: 'ккал',
          color: AppTheme.primary,
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: recipe.difficultyEmoji,
          value: recipe.difficulty,
          unit: '',
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: '👥',
          value: '${recipe.servings}',
          unit: 'порц.',
          color: const Color(0xFF9C27B0),
        ),
      ],
    );
  }

  Widget _buildServingsControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          const Text(
            'Порций',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (_servings > 1) setState(() => _servings--);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.remove_rounded, size: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$_servings',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _servings++),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(Recipe recipe) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.ingredients.length,
      itemBuilder: (ctx, i) {
        final ing = recipe.ingredients[i];
        final amount = _parseAndMultiply(ing.amount, _multiplier);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(ing.emoji ?? '🥄', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ing.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.dark,
                  ),
                ),
              ),
              Text(
                '$amount ${ing.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildStepsTab(Recipe recipe) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.steps.length,
      itemBuilder: (ctx, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    recipe.steps[i],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.dark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildTipsTab(Recipe recipe) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          if (recipe.tips != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                recipe.tips!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppTheme.dark,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildTimeInfo(recipe),
          const SizedBox(height: 12),
          _buildTagsRow(recipe),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏱️ Время',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _TimeRow(label: 'Подготовка', value: '${recipe.prepTime} мин'),
              ),
              Expanded(
                child: _TimeRow(label: 'Готовка', value: '${recipe.cookTime} мин'),
              ),
              Expanded(
                child: _TimeRow(
                  label: 'Итого',
                  value: '${recipe.totalTime} мин',
                  bold: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏷️ Теги',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recipe.tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _parseAndMultiply(String amount, double multiplier) {
    if (multiplier == 1.0) return amount;
    final num = double.tryParse(amount.replaceAll(',', '.'));
    if (num == null) return amount;
    final result = num * multiplier;
    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }
    return result.toStringAsFixed(1);
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: color,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TimeRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 16 : 14,
            color: bold ? AppTheme.primary : AppTheme.dark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
