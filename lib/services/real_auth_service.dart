import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

/// Real auth service for volleyballlife.com.
///
/// Uses the VBL code-based auth flow:
///   1. POST /account/code  → sends verification code to email
///   2. POST /account/code-login  → exchanges code for session token
///
/// The token is stored securely via flutter_secure_storage.
class RealAuthService implements AuthService {
  static const _tokenKey = 'vbl_session_token';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  String? _token;
  int? _userId;
  String? _userName;

  RealAuthService({
    required String? Function() baseUrl,
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  /// Not authenticated while not logged in.
  /// The mock returned true immediately — real checks token presence.
  @override
  bool get isAuthenticated => _token != null || _storedToken != null;

  String? _storedToken;

  @override
  int? get userId => _userId;

  @override
  String? get userName => _userName;

  // ---- CODE FLOW ----

  /// Send a verification code to [email], returns success.
  Future<bool> sendCode(String email) async {
    final url = Uri.parse('https://api-v8.volleyballlife.com/account/code');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return response.statusCode == 200;
  }

  /// Login with a verification [code] previously sent to [email].
  @override
  Future<bool> login(String email, String code) async {
    final url =
        Uri.parse('https://api-v8.volleyballlife.com/account/code-login');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _token = data['token'] as String? ?? data['access_token'] as String?;
      _userId = data['userId'] as int? ?? data['user_id'] as int?;
      _userName = data['userName'] as String? ?? data['name'] as String?;

      if (_token != null) {
        await _storage.write(key: _tokenKey, value: _token);
        _storedToken = _token;
      }

      return _token != null;
    } catch (e) {
      debugPrint('RealAuthService.login failed: $e');
      return false;
    }
  }

  /// Legacy email/password fallback (if VBL API supports it).
  Future<bool> loginWithPassword(String email, String password) async {
    final url = Uri.parse('https://api-v8.volleyballlife.com/account/login');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      _token = data['token'] as String? ?? data['access_token'] as String?;
      _userId = data['userId'] as int?;
      _userName = data['userName'] as String?;

      if (_token != null) {
        await _storage.write(key: _tokenKey, value: _token);
        _storedToken = _token;
      }
      return _token != null;
    } catch (e) {
      debugPrint('RealAuthService.loginWithPassword failed: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    _token = null;
    _storedToken = null;
    _userId = null;
    _userName = null;
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<void> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      _storedToken = token;
      _token = token;
      // Optionally validate token with a ping to /account/ping
      // For now we trust the stored token.
    }
  }

  /// Expose the auth token for the API client to use in Authorization headers.
  String? get authToken => _token ?? _storedToken;
}
