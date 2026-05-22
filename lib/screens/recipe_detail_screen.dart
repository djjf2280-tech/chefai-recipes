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
      body: CustomScrollView(slivers: [
        // Hero фото
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: r.categoryColor,
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
              onTap: () => context.read<FavoritesService>().toggle(r.id),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFav ? Colors.red.withOpacity(0.9) : Colors.black38,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              Image.asset(r.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(gradient: LinearGradient(
                      colors: [r.categoryColor.withOpacity(0.7), r.categoryColor],
                    )),
                    child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 100))),
                  )),
              DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.55)],
                ),
              )),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: Container(
          decoration: const BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          margin: const EdgeInsets.only(top: -24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Теги категории и кухни
                Row(children: [
                  _badge(r.category, r.categoryColor.withOpacity(0.15), r.categoryColor),
                  const SizedBox(width: 8),
                  if (r.cuisine.isNotEmpty) _badge(r.cuisine, r.cuisineColor.withOpacity(0.12), r.cuisineColor),
                  const SizedBox(width: 8),
                  _badge(r.difficulty, r.difficultyColor.withOpacity(0.1), r.difficultyColor),
                ]),
                const SizedBox(height: 12),
                Text(r.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.dark, height: 1.15, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text(r.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
                const SizedBox(height: 18),
                // Статы
                Row(children: [
                  _stat('⏱', '${r.totalTime}', 'мин', const Color(0xFF2196F3)),
                  const SizedBox(width: 10),
                  _stat('🔥', '${r.calories}', 'ккал', AppTheme.primary),
                  const SizedBox(width: 10),
                  _stat('👥', '${r.servings}', 'порц.', const Color(0xFF9C27B0)),
                  const SizedBox(width: 10),
                  _stat('📋', '${r.ingredients.length}', 'ингр.', const Color(0xFF009688)),
                ]),
                const SizedBox(height: 14),
                // Пересчёт порций
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Text('🍽️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    const Text('Порций', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () { if (_servings > 1) setState(() => _servings--); },
                      child: Container(width: 34, height: 34,
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(11)),
                          child: const Icon(Icons.remove_rounded, size: 18)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_servings', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _servings++),
                      child: Container(width: 34, height: 34,
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(11)),
                          child: const Icon(Icons.add_rounded, size: 18, color: Colors.white)),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
              ]),
            ),

            // Табы
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(color: AppTheme.dark, borderRadius: BorderRadius.circular(14)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  dividerColor: Colors.transparent,
                  tabs: const [Tab(text: '🥕 Состав'), Tab(text: '👨‍🍳 Шаги'), Tab(text: '💡 Советы')],
                ),
              ),
            ),

            SizedBox(height: 420, child: TabBarView(
              controller: _tabs,
              children: [_ingredients(r), _steps(r), _tips(r)],
            )),

            // Кнопка ИИ
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AiChatScreen(
                    initialMessage: 'Расскажи секреты рецепта "${r.title}". Какие лайфхаки есть?',
                  ),
                )),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.dark, Color(0xFF16213E)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppTheme.dark.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('✨', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Text('Спросить Шефа Максима', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ]),
                ),
              ),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 11)),
  );

  Widget _stat(String icon, String val, String label, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 2),
      Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
      Text(label, style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
    ]),
  ));

  Widget _ingredients(Recipe r) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: r.ingredients.length,
    itemBuilder: (_, i) {
      final ing = r.ingredients[i];
      final amt = _multAmt(ing.amount, _mult);
      return Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: r.categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(ing.emoji ?? '🥄', style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.dark))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: r.categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('$amt ${ing.unit}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: r.categoryColor)),
          ),
        ]),
      ).animate().fadeIn(delay: (i * 40).ms).slideX(begin: 0.05, end: 0);
    },
  );

  Widget _steps(Recipe r) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: r.steps.length,
    itemBuilder: (_, i) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('${i+1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)))),
        const SizedBox(width: 12),
        Expanded(child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
          child: Text(r.steps[i], style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppTheme.dark)),
        )),
      ]),
    ).animate().fadeIn(delay: (i * 60).ms),
  );

  Widget _tips(Recipe r) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    physics: const NeverScrollableScrollPhysics(),
    child: Column(children: [
      if (r.tips != null)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
          ),
          child: Text(r.tips!, style: const TextStyle(fontSize: 14.5, height: 1.6, color: AppTheme.dark)),
        ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🏷️ Теги', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: r.tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: r.categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('#$t', style: TextStyle(color: r.categoryColor, fontSize: 12, fontWeight: FontWeight.w700)),
          )).toList()),
        ]),
      ),
    ]),
  );

  String _multAmt(String amount, double mult) {
    if (mult == 1.0) return amount;
    final n = double.tryParse(amount.replaceAll(',', '.'));
    if (n == null) return amount;
    final res = n * mult;
    return res == res.roundToDouble() ? res.toInt().toString() : res.toStringAsFixed(1);
  }
}
