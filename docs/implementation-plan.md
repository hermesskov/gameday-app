# Gameday App — Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Build a cross-platform (Android + iOS) gameday experience app for volleyballlife.com, matching the Vuetify/Material Design look.

**Architecture:** Flutter app with Riverpod state management, talking to the existing volleyballlife.com REST API for auth, event data, scoring, and push notifications. API endpoints will be wired up later when the backend team exposes them — the app uses service abstractions with mock implementations initially.

**Tech Stack:** Flutter 3.x, Dart, Riverpod, GoRouter, Material 3 theming (Vuetify match)

**Constraints:** Auth + notifications come from the main site's backend (not Firebase). API client built with dependency injection so real endpoints replace mocks without refactoring.

---

## Task 1: Install Flutter + Scaffold Project with Vuetify Theme

**Objective:** Get Flutter installed, project created, Material 3 theme configured to match Vuetify color palette.

**Files:**
- Create: `pubspec.yaml`, `lib/main.dart`, `lib/app.dart`, `lib/theme/vuetify_theme.dart`

**Step 1: Install Flutter SDK**

```bash
# Install via snap (Ubuntu)
sudo snap install flutter --classic
flutter config --no-analytics
flutter doctor
```

Expected: `flutter doctor` shows no critical errors.

**Step 2: Create Flutter project**

```bash
cd ~/Projects/gameday-app
flutter create --org com.volleyballlife --project-name gameday_app .
```

**Step 3: Add dependencies to pubspec.yaml**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0
  google_fonts: ^6.2.1
  shared_preferences: ^2.3.2
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  json_serializable: ^6.8.0
  build_runner: ^2.4.12
  riverpod_generator: ^2.4.0
  mocktail: ^1.0.4
```

Run: `flutter pub get`

**Step 4: Create Vuetify theme**

File: `lib/theme/vuetify_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VuetifyTheme {
  // Primary — matches Vuetify's default blue
  static const primary = Color(0xFF1976D2);
  static const primaryDark = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF42A5F5);

  // Accent
  static const accent = Color(0xFF82B1FF);
  static const error = Color(0xFFFF5252);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);

  // Surface / background
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F5F5);
  static const cardShadow = Color(0x1A000000);

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.robotoTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
        error: error,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}
```

**Step 5: Create app entry point with theme**

File: `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'theme/vuetify_theme.dart';

class GamedayApp extends StatelessWidget {
  const GamedayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VBL Gameday',
      theme: VuetifyTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Routes added in later tasks
  ],
);
```

File: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const GamedayApp());
}
```

**Step 6: Verify it builds**

```bash
flutter run -d chrome  # quickest way to test
```

Expected: App launches in Chrome with blue AppBar and Material 3 theme.

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: scaffold Flutter project with Vuetify theme"
```

---

## Task 2: Data Models

**Objective:** Create Dart data models for Event, Match, Bracket, User with JSON serialization.

**Files:**
- Create: `lib/models/event.dart`, `lib/models/match.dart`, `lib/models/bracket.dart`, `lib/models/user.dart`
- Create: `test/models/event_test.dart`, `test/models/match_test.dart`

**Step 1: Write User model test**

```dart
// test/models/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gameday_app/models/user.dart';

void main() {
  group('User', () {
    test('fromJson creates User with required fields', () {
      final json = {
        'id': 'usr_123',
        'email': 'player@example.com',
        'name': 'Karissa Cook',
      };
      final user = User.fromJson(json);
      expect(user.id, 'usr_123');
      expect(user.email, 'player@example.com');
      expect(user.name, 'Karissa Cook');
    });
  });
}
```

**Step 2: Write User model**

File: `lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

Run: `dart run build_runner build`

**Step 3: Write Event model**

File: `lib/models/event.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
part 'event.g.dart';

@JsonSerializable()
class Event {
  final String id;
  final String name;
  final DateTime startDate;
  final String location;

  const Event({
    required this.id,
    required this.name,
    required this.startDate,
    required this.location,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
```

**Step 4: Write Match model**

