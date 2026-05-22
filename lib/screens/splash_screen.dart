import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C), Color(0xFFFFBF69)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Логотип
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: const Center(child: Text('👨‍🍳', style: TextStyle(fontSize: 58))),
                )
                    .animate()
                    .scale(delay: 200.ms, duration: 700.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 28),

                const Text('ChefAI', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1))
                    .animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 6),

                Text('Рецепты & Шеф Максим', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 17, fontWeight: FontWeight.w400))
                    .animate().fadeIn(delay: 700.ms, duration: 500.ms),

                const SizedBox(height: 70),

                SizedBox(
                  width: 36, height: 36,
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.7)), strokeWidth: 3),
                ).animate().fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
