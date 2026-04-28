import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scaffold_with_nav_bar.dart';
import '../features/today/today_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/prayer/prayer_library_screen.dart';
import '../features/church_finder/church_search_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/settings_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorTodayKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final shellNavigatorCalendarKey = GlobalKey<NavigatorState>(
  debugLabel: 'calendar',
);
final shellNavigatorPrayKey = GlobalKey<NavigatorState>(debugLabel: 'pray');
final shellNavigatorChurchKey = GlobalKey<NavigatorState>(debugLabel: 'church');
final shellNavigatorProgressKey = GlobalKey<NavigatorState>(
  debugLabel: 'progress',
);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/today',
    routes: [
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorTodayKey,
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorCalendarKey,
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorPrayKey,
            routes: [
              GoRoute(
                path: '/pray',
                builder: (context, state) => const PrayerLibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorChurchKey,
            routes: [
              GoRoute(
                path: '/church',
                builder: (context, state) => const ChurchSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorProgressKey,
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
