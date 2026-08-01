import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../local/daily_action_engine.dart';
import '../local/user_settings_repository.dart';
import '../local/widget_snapshot_service.dart';

const _legacyDemoChurchId = 'giao_xu_demo_tan_dinh';
const _packManifestKeyPrefix = 'content_pack_manifest_';

class ContentPackImportResult {
  const ContentPackImportResult({
    required this.packId,
    required this.version,
    required this.checksum,
    required this.imported,
  });

  final String packId;
  final String version;
  final String checksum;
  final bool imported;
}

class ContentPackImporter {
  ContentPackImporter(this.db);

  final AppDatabase db;

  Future<ContentPackImportResult> importPackJson(
    String jsonSource, {
    bool force = false,
  }) async {
    final decoded = jsonDecode(jsonSource);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Content pack must be a JSON object.');
    }

    _validatePack(decoded);
    _verifyChecksum(decoded);

    final packId = decoded['pack_id']! as String;
    final version = decoded['version']! as String;
    final checksum = decoded['checksum']! as String;
    final locale = decoded['locale']! as String;
    final calendarDays = _list(decoded, 'calendar_days');
    final celebrations = _list(decoded, 'celebrations');
    final readings = _list(decoded, 'readings');
    final dailyReflections = _optionalList(decoded, 'daily_reflections');
    final actionRules = _list(decoded, 'action_rules');
    final prayers = _list(decoded, 'prayers');
    final churches = _list(decoded, 'churches');
    final massTimes = _list(decoded, 'mass_times');
    final activeKey = 'active_content_pack_$packId';
    final manifestKey = '$_packManifestKeyPrefix$packId';
    final calendarScopeKey = UserSettingsKeys.activeCalendarContent(locale);
    final existing = await (db.select(
      db.userSettings,
    )..where((t) => t.key.equals(activeKey))).getSingleOrNull();
    final previousManifestSetting = await (db.select(
      db.userSettings,
    )..where((t) => t.key.equals(manifestKey))).getSingleOrNull();
    final calendarScopeSetting = await (db.select(
      db.userSettings,
    )..where((t) => t.key.equals(calendarScopeKey))).getSingleOrNull();
    final previousManifest = _decodeObject(previousManifestSetting?.value);
    final calendarScope = _decodeStringMap(calendarScopeSetting?.value);
    final calendarDates = calendarDays
        .map((row) => row['date']! as String)
        .toSet();
    final ownsCalendarScope = calendarDates.every(
      (date) => calendarScope[date] == '$packId@$checksum',
    );
    final manifestIsCurrent =
        previousManifest['checksum'] == checksum &&
        previousManifest['version'] == version;

    if (!force &&
        existing?.value == checksum &&
        manifestIsCurrent &&
        ownsCalendarScope) {
      return ContentPackImportResult(
        packId: packId,
        version: version,
        checksum: checksum,
        imported: false,
      );
    }

