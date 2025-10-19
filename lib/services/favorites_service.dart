class FavoritesService {
  static final Set<String> _favorites = <String>{};

  static Set<String> get favorites => _favorites;

  static bool isFavorite(String providerId) {
    return _favorites.contains(providerId);
  }

  static void toggleFavorite(String providerId) {
    if (_favorites.contains(providerId)) {
      _favorites.remove(providerId);
    } else {
      _favorites.add(providerId);
    }
  }

  static void addFavorite(String providerId) {
    _favorites.add(providerId);
  }

  static void removeFavorite(String providerId) {
    _favorites.remove(providerId);
  }
}
