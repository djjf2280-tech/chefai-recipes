import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  Set<String> _favorites = {};
  bool _isLoaded = false;

  Set<String> get favorites => Set.unmodifiable(_favorites);
  bool get isLoaded => _isLoaded;

  FavoritesService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites') ?? [];
    _favorites = list.toSet();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggle(String recipeId) async {
    if (_favorites.contains(recipeId)) {
      _favorites.remove(recipeId);
    } else {
      _favorites.add(recipeId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }

  bool isFavorite(String recipeId) => _favorites.contains(recipeId);
}
