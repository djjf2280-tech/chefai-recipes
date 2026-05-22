import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  late TabController _tabs;
  int _servings = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _servings = widget.recipe.servings;
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  double get _mult => _servings / widget.recipe.servings;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final isFav = context.watch<FavoritesService>().isFavorite(r.id);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // ── HERO ФОТО ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: r.categoryColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.dark, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => context.read<FavoritesService>().toggle(r.id),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(14)),
                  child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: isFav ? Colors.red : AppTheme.grey, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: r.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: r.categoryColor.withOpacity(0.3),
                      child: Center(child: Text(r.categoryIcon, style: const TextStyle(fontSize: 100))),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: r.categoryColor.withOpacity(0.3),
                      child: Center(child: Text(r.categoryIcon, style: const TextStyle(fontSize: 100))),
                    ),
                  ),
                  // Градиент
                  Container(
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

          // ── КОНТЕНТ ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.bg,
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
                        // Категория тег
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(color: r.categoryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(r.categoryIcon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(r.category, style: TextStyle(color: r.categoryColor, fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(r.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.dark, height: 1.2)),
                        const SizedBox(height: 8),
                        Text(r.description, style: TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.5)),
                        const SizedBox(height: 20),

                        // Статистика
                        Row(
                          children: [
                            _StatBox(icon: Icons.timer_outlined, value: '${r.totalTime}', unit: 'мин', color: const Color(0xFF2196F3)),
                            const SizedBox(width: 10),
                            _StatBox(icon: Icons.local_fire_department_outlined, value: '${r.calories}', unit: 'ккал', color: AppTheme.primary),
                            const SizedBox(width: 10),
                            _StatBox(icon: Icons.people_alt_outlined, value: '${r.servings}', unit: 'порц.', color: const Color(0xFF9C27B0)),
                            const SizedBox(width: 10),
                            _StatBox(
                              icon: r.difficulty == 'Легко' ? Icons.sentiment_satisfied_rounded
                                  : r.difficulty == 'Средне' ? Icons.sentiment_neutral_rounded
                                  : Icons.sentiment_very_dissatisfied_rounded,
                              value: r.difficulty, unit: '',
                              color: r.difficulty == 'Легко' ? const Color(0xFF4CAF50)
                                  : r.difficulty == 'Средне' ? const Color(0xFFFFC107)
                                  : const Color(0xFFE53935),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Пересчёт порций
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
                          child: Row(
                            children: [
                              const Text('🍽️', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              const Text('Порций', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              const Spacer(),
                              _ServingBtn(icon: Icons.remove_rounded, onTap: () { if (_servings > 1) setState(() => _servings--); }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('$_servings', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                              ),
                              _ServingBtn(icon: Icons.add_rounded, onTap: () => setState(() => _servings++), filled: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Табы
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                      child: TabBar(
                        controller: _tabs,
                        indicator: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.grey,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        padding: const EdgeInsets.all(4),
                        tabs: const [
                          Tab(text: '🥕 Состав'),
                          Tab(text: '👨‍🍳 Шаги'),
                          Tab(text: '💡 Советы'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 480,
                    child: TabBarView(
                      controller: _tabs,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _IngredientsTab(recipe: r, multiplier: _mult),
                        _StepsTab(recipe: r),
                        _TipsTab(recipe: r),
                      ],
                    ),
                  ),

                  // Кнопка ШефАИ
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AiChatScreen(initialMessage: 'Расскажи подробнее о рецепте "${r.title}". Какие секреты приготовления?'),
                      )),
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('👨‍🍳', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 10),
                            Text('Спросить Шефа Максима', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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
}

// ── ВКЛАДКИ ──

class _IngredientsTab extends StatelessWidget {
  final Recipe recipe;
  final double multiplier;
  const _IngredientsTab({required this.recipe, required this.multiplier});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.ingredients.length,
      itemBuilder: (_, i) {
        final ing = recipe.ingredients[i];
        final rawAmt = double.tryParse(ing.amount.replaceAll(',', '.'));
        final displayAmt = rawAmt != null
            ? (rawAmt * multiplier == (rawAmt * multiplier).roundToDouble()
                ? (rawAmt * multiplier).toInt().toString()
                : (rawAmt * multiplier).toStringAsFixed(1))
            : ing.amount;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(ing.emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.dark))),
              Text('$displayAmt ${ing.unit}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primary)),
            ],
          ),
        ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _StepsTab extends StatelessWidget {
  final Recipe recipe;
  const _StepsTab({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.steps.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  ),
                  child: Text(recipe.steps[i], style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.dark)),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 70).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _TipsTab extends StatelessWidget {
  final Recipe recipe;
  const _TipsTab({required this.recipe});

  @override
  Widget build(BuildContext context) {
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
                border: Border.all(color: AppTheme.primary.withOpacity(0.25), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
              ),
              child: Text(recipe.tips!, style: const TextStyle(fontSize: 15, height: 1.65, color: AppTheme.dark)),
            ),
          const SizedBox(height: 14),
          // Теги
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🏷️ Теги', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: recipe.tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('#$t', style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ──

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final Color color;
  const _StatBox({required this.icon, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
            if (unit.isNotEmpty) Text(unit, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _ServingBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _ServingBtn({required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 18, color: filled ? Colors.white : AppTheme.dark),
      ),
    );
  }
}
