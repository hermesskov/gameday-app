import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:gameday_app/services/real_auth_service.dart';

/// An HTTP client that returns controlled responses (no real network calls).
class _MockHttpClient extends http.BaseClient {
  final Map<String, http.Response> _responses = {};
  int callCount = 0;

  void enqueue(String url, http.Response response) {
    _responses[url] = response;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    callCount++;
    final url = request.url.toString();
    final response = _responses[url];
    if (response != null) {
      return Future.value(http.StreamedResponse(
        http.ByteStream.fromBytes(response.bodyBytes),
        response.statusCode,
        headers: response.headers,
      ));
    }
    // Default: 401 for anything unregistered
    return Future.value(http.StreamedResponse(
      http.ByteStream.fromBytes([]),
      401,
    ));
  }
}

void main() {
  late _MockHttpClient mockClient;
  late RealAuthService auth;

  setUp(() {
    mockClient = _MockHttpClient();
    auth = RealAuthService(client: mockClient);
  });

  test('starts unauthenticated', () {
    expect(auth.isAuthenticated, false);
    expect(auth.userId, isNull);
    expect(auth.userName, isNull);
  });

  test('login returns true on 200 with access_token', () async {
    mockClient.enqueue(
      'https://api-v8.volleyballlife.com/Account/Login',
      http.Response(
        '{"access_token":"test-token-123","data":{"userId":98765,"userName":"Karissa Cook"}}',
        200,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final result = await auth.login('test@example.com', 'password123');

    expect(result, true);
    expect(auth.isAuthenticated, true);
    expect(auth.userId, 98765);
    expect(auth.userName, 'Karissa Cook');
  });

  test('login returns false on 401', () async {
    mockClient.enqueue(
      'https://api-v8.volleyballlife.com/Account/Login',
      http.Response('{"error":"invalid_credentials"}', 401,
          headers: {'Content-Type': 'application/json'}),
    );

    final result = await auth.login('test@example.com', 'wrong');

    expect(result, false);
    expect(auth.isAuthenticated, false);
  });

  test('logout clears session', () async {
    mockClient.enqueue(
      'https://api-v8.volleyballlife.com/Account/Login',
      http.Response(
        '{"access_token":"test-token","data":{"userId":1,"userName":"Test"}}',
        200,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    await auth.login('test@example.com', 'pass');
    expect(auth.isAuthenticated, true);

    await auth.logout();
    expect(auth.isAuthenticated, false);
    expect(auth.userId, isNull);
    expect(auth.userName, isNull);
  });

  test('authToken returns the stored token after login', () async {
    mockClient.enqueue(
      'https://api-v8.volleyballlife.com/Account/Login',
      http.Response(
        '{"access_token":"token-456","data":{"userId":1,"userName":"Test"}}',
        200,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    await auth.login('test@example.com', 'pass');
    expect(auth.authToken, 'token-456');
  });
}
