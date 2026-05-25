import '../models/team.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cookie-based session auth. Real implementation calls POST to
/// volleyballlife.com auth endpoint and stores the session cookie.
abstract class AuthService {
  bool get isAuthenticated;
  int? get userId;
  String? get userName;
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<void> restoreSession();
}

class MockAuthService implements AuthService {
  static const _userIdKey = 'mock_user_id';
  static const _userNameKey = 'mock_user_name';

  @override
  bool isAuthenticated = false;

  @override
  int? userId;

  @override
  String? userName;

  @override
  Future<bool> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation — accepts any non-empty email/password
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    isAuthenticated = true;
    userId = 98765;
    userName = 'Karissa Cook';

    // Persist mock session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId!);
    await prefs.setString(_userNameKey, userName!);

    return true;
  }

  @override
  Future<void> logout() async {
    isAuthenticated = false;
    userId = null;
    userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
  }

  @override
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getInt(_userIdKey);
    final storedName = prefs.getString(_userNameKey);

    if (storedId != null && storedName != null) {
      isAuthenticated = true;
      userId = storedId;
      userName = storedName;
    }
  }
}
