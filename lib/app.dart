import 'package:flutter/material.dart';
import 'theme/vuetify_theme.dart';
import 'package:go_router/go_router.dart';
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
  initialLocation: '/dashboard',
  routes: [
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
  ],
);