    await db.transaction(() async {
      await _removePreviouslyImportedRows(previousManifest, packId);
      await _replaceCalendarScope(
        locale: locale,
        packId: packId,
        checksum: checksum,
        incomingDates: calendarDates,
        previousManifest: previousManifest,
        calendarScope: calendarScope,
        calendarScopeKey: calendarScopeKey,
      );
      await _removeLegacyDemoChurch();
      await _importCalendarDays(calendarDays);
      await _importCelebrations(celebrations);
      await _importReadings(readings);
      await _importDailyReflections(dailyReflections);
      await _importActionRules(actionRules, packId);
      await _importPrayers(prayers);
      await _importChurches(
        churches,
        defaultTimezone: decoded['timezone'] as String?,
      );
      await _importMassTimes(massTimes);
      await db
          .into(db.userSettings)
          .insertOnConflictUpdate(
            UserSettingsCompanion.insert(
              key: activeKey,
              value: checksum,
              updatedAt: Value(DateTime.now()),
            ),
          );
      await db
          .into(db.userSettings)
          .insertOnConflictUpdate(
            UserSettingsCompanion.insert(
              key: manifestKey,
              value: jsonEncode({
                'pack_id': packId,
                'version': version,
                'checksum': checksum,
                'locale': locale,
                'calendar_dates': calendarDates.toList()..sort(),
                'celebration_ids': _ids(celebrations),
                'reading_ids': _ids(readings),
                'daily_reflection_ids': _ids(dailyReflections),
                'action_rule_ids': _ids(actionRules),
                'prayer_ids': _ids(prayers),
                'church_ids': _ids(churches),
                'mass_time_ids': _ids(massTimes),
              }),
              updatedAt: Value(DateTime.now()),
            ),
          );
      await db
          .into(db.userSettings)
          .insertOnConflictUpdate(
            UserSettingsCompanion.insert(
              key: 'active_content_pack_manifest',
              value: jsonEncode({
                'pack_id': packId,
                'version': version,
                'checksum': checksum,
                'imported_at': DateTime.now().toUtc().toIso8601String(),
              }),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });

    await _regenerateNextWidgetSnapshots(decoded['valid_from']! as String);

    return ContentPackImportResult(
      packId: packId,
      version: version,
      checksum: checksum,
      imported: true,
    );
  }

  Future<void> _replaceCalendarScope({
    required String locale,
    required String packId,
    required String checksum,
    required Set<String> incomingDates,
    required Map<String, Object?> previousManifest,
    required Map<String, String> calendarScope,
    required String calendarScopeKey,
  }) async {
    final previousDates = _stringSet(previousManifest['calendar_dates']);
    final ownedPreviousDates = previousDates.where(
      (date) => calendarScope[date]?.startsWith('$packId@') ?? false,
    );
    final staleDates = ownedPreviousDates.toSet()..removeAll(incomingDates);
    final datesToReplace = {...incomingDates, ...staleDates};

    await _deleteCalendarContent(datesToReplace, locale);
    await _deleteUncommittedDailyActions(datesToReplace, locale);

    for (final date in staleDates) {
      calendarScope.remove(date);
      final hasUserAction =
          await (db.select(db.dailyActions)
                ..where((t) => t.date.equals(date))
                ..limit(1))
              .getSingleOrNull() !=
          null;
      if (!hasUserAction) {
        await (db.delete(
          db.calendarDays,
        )..where((t) => t.date.equals(date) & t.locale.equals(locale))).go();
      }
    }
    for (final date in incomingDates) {
      calendarScope[date] = '$packId@$checksum';
    }

    if (datesToReplace.isNotEmpty) {
      await db
          .into(db.userSettings)
          .insertOnConflictUpdate(
            UserSettingsCompanion.insert(
              key: calendarScopeKey,
              value: jsonEncode(calendarScope),
              updatedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  Future<void> _deleteCalendarContent(Set<String> dates, String locale) async {
    for (final chunk in _chunks(dates)) {
      await (db.delete(
        db.dailyReflections,
      )..where((t) => t.date.isIn(chunk) & t.locale.equals(locale))).go();
      await (db.delete(
        db.readings,
      )..where((t) => t.date.isIn(chunk) & t.locale.equals(locale))).go();
      await (db.delete(
        db.celebrations,
      )..where((t) => t.date.isIn(chunk) & t.locale.equals(locale))).go();
    }
  }

  Future<void> _deleteUncommittedDailyActions(
    Set<String> dates,
    String locale,
  ) async {
    for (final dateChunk in _chunks(dates)) {
      final actions = await (db.select(
        db.dailyActions,
      )..where((t) => t.date.isIn(dateChunk) & t.locale.equals(locale))).get();
      final actionIds = actions.map((action) => action.id).toSet();
      if (actionIds.isEmpty) {
        continue;
      }

      final loggedActionIds = <String>{};
      for (final actionChunk in _chunks(actionIds)) {
        final logs = await (db.select(
          db.actionLogs,
        )..where((t) => t.actionId.isIn(actionChunk))).get();
        loggedActionIds.addAll(logs.map((log) => log.actionId));
      }
      actionIds.removeAll(loggedActionIds);
      await _deleteIds(
        actionIds,
        (ids) =>
            (db.delete(db.dailyActions)..where((t) => t.id.isIn(ids))).go(),
      );
    }
  }

  Future<void> _removePreviouslyImportedRows(
    Map<String, Object?> manifest,
    String packId,
  ) async {
    await _deleteIds(
      _stringSet(manifest['mass_time_ids']),
      (ids) => (db.delete(db.massTimes)..where((t) => t.id.isIn(ids))).go(),
    );
    await _deleteIds(
      _stringSet(manifest['church_ids']),
      (ids) => (db.delete(db.churches)..where((t) => t.id.isIn(ids))).go(),
    );
    await _deleteIds(
      _stringSet(manifest['prayer_ids']),
      (ids) => (db.delete(db.prayers)..where((t) => t.id.isIn(ids))).go(),
    );
    await _deleteIds(
      _stringSet(manifest['daily_reflection_ids']),
      (ids) =>
          (db.delete(db.dailyReflections)..where((t) => t.id.isIn(ids))).go(),
    );
    await _deleteIds(
      _stringSet(manifest['reading_ids']),
      (ids) => (db.delete(db.readings)..where((t) => t.id.isIn(ids))).go(),
    );
    await _deleteIds(
      _stringSet(manifest['celebration_ids']),
      (ids) => (db.delete(db.celebrations)..where((t) => t.id.isIn(ids))).go(),
    );
    await (db.delete(
      db.actionRules,
    )..where((t) => t.packId.equals(packId))).go();
  }

  Future<void> _deleteIds(
    Set<String> ids,
    Future<int> Function(List<String>) delete,
  ) async {
    for (final chunk in _chunks(ids)) {
      await delete(chunk);
    }
  }

  Iterable<List<String>> _chunks(Iterable<String> values) sync* {
    final chunk = <String>[];
    for (final value in values) {
      chunk.add(value);
      if (chunk.length == 400) {
        yield List<String>.of(chunk);
        chunk.clear();
      }
    }
    if (chunk.isNotEmpty) {
      yield chunk;
    }
  }

  List<String> _ids(List<Map<String, Object?>> rows) {
    return rows.map((row) => row['id']! as String).toList(growable: false);
  }

  Set<String> _stringSet(Object? value) {
    if (value is! List) {
      return {};
    }
    return value.whereType<String>().toSet();
  }

  Map<String, Object?> _decodeObject(String? value) {
    if (value == null) {
      return {};
    }
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, Object?> ? decoded : {};
    } on FormatException {
      return {};
    }
  }

  Map<String, String> _decodeStringMap(String? value) {
    return _decodeObject(value).map(
      (key, value) => MapEntry(key, value is String ? value : ''),
    )..removeWhere((key, value) => value.isEmpty);
  }

  Future<void> _regenerateNextWidgetSnapshots(String validFrom) async {
    final engine = DailyActionEngine(db);
    final snapshots = WidgetSnapshotService(db);
    final startDate = DateTime.parse(validFrom);
    for (var offset = 0; offset < 14; offset += 1) {
      final date = _dateKey(startDate.add(Duration(days: offset)));
      final publishLatest = date == _dateKey(DateTime.now());
      final action = await engine.getOrCreateActionForDate(
        date,
        publishWidgetSnapshot: publishLatest,
      );
      await snapshots.regenerateForDate(
        date,
        locale: action.locale,
        publishLatest: publishLatest,
      );
    }
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _validatePack(Map<String, Object?> pack) {
    const requiredFields = [
      'schema_version',
      'pack_id',
      'version',
      'locale',
      'created_at',
      'valid_from',
      'valid_to',
      'source_summary',
      'license_summary',
      'checksum',
      'calendar_days',
      'celebrations',
      'readings',
      'action_rules',
      'prayers',
      'churches',
      'mass_times',
    ];
    for (final field in requiredFields) {
      if (!pack.containsKey(field)) {
        throw FormatException('Content pack missing required field: $field');
      }
    }
    if (pack['schema_version'] != '0.1' && pack['schema_version'] != '0.2') {
      throw FormatException(
        'Unsupported content pack schema: ${pack['schema_version']}',
      );
    }

    final calendarDates = _list(
      pack,
      'calendar_days',
    ).map((row) => row['date']).whereType<String>().toSet();
    for (final celebration in _list(pack, 'celebrations')) {
      _requireKnownDate(calendarDates, celebration, 'celebration');
    }
    for (final reading in _list(pack, 'readings')) {
      _requireKnownDate(calendarDates, reading, 'reading');
      final license = reading['license'];
      final text = reading['text'];
      if ((license == 'reference-only' || license == 'pending-review') &&
          text != null) {
        throw FormatException(
          'Reading ${reading['id']} cannot include text with $license license.',
        );
      }
    }
    for (final reflection in _optionalList(pack, 'daily_reflections')) {
      _requireKnownDate(calendarDates, reflection, 'daily reflection');
      if (reflection['license'] == 'reference-only') {
        throw FormatException(
          'Daily reflection ${reflection['id']} cannot use reference-only license.',
        );
      }
    }

    final churchIds = _list(
      pack,
      'churches',
    ).map((row) => row['id']).whereType<String>().toSet();
    for (final massTime in _list(pack, 'mass_times')) {
      final churchId = massTime['church_id'];
      if (churchId is! String || !churchIds.contains(churchId)) {
        throw FormatException(
          'Mass time ${massTime['id']} references unknown church.',
        );
      }
    }
  }

  void _verifyChecksum(Map<String, Object?> pack) {
    final checksum = pack['checksum'];
    if (checksum is! String || !checksum.startsWith('sha256:')) {
      throw const FormatException('Content pack checksum must use sha256.');
    }

    final canonical = _canonicalJson({...pack, 'checksum': ''});
    final computed = 'sha256:${sha256.convert(utf8.encode(canonical))}';
    if (computed != checksum) {
      throw FormatException(
        'Content pack checksum mismatch: expected $checksum, got $computed',
      );
    }
  }

  Future<void> _importCalendarDays(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await db
          .into(db.calendarDays)
          .insertOnConflictUpdate(
            CalendarDaysCompanion.insert(
              date: row['date']! as String,
              season: row['season']! as String,
              liturgicalWeek: _liturgicalWeekNumber(row['liturgical_week']),
              color: row['liturgical_color']! as String,
              cycleYear: (row['cycle_year'] as String?) ?? '',
              locale: row['locale']! as String,
              lunarDate: Value(
                row['locale'] == 'vi' ? row['lunar_date'] as String? : null,
              ),
            ),
          );
    }
  }

  Future<void> _importCelebrations(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await db
          .into(db.celebrations)
          .insertOnConflictUpdate(
            CelebrationsCompanion.insert(
              id: row['id']! as String,
              date: row['date']! as String,
              name: row['title']! as String,
              rank: row['rank']! as String,
              isOptional: Value(row['rank'] == 'optional_memorial'),
              locale: row['locale']! as String,
            ),
          );
    }
  }

  Future<void> _importReadings(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await db
          .into(db.readings)
          .insertOnConflictUpdate(
            ReadingsCompanion.insert(
              id: row['id']! as String,
              date: row['date']! as String,
              type: row['type']! as String,
              citation: row['citation']! as String,
              displayLabel: Value(row['display_label'] as String?),
              textContent: Value(row['text'] as String?),
              sourceUrl: Value(row['source_url'] as String?),
              license: row['license']! as String,
              locale: row['locale']! as String,
            ),
          );
    }
  }

  Future<void> _importDailyReflections(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await db
          .into(db.dailyReflections)
          .insertOnConflictUpdate(
            DailyReflectionsCompanion.insert(
              id: row['id']! as String,
              date: row['date']! as String,
              locale: row['locale']! as String,
              title: row['title']! as String,
              body: row['body']! as String,
              sourceUrl: Value(row['source_url'] as String?),
              license: row['license']! as String,
              source: _canonicalJson(row['source']),
            ),
          );
    }
  }

  Future<void> _importActionRules(
    List<Map<String, Object?>> rows,
    String packId,
  ) async {
    for (final row in rows) {
      final action = row['action']! as Map<String, Object?>;
      await db
          .into(db.actionRules)
          .insertOnConflictUpdate(
            ActionRulesCompanion.insert(
              id: row['id']! as String,
              type: action['type']! as String,
              triggerCondition: _canonicalJson(row['when']),
              templatePrompt: _canonicalJson(action),
              priority: row['priority']! as int,
              locale: Value(row['locale']! as String),
              packId: Value(packId),
              isActive: Value(row['enabled']! as bool),
            ),
          );
    }
  }

  Future<void> _importPrayers(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await db
          .into(db.prayers)
          .insertOnConflictUpdate(
            PrayersCompanion.insert(
              id: row['id']! as String,
              locale: row['locale']! as String,
              title: row['title']! as String,
              body: Value(row['body'] as String?),
              sourceUrl: Value(row['source_url'] as String?),
              license: row['license']! as String,
              tags: Value(jsonEncode(row['tags'] ?? const [])),
              source: _canonicalJson(row['source']),
            ),
          );
    }
  }

