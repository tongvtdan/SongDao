import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songdao/l10n/app_localizations.dart';
import 'package:songdao/features/today/today_controller.dart';

import '../data/content/content_pack_provider.dart';
import '../data/local/database_provider.dart';
import 'theme.dart';
import 'router.dart';

class SongDaoApp extends ConsumerStatefulWidget {
  const SongDaoApp({super.key});

  @override
  ConsumerState<SongDaoApp> createState() => _SongDaoAppState();
}

class _SongDaoAppState extends ConsumerState<SongDaoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(dailyReminderServiceProvider).refreshScheduledReminders(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    ref.listen(seedContentBootstrapProvider, (_, next) {
      next.whenData((_) {
        unawaited(
          ref.read(dailyReminderServiceProvider).refreshScheduledReminders(),
        );
        unawaited(
          ref
              .read(appIconServiceProvider)
              .applySeasonalIconForDate(TodayController.todayDateKey()),
        );
      });
    });
    ref.watch(seedContentBootstrapProvider);

    final appLocale =
        ref.watch(appLocaleProvider).valueOrNull ?? const Locale('vi');

    return MaterialApp.router(
      title: 'Sống Đạo',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('vi')],
      debugShowCheckedModeBanner: false,
    );
  }
}
