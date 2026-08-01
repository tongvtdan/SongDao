import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_database.dart';
import 'user_settings_repository.dart';

enum AppIconVariant {
  primary,
  ordinary,
  advent,
  christmas,
  lent,
  easter,
  marian,
}

class AppIconService {
  const AppIconService({
    required this._db,
    required this._settings,
    this._channel = const MethodChannel(_channelName),
  });

  static const _channelName = 'app.songdao/icon';

  final AppDatabase _db;
  final UserSettingsRepository _settings;
  final MethodChannel _channel;

  Future<bool> supportsAlternateIcons() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('supportsAlternateIcons') ??
          false;
    } on PlatformException catch (error, stackTrace) {
      _logIconError(error, stackTrace);
      return false;
    } on MissingPluginException catch (error, stackTrace) {
      _logIconError(error, stackTrace);
      return false;
    }
  }

  Future<AppIconVariant> getCurrentIcon() async {
    final stored = await _settings.selectedAppIconVariant();
    return appIconVariantFromName(stored);
  }

  Future<bool> setIcon(AppIconVariant variant) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    try {
      await _channel.invokeMethod<void>('setIcon', {
        'iconName': appIconVariantName(variant),
      });
      await _settings.setSelectedAppIconVariant(appIconVariantName(variant));
      return true;
    } on PlatformException catch (error, stackTrace) {
      _logIconError(error, stackTrace);
      return false;
    } on MissingPluginException catch (error, stackTrace) {
      _logIconError(error, stackTrace);
      return false;
    }
  }

  Future<AppIconVariant> recommendedIconForDate(
    String date, {
    String locale = 'vi',
  }) async {
    final day =
        await (_db.select(_db.calendarDays)
              ..where((t) => t.date.equals(date) & t.locale.equals(locale)))
            .getSingleOrNull();
    final celebrations =
        await (_db.select(_db.celebrations)
              ..where((t) => t.date.equals(date) & t.locale.equals(locale))
              ..orderBy([(t) => OrderingTerm.asc(t.rank)]))
            .get();
    return recommendedIconVariant(
      season: day?.season,
      celebrations: celebrations.map((item) => item.name),
    );
  }

  Future<bool> applySeasonalIconForDate(
    String date, {
    String locale = 'vi',
  }) async {
    if (!await _settings.seasonalIconEnabled()) {
      return false;
    }
    if (!await supportsAlternateIcons()) {
      return false;
    }
    final variant = await recommendedIconForDate(date, locale: locale);
    final current = await getCurrentIcon();
    if (current == variant) {
      return true;
    }
    return setIcon(variant);
  }

  void _logIconError(Object error, StackTrace stackTrace) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('App icon bridge failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

AppIconVariant recommendedIconVariant({
  required String? season,
  Iterable<String> celebrations = const [],
}) {
  final normalizedCelebrations = celebrations
      .map((value) => value.toLowerCase())
      .toList(growable: false);
  if (normalizedCelebrations.any(_isMarianCelebration)) {
    return AppIconVariant.marian;
  }

  return switch (season) {
    'advent' => AppIconVariant.advent,
    'christmas' => AppIconVariant.christmas,
    'lent' => AppIconVariant.lent,
    'easter' => AppIconVariant.easter,
    'ordinary' => AppIconVariant.ordinary,
    _ => AppIconVariant.primary,
  };
}

bool _isMarianCelebration(String value) {
  return value.contains('maria') ||
      value.contains('mary') ||
      value.contains('mẹ maria') ||
      value.contains('đức mẹ') ||
      value.contains('duc me');
}

String appIconVariantName(AppIconVariant variant) {
  return switch (variant) {
    AppIconVariant.primary => 'primary',
    AppIconVariant.ordinary => 'ordinary',
    AppIconVariant.advent => 'advent',
    AppIconVariant.christmas => 'christmas',
    AppIconVariant.lent => 'lent',
    AppIconVariant.easter => 'easter',
    AppIconVariant.marian => 'marian',
  };
}

AppIconVariant appIconVariantFromName(String name) {
  return switch (name) {
    'ordinary' => AppIconVariant.ordinary,
    'advent' => AppIconVariant.advent,
    'christmas' => AppIconVariant.christmas,
    'lent' => AppIconVariant.lent,
    'easter' => AppIconVariant.easter,
    'marian' => AppIconVariant.marian,
    _ => AppIconVariant.primary,
  };
}
