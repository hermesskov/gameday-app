import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'auth_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => MockApiClient());
final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());

/// Whether the user is currently authenticated.
final authStateProvider = Provider<bool>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.isAuthenticated;
});
