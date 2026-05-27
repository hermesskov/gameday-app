import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

/// Real auth service for volleyballlife.com.
///
/// Uses the VBL password-based login flow:
///   POST /Account/Login  → {userName, password} → {access_token, data}
///
/// The token is stored securely via flutter_secure_storage.
/// Tokens last 30 days, so re-auth is infrequent.
class RealAuthService implements AuthService {
  static const _tokenKey = 'vbl_session_token';
  static const _baseUrl =
      'https://api-v8.volleyballlife.com';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  String? _token;

  /// User info extracted from the login response's `data` payload.
  int? _userId;
  String? _userName;

  RealAuthService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  @override
  bool get isAuthenticated => _token != null;

  @override
  int? get userId => _userId;

  @override
  String? get userName => _userName;

  // ── PRIMARY: PASSWORD FLOW ──

  @override
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/Account/Login');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('RealAuthService.login failed: ${response.statusCode}');
        return false;
      }

      final data = jsonDecode(response.body);

      // VBL returns { access_token: "...", data: { ... } }
      _token = data['access_token'] as String?;

      // Extract user info from nested `data` object
      if (data['data'] != null) {
        final userData = data['data'] as Map<String, dynamic>;
        _userId = userData['userId'] as int? ?? userData['Id'] as int?;
        _userName = userData['userName'] as String? ??
            userData['UserName'] as String?;
      }

      if (_token != null) {
        await _storage.write(key: _tokenKey, value: _token);
        // Also persist whatever user info was extracted
        if (_userId != null) {
          await _storage.write(key: 'vbl_user_id', value: _userId.toString());
        }
        if (_userName != null) {
          await _storage.write(key: 'vbl_user_name', value: _userName);
        }
      }

      return _token != null;
    } catch (e) {
      debugPrint('RealAuthService.login failed: $e');
      return false;
    }
  }

  // ── FALLBACK: CODE FLOW ──

  @override
  Future<bool> sendCode(String email) async {
    final url = Uri.parse('$_baseUrl/Account/Code');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('RealAuthService.sendCode failed: $e');
      return false;
    }
  }

  @override
  Future<bool> loginWithCode(String email, String code) async {
    final url = Uri.parse('$_baseUrl/Account/Code-Login');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': email, 'password': code}),
      );

      if (response.statusCode != 200) return false;

      final result = jsonDecode(response.body);
      _token = result['access_token'] as String?;

      if (result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        _userId = userData['userId'] as int? ?? userData['Id'] as int?;
        _userName = userData['userName'] as String? ??
            userData['UserName'] as String?;
      }

      if (_token != null) {
        await _storage.write(key: _tokenKey, value: _token);
        if (_userId != null) {
          await _storage.write(key: 'vbl_user_id', value: _userId.toString());
        }
        if (_userName != null) {
          await _storage.write(key: 'vbl_user_name', value: _userName);
        }
      }

      return _token != null;
    } catch (e) {
      debugPrint('RealAuthService.loginWithCode failed: $e');
      return false;
    }
  }

  // ── SESSION MANAGEMENT ──

  @override
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: 'vbl_user_id');
    await _storage.delete(key: 'vbl_user_name');
  }

  @override
  Future<void> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      _token = token;
      final idStr = await _storage.read(key: 'vbl_user_id');
      _userId = idStr != null ? int.tryParse(idStr) : null;
      _userName = await _storage.read(key: 'vbl_user_name');
    }
  }

  @override
  String? get authToken => _token;
}