  Future<void> _importChurches(
    List<Map<String, Object?>> rows, {
    String? defaultTimezone,
  }) async {
    for (final row in rows) {
      await db
          .into(db.churches)
          .insertOnConflictUpdate(
            ChurchesCompanion.insert(
              id: row['id']! as String,
              locale: row['locale']! as String,
              name: row['name']! as String,
              diocese: row['diocese']! as String,
              address: row['address']! as String,
              timezone: Value(
                (row['timezone'] as String?) ?? defaultTimezone ?? 'UTC',
              ),
              latitude: Value((row['latitude'] as num?)?.toDouble()),
              longitude: Value((row['longitude'] as num?)?.toDouble()),
              phone: Value(row['phone'] as String?),
              website: Value(row['website'] as String?),
              verifiedAt: Value(_optionalDate(row['verified_at'])),
              source: _canonicalJson(row['source']),
            ),
          );
    }
  }

  Future<void> _removeLegacyDemoChurch() async {
    await (db.delete(
      db.massTimes,
    )..where((t) => t.churchId.equals(_legacyDemoChurchId))).go();
    await (db.delete(
      db.churches,
    )..where((t) => t.id.equals(_legacyDemoChurchId))).go();
    await (db.delete(db.userSettings)..where(
          (t) =>
              t.key.equals(UserSettingsKeys.selectedChurchId) &
              t.value.equals(_legacyDemoChurchId),
        ))
        .go();
  }

