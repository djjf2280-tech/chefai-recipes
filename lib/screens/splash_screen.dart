import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFFF9F1C),
              Color(0xFFFFBF69),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '👨‍🍳',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    delay: 200.ms,
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              const Text(
                'ChefAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              Text(
                'Рецепты & AI-помощник',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 60),

              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.7),
                  ),
                  strokeWidth: 3,
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
