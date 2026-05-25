import 'package:flutter/material.dart';
import 'theme/vuetify_theme.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/event_dashboard.dart';

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
  ],
);
