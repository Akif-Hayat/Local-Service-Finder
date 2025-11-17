class AuthService {
  static bool _isLoggedIn = false;
  static String? _currentUser;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUser => _currentUser;

  static Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation - accept any email/password for demo
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _currentUser = email;
      return true;
    }
    return false;
  }

  static Future<bool> signup(String email, String password, String firstName, String lastName) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation - accept any valid input for demo
    if (email.isNotEmpty && password.isNotEmpty && firstName.isNotEmpty && lastName.isNotEmpty) {
      _isLoggedIn = true;
      _currentUser = email;
      return true;
    }
    return false;
  }

  static void logout() {
    _isLoggedIn = false;
    _currentUser = null;
  }
}
