import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/bp_screen.dart';
import 'screens/caregiver/caregiver_dashboard_screen.dart';
import 'screens/caregiver/caregiver_unlock_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meds_screen.dart';
import 'screens/walk_screen.dart';
import 'screens/water_screen.dart';
import 'services/notification_service.dart';

const _validRoutes = {
  '/medisyne',
  '/bloeddruk',
  '/water',
  '/stap',
  '/versorger',
  '/versorger/dashboard',
};

bool _isValidRoute(String route) {
  final path = Uri.tryParse(route)?.path ?? route;
  return _validRoutes.contains(path);
}

/// Root navigator key — lets app-wide widgets (e.g. the update dialog) obtain a
/// context that sits under the Navigator, which `MaterialApp.router`'s builder
/// context does not.
final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  redirect: (context, state) {
    final pending = NotificationService.pendingRoute;
    if (pending != null) {
      NotificationService.pendingRoute = null;
      if (_isValidRoute(pending)) return pending;
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/medisyne',
      builder: (context, state) {
        final session = state.uri.queryParameters['session'] ?? 'morning';
        return MedsScreen(session: session);
      },
    ),
    GoRoute(path: '/bloeddruk', builder: (context, state) => const BpScreen()),
    GoRoute(path: '/water', builder: (context, state) => const WaterScreen()),
    GoRoute(path: '/stap', builder: (context, state) => const WalkScreen()),
    GoRoute(
      path: '/versorger',
      builder: (context, state) => const CaregiverUnlockScreen(),
    ),
    GoRoute(
      path: '/versorger/dashboard',
      builder: (context, state) => const CaregiverDashboardScreen(),
    ),
  ],
);
