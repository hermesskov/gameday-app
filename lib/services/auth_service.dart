/// Interface for the VBL auth service.
abstract class AuthService {
  /// Whether a valid session is currently stored.
  bool get isAuthenticated;

  /// The authenticated user's ID (null if not logged in).
  int? get userId;

  /// The authenticated user's display name (null if not logged in).
  String? get userName;

  /// Login with email/username and password.
  ///
  /// Calls POST /Account/Login on the VBL API.
  /// Returns true on success, false on invalid credentials.
  Future<bool> login(String email, String password);

  /// Clear the stored session.
  Future<void> logout();

  /// Try to restore a previously saved session (e.g. on app start).
  Future<void> restoreSession();

  /// Expose the auth token for the API client to use in Authorization headers.
  String? get authToken;

  /// Send a verification code to the user's email (optional fallback).
  Future<bool> sendCode(String email);

  /// Login with an email + verification code (optional fallback).
  Future<bool> loginWithCode(String email, String code);
}