File: `lib/models/match.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
part 'match.g.dart';

@JsonSerializable()
class Match {
  final String id;
  final String eventId;
  final String division;
  final int pool;
  final int? court;
  final String teamA;
  final String teamB;
  final int? scoreA;
  final int? scoreB;
  final String status; // upcoming, live, completed
  final DateTime? scheduledTime;

  const Match({
    required this.id,
    required this.eventId,
    required this.division,
    required this.pool,
    this.court,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
    required this.status,
    this.scheduledTime,
  });

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);
}
```

**Step 5: Write Bracket model**

File: `lib/models/bracket.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import 'match.dart';
part 'bracket.g.dart';

@JsonSerializable()
class Bracket {
  final String id;
  final String eventId;
  final String division;
  final List<Match> matches;

  const Bracket({
    required this.id,
    required this.eventId,
    required this.division,
    required this.matches,
  });

  factory Bracket.fromJson(Map<String, dynamic> json) =>
      _$BracketFromJson(json);
  Map<String, dynamic> toJson() => _$BracketToJson(this);
}
```

**Step 6: Run build_runner + tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test
```

Expected: All model tests pass. JSON serialization works.

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: add data models with JSON serialization"
```

---

## Task 3: API Client + Auth Service (Backend Placeholders)

**Objective:** Create service layer that abstracts the backend API. Initially use mock implementations. Real endpoints slot in later.

**Files:**
- Create: `lib/services/api_client.dart`, `lib/services/auth_service.dart`
- Create: `test/services/api_client_test.dart`, `test/services/auth_service_test.dart`

**Step 1: Write abstract API client**

File: `lib/services/api_client.dart`

```dart
import '../models/event.dart';
import '../models/match.dart';
import '../models/bracket.dart';

/// Abstract API client. Real implementation hits volleyballlife.com REST API.
/// Mock implementation returns test data for development.
abstract class ApiClient {
  Future<List<Event>> getUserEvents(String userId);
  Future<List<Match>> getEventMatches(String eventId);
  Future<Bracket> getBracket(String eventId, String division);
  Future<void> submitScore(String matchId, int scoreA, int scoreB);
  Future<void> checkIn(String eventId, String userId);
}
```

**Step 2: Write mock API client for development**

```dart
// In same file, or lib/services/mock_api_client.dart
import '../models/event.dart';
import '../models/match.dart';
import '../models/bracket.dart';
import 'api_client.dart';

class MockApiClient implements ApiClient {
  @override
  Future<List<Event>> getUserEvents(String userId) async {
    return [
      Event(
        id: 'evt_1',
        name: 'AVP Santa Cruz',
        startDate: DateTime(2026, 5, 31),
        location: 'Main Beach',
      ),
      Event(
        id: 'evt_2',
        name: 'CBVA Manhattan Beach',
        startDate: DateTime(2026, 6, 7),
        location: 'Manhattan Beach Pier',
      ),
    ];
  }

  @override
  Future<List<Match>> getEventMatches(String eventId) async {
    return [
      Match(
        id: 'm_1',
        eventId: eventId,
        division: 'Women\'s Open',
        pool: 4,
        court: 7,
        teamA: 'Cook/Martinez',
        teamB: 'Thompson/Reed',
        status: 'upcoming',
        scheduledTime: DateTime(2026, 5, 31, 8, 30),
      ),
    ];
  }

  @override
  Future<Bracket> getBracket(String eventId, String division) async {
    return Bracket(id: 'brk_1', eventId: eventId, division: division, matches: []);
  }

  @override
  Future<void> submitScore(String matchId, int scoreA, int scoreB) async {
    // TODO: POST to /api/scores
  }

  @override
  Future<void> checkIn(String eventId, String userId) async {
    // TODO: POST to /api/checkin
  }
}
```

**Step 3: Write auth service**

File: `lib/services/auth_service.dart`

```dart
import '../models/user.dart';

abstract class AuthService {
  User? get currentUser;
  Future<User?> login(String email, String password);
  Future<void> logout();
}

class MockAuthService implements AuthService {
  @override
  User? currentUser;

  @override
  Future<User?> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    currentUser = User(id: 'usr_1', email: email, name: 'Karissa Cook');
    return currentUser;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }
}
```

**Step 4: Write Riverpod providers**

File: `lib/services/providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'auth_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => MockApiClient());
final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());
```

**Step 5: Write tests verifying mocks return expected data**

```bash
flutter test test/services/
```

