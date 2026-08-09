import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scaffold_with_nav_bar.dart';
import '../features/today/today_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/calendar/user_event_editor_screen.dart';
import '../features/prayer/prayer_library_screen.dart';
import '../features/church_finder/church_search_screen.dart';
import '../features/progress/journal_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/readings/reading_source.dart';
import '../features/readings/reading_webview_screen.dart';
import '../features/settings/settings_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorTodayKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final shellNavigatorCalendarKey = GlobalKey<NavigatorState>(
  debugLabel: 'calendar',
);
final shellNavigatorPrayKey = GlobalKey<NavigatorState>(debugLabel: 'pray');
final shellNavigatorProgressKey = GlobalKey<NavigatorState>(
  debugLabel: 'progress',
);

final initialDeepLinkRouteProvider = Provider<String?>((ref) => null);

final routerProvider = Provider<GoRouter>((ref) {
  final initialRoute = ref.watch(initialDeepLinkRouteProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialRoute ?? '/today',
    redirect: (context, state) {
      if (state.uri.path.isEmpty || state.uri.path == '/') {
        return '/today';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/church',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChurchSearchScreen(),
      ),
      GoRoute(
        path: '/readings/web',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final source = ReadingSource.fromId(
            state.uri.queryParameters['source'],
          );
          return source == null ? '/today' : null;
        },
        builder: (context, state) {
          final source = ReadingSource.fromId(
            state.uri.queryParameters['source'],
          )!;
          final title = state.uri.queryParameters['title'] ?? 'Bài đọc';
          return ReadingWebViewScreen(source: source, title: title);
        },
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
                builder: (context, state) => CalendarScreen(
                  key: state.pageKey,
                  initialDate: _parseCalendarDate(
                    state.uri.queryParameters['date'],
                  ),
                  focusedEventId: int.tryParse(
                    state.uri.queryParameters['eventId'] ?? '',
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'events/new',
                    builder: (context, state) => UserEventEditorScreen(
                      initialDate:
                          _parseCalendarDate(
                            state.uri.queryParameters['date'],
                          ) ??
                          DateTime.now(),
                    ),
                  ),
                  GoRoute(
                    path: 'events/:eventId/edit',
                    redirect: (context, state) {
                      return int.tryParse(
                                state.pathParameters['eventId'] ?? '',
                              ) ==
                              null
                          ? '/calendar'
                          : null;
                    },
                    builder: (context, state) => UserEventEditorScreen(
                      eventId: int.parse(state.pathParameters['eventId']!),
                      initialDate: DateTime.now(),
                    ),
                  ),
                ],
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
            navigatorKey: shellNavigatorProgressKey,
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
                routes: [
                  GoRoute(
                    path: 'journal',
                    builder: (context, state) => const JournalScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

DateTime? _parseCalendarDate(String? value) {
  if (value == null) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || value != parsed.toIso8601String().substring(0, 10)) {
    return null;
  }
  return DateTime(parsed.year, parsed.month, parsed.day);
}