  Future<void> _importMassTimes(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await db
          .into(db.massTimes)
          .insertOnConflictUpdate(
            MassTimesCompanion.insert(
              id: row['id']! as String,
              churchId: row['church_id']! as String,
              weekday: row['weekday']! as String,
              context: row['context']! as String,
              time: row['time']! as String,
              language: row['language']! as String,
              validFrom: DateTime.parse(row['valid_from']! as String),
              validTo: Value(_optionalDate(row['valid_to'])),
              isImportantDefault: Value(row['is_important_default']! as bool),
              source: _canonicalJson(row['source']),
            ),
          );
    }
  }

  List<Map<String, Object?>> _list(Map<String, Object?> pack, String key) {
    final value = pack[key];
    if (value is! List) {
      throw FormatException('Content pack field $key must be a list.');
    }
    return value
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw FormatException(
              'Content pack field $key has a non-object item.',
            );
          }
          return item;
        })
        .toList(growable: false);
  }

  List<Map<String, Object?>> _optionalList(
    Map<String, Object?> pack,
    String key,
  ) {
    if (!pack.containsKey(key)) {
      return const [];
    }
    return _list(pack, key);
  }

  void _requireKnownDate(
    Set<String> calendarDates,
    Map<String, Object?> row,
    String kind,
  ) {
    final date = row['date'];
    if (date is! String || !calendarDates.contains(date)) {
      throw FormatException(
        '$kind ${row['id']} references unknown calendar date.',
      );
    }
  }

  int _liturgicalWeekNumber(Object? value) {
    final text = value?.toString() ?? '';
    const romanValues = {'I': 1, 'II': 2, 'III': 3, 'IV': 4, 'V': 5};
    for (final entry in romanValues.entries.toList().reversed) {
      if (text.contains(' ${entry.key} ') || text.contains(' ${entry.key}')) {
        return entry.value;
      }
    }
    return 0;
  }

  DateTime? _optionalDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }

  String _canonicalJson(Object? value) {
    if (value is Map) {
      final sorted = <String, Object?>{};
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      for (final key in keys) {
        sorted[key] = _canonicalValue(value[key]);
      }
      return jsonEncode(sorted);
    }
    return jsonEncode(_canonicalValue(value));
  }

  Object? _canonicalValue(Object? value) {
    if (value is Map) {
      final sorted = <String, Object?>{};
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      for (final key in keys) {
        sorted[key] = _canonicalValue(value[key]);
      }
      return sorted;
    }
    if (value is List) {
      return value.map(_canonicalValue).toList(growable: false);
    }
    return value;
  }
}
