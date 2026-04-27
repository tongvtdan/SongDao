import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songdao/l10n/app_localizations.dart';

import 'theme.dart';
import 'router.dart';

class SongDaoApp extends ConsumerWidget {
  const SongDaoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Sống Đạo',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: const Locale('vi'), // Set Vietnamese as the default
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
