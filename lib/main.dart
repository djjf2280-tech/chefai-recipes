import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/ai_service.dart';
import 'services/favorites_service.dart';
import 'data/recipes_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const RecipeAIApp());
}

class RecipeAIApp extends StatelessWidget {
  const RecipeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AiService()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => RecipesData()),
      ],
      child: MaterialApp(
        title: 'ChefAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}

class AppTheme {
  static const Color primary    = Color(0xFFFF6B35);
  static const Color secondary  = Color(0xFFFF9F1C);
  static const Color dark       = Color(0xFF1C1C1E);
  static const Color grey       = Color(0xFF8E8E93);
  static const Color lightGrey  = Color(0xFFF2F2F7);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color bg         = Color(0xFFF8F8FA);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: bg,
  );
}
