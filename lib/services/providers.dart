import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'real_auth_service.dart';
import 'real_api_client.dart';

/// Real auth service — talks to api-v8.volleyballlife.com
final authServiceProvider = Provider<RealAuthService>((ref) {
  return RealAuthService(baseUrl: () => 'https://api-v8.volleyballlife.com');
});

/// Real API client — authenticated requests against the VBL backend
final apiClientProvider = Provider<ApiClient>((ref) {
  final auth = ref.watch(authServiceProvider);
  return RealApiClient(auth);
});

/// Whether the user is currently authenticated.
final authStateProvider = Provider<bool>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.isAuthenticated;
});
