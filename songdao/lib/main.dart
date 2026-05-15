import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'notifications/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await localNotificationService.initialize(
    onOpenRoute: (route) => rootNavigatorKey.currentContext?.go(route),
  );
  runApp(
    ProviderScope(
      overrides: [initialDeepLinkRouteProvider.overrideWithValue(initialRoute)],
      child: const SongDaoApp(),
    ),
  );
}
