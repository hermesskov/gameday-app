import 'package:flutter/material.dart';
import 'theme/vuetify_theme.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/event_dashboard.dart';
import 'screens/live_score.dart';
import 'screens/bracket_view.dart';
import 'models/schedule_event.dart';

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
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const EventDashboard(),
    ),
    GoRoute(
      path: '/live-score',
      builder: (context, state) {
        final event = state.extra as ScheduleEvent;
        return LiveScoreScreen(event: event);
      },
    ),
    GoRoute(
      path: '/bracket',
      builder: (context, state) => const BracketView(),
    ),
    GoRoute(
      path: '/watchlist',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Scaffold(
          appBar: AppBar(title: const Text('Watchlist')),
          body: const Center(
            child: Text('Watchlist — coming in Task 8'),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    ),
  ],
);
