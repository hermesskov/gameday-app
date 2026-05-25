import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gameday_app/services/auth_service.dart';

void main() {
  late MockAuthService auth;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    auth = MockAuthService();
  });

  test('starts unauthenticated', () {
    expect(auth.isAuthenticated, false);
    expect(auth.userId, isNull);
    expect(auth.userName, isNull);
  });

  test('login with valid credentials returns true and sets user', () async {
    final result = await auth.login('test@example.com', 'password123');

    expect(result, true);
    expect(auth.isAuthenticated, true);
    expect(auth.userId, 98765);
    expect(auth.userName, 'Karissa Cook');
  });

  test('login with empty email returns false', () async {
    final result = await auth.login('', 'password123');

    expect(result, false);
    expect(auth.isAuthenticated, false);
  });

  test('login with empty password returns false', () async {
    final result = await auth.login('test@example.com', '');

    expect(result, false);
    expect(auth.isAuthenticated, false);
  });

  test('logout clears session', () async {
    await auth.login('test@example.com', 'password123');
    expect(auth.isAuthenticated, true);

    await auth.logout();

    expect(auth.isAuthenticated, false);
    expect(auth.userId, isNull);
    expect(auth.userName, isNull);
  });

  test('restoreSession with no stored data leaves unauthenticated', () async {
    await auth.restoreSession();

    expect(auth.isAuthenticated, false);
  });

  test('login then logout then login again works', () async {
    await auth.login('test@example.com', 'password123');
    expect(auth.isAuthenticated, true);

    await auth.logout();
    expect(auth.isAuthenticated, false);

    final result = await auth.login('other@example.com', 'newpass');
    expect(result, true);
    expect(auth.isAuthenticated, true);
    expect(auth.userId, 98765);
  });
}
