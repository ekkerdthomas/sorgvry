import 'package:go_router/go_router.dart';

import 'screens/bp_screen.dart';
import 'screens/caregiver/caregiver_dashboard_screen.dart';
import 'screens/caregiver/caregiver_unlock_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meds_screen.dart';
import 'screens/walk_screen.dart';
import 'screens/water_screen.dart';

final router = GoRouter(
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