Expected: Tests pass, mock data returned correctly.

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add API client and auth service with mock implementations"
```

---

## Task 4: Login Screen

**Objective:** Build a login screen that matches Vuetify style.

**Files:**
- Create: `lib/screens/login_screen.dart`
- Modify: `lib/app.dart` (add route)

**Step 1: Write the screen**

File: `lib/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.login(_emailController.text, _passwordController.text);
      if (mounted) {
        // Navigate to dashboard — router handles this in Task 5
      }
    } catch (e) {
      setState(() => _error = 'Login failed. Check your credentials.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / branding
                Icon(Icons.sports_volleyball, size: 64,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text('VBL Gameday',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Sign in to your Volleyball Life account',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600])),
                const SizedBox(height: 32),

                // Email field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Error message
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_error!, style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
                  ),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('SIGN IN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

**Step 2: Register route**

In `lib/app.dart`, update the router:

```dart
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
```

**Step 3: Verify**

```bash
flutter run -d chrome
```

Expected: Login screen with email/password fields, styled in Vuetify theme.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: add login screen with Vuetify theme styling"
```

---

## Task 5: Event Dashboard Screen

**Objective:** The main gameday hub — shows next match, check-in button, bracket link, watchlist.

**Files:**
- Create: `lib/screens/event_dashboard.dart`, `lib/widgets/match_card.dart`
- Modify: `lib/app.dart`

**Step 1: Build MatchCard widget**

File: `lib/widgets/match_card.dart`

```dart
import 'package:flutter/material.dart';
import '../models/match.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = match.status == 'live'
        ? Colors.red
        : match.status == 'completed'
            ? Colors.grey[600]
            : Theme.of(context).colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status + court
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(match.status.toUpperCase(),
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.bold, color: color)),
                  ),
                  const Spacer(),
                  if (match.court != null)
                    Text('Court ${match.court}',
                        style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 12),

              // Teams
              Row(
                children: [
                  Expanded(child: Text(match.teamA,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  if (match.scoreA != null)
                    Text('${match.scoreA}', style: const TextStyle(fontSize: 24,
                        fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('vs', style: TextStyle(color: Colors.grey)),
                  ),
                  if (match.scoreB != null)
                    Text('${match.scoreB}', style: const TextStyle(fontSize: 24,
                        fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(match.teamB, textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Time
              if (match.scheduledTime != null)
                Text(_formatTime(match.scheduledTime!),
                    style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour}:${time.minute.toString().padLeft(2, '0')} $amPm';
  }
}
```

**Step 2: Build Event Dashboard**

File: `lib/screens/event_dashboard.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match.dart';
import '../widgets/match_card.dart';

class EventDashboard extends ConsumerWidget {
  const EventDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder data — wired to API in later iteration
    final nextMatch = Match(
      id: 'm_1', eventId: 'evt_1', division: 'Women\'s Open',
      pool: 4, court: 7, teamA: 'Cook/Martinez',
      teamB: 'Thompson/Reed', status: 'upcoming',
      scheduledTime: DateTime(2026, 5, 31, 8, 30),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('AVP Santa Cruz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Check-in card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check In', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('Confirm your presence for today',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: call apiClient.checkIn()
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Checked in!')),
                      );
                    },
                    child: const Text('CHECK IN'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Next match
          const Text('Your Next Match',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          MatchCard(match: nextMatch, onTap: () {
            // Navigate to live score
          }),

          const SizedBox(height: 24),

          // Quick links
          const Text('Quick Links',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _QuickLinkCard(
            icon: Icons.account_tree,
            title: 'Bracket',
            subtitle: 'View full tournament bracket',
            onTap: () {},
          ),
          _QuickLinkCard(
            icon: Icons.favorite_border,
            title: 'Watchlist',
            subtitle: 'Bookmarked matches and teams',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon, required this.title,
    required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

**Step 3: Register route + verify**

Add `/dashboard` route to `lib/app.dart`, run `flutter run -d chrome`.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: add event dashboard with match card widget"
```

---

## Task 6: Live Score Screen

**Objective:** One-tap scoring optimized for on-court use. Big targets, undo button.

**Files:**
- Create: `lib/screens/live_score.dart`
- Modify: `lib/app.dart`

```dart
// lib/screens/live_score.dart
import 'package:flutter/material.dart';

class LiveScoreScreen extends StatefulWidget {
  final String teamA;
  final String teamB;

  const LiveScoreScreen({
    super.key,
    required this.teamA,
    required this.teamB,
  });

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  int _scoreA = 0;
  int _scoreB = 0;
  final List<Map<String, int>> _history = [];

  void _addPoint(String team) {
    setState(() {
      _history.add({'scoreA': _scoreA, 'scoreB': _scoreB});
      if (team == 'A') _scoreA++; else _scoreB++;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final prev = _history.removeLast();
      _scoreA = prev['scoreA']!;
      _scoreB = prev['scoreB']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teamA} vs ${widget.teamB}'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Submit scores via API
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Team A — tap to score
                Expanded(
                  child: GestureDetector(
                    onTap: () => _addPoint('A'),
                    child: Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      child: Center(
                        child: Text('$_scoreA',
                            style: const TextStyle(fontSize: 96,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                Container(width: 2, color: Colors.grey[300]),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _addPoint('B'),
                    child: Container(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                      child: Center(
                        child: Text('$_scoreB',
                            style: const TextStyle(fontSize: 96,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Team names at bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Text(widget.teamA,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18))),
                const SizedBox(width: 16),
                Expanded(child: Text(widget.teamB,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Commit:** `feat: add live score screen with undo and submit`

---

## Task 7: Bracket View Screen

**Objective:** Tournament bracket view with current user's path highlighted.

**Files:**
- Create: `lib/screens/bracket_view.dart`

(Basic bracket scaffold — real data wiring in later task)

```dart
// lib/screens/bracket_view.dart
import 'package:flutter/material.dart';

class BracketView extends StatelessWidget {
  const BracketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournament Bracket')),
      body: const Center(
        child: Text('Bracket will display here.\nWire to API data in future iteration.'),
      ),
    );
  }
}
```

**Commit:** `feat: add bracket view scaffold`

---

## Task 8: Watchlist + Notification Service

**Objective:** Screen showing bookmarked matches/divisions + notification service scaffold.

**Files:**
- Create: `lib/screens/watchlist.dart`, `lib/services/notification_service.dart`

Notification service (placeholder for backend):

```dart
// lib/services/notification_service.dart
abstract class NotificationService {
  Future<void> initialize();
  Future<void> watchDivision(String eventId, String division);
  Future<void> watchTeam(String eventId, String teamName);
}

class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> watchDivision(String eventId, String division) async {}
  @override
  Future<void> watchTeam(String eventId, String teamName) async {}
}
```

**Commit:** `feat: add watchlist screen and notification service`

---

## Task 9: Integration Tests + GitHub CI/CD

**Objective:** Full gameday flow test + GitHub Actions to build on push.

**Files:**
- Create: `.github/workflows/flutter-ci.yml`
- Create: `integration_test/gameday_flow_test.dart`

**CI workflow:**

```yaml
name: Flutter CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --debug
```

**Commit:** `feat: add integration tests and CI pipeline`

---

## Task 10: Wire to Real Backend

**Objective:** After backend team exposes endpoints, replace mock implementations with real HTTP calls.

**Files:**
- Modify: `lib/services/auth_service.dart`, `lib/services/api_client.dart`, `lib/services/notification_service.dart`

Swap `MockAuthService` → `RealAuthService` (calls `/api/auth/login`).  
Swap `MockApiClient` → `RealApiClient` (calls `/api/events`, `/api/matches`, `/api/scores`).  
Swap `MockNotificationService` → `RealNotificationService` (registers device token, calls `/api/notifications/subscribe`).

---

## Execution Order

Tasks 1-3 must run sequentially (dependencies). Tasks 4-8 can run in parallel after Task 3. Task 9 runs after all screens exist. Task 10 is last and requires backend readiness.

```
1 → 2 → 3 → [4, 5, 6, 7, 8] → 9 → 10
```

---

## What We're NOT Building Yet

- Push notifications (backend-dependent, Task 10)
- Real auth flow (mock login → Task 10)
- Live scoring API integration (mock submit → Task 10)
- Bracket rendering with real data
- Offline support
- iOS build signing (needs Apple Developer account)
