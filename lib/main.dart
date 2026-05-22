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
  static const Color dark       = Color(0xFF1A1A2E);
  static const Color bg         = Color(0xFFF7F3EF);
  static const Color card       = Color(0xFFFFFFFF);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, secondary: secondary),
    textTheme: GoogleFonts.poppinsTextTheme(),
    scaffoldBackgroundColor: bg,
  );
}
