import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_favorites_service.dart';

class FavoritesService {
  static final Set<String> _favorites = <String>{};

  static Set<String> get favorites => _favorites;

  static Future<void> initialize() async {
    try {
      _favorites
        ..clear()
        ..addAll(await FirebaseFavoritesService.loadFavorites());
    } catch (_) {
      // fallback silently - Firebase not configured
    }
  }

  static bool isFavorite(String providerId) {
    return _favorites.contains(providerId);
  }

  static Future<void> toggleFavorite(String providerId) async {
    if (_favorites.contains(providerId)) {
      _favorites.remove(providerId);
      try {
        await FirebaseFavoritesService.removeFavorite(providerId);
      } catch (_) {
        // Firebase not configured, continue with local only
      }
    } else {
      _favorites.add(providerId);
      try {
        await FirebaseFavoritesService.addFavorite(providerId);
      } catch (_) {
        // Firebase not configured, continue with local only
      }
    }
  }

  static Future<void> addFavorite(String providerId) async {
    _favorites.add(providerId);
    try {
      await FirebaseFavoritesService.addFavorite(providerId);
    } catch (_) {
      // Firebase not configured, continue with local only
    }
  }

  static Future<void> removeFavorite(String providerId) async {
    _favorites.remove(providerId);
    try {
      await FirebaseFavoritesService.removeFavorite(providerId);
    } catch (_) {
      // Firebase not configured, continue with local only
    }
  }
}
