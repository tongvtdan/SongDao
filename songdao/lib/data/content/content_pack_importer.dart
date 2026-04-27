import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../local/app_database.dart';

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
    final activeKey = 'active_content_pack_$packId';
    final existing = await (db.select(
      db.userSettings,
    )..where((t) => t.key.equals(activeKey))).getSingleOrNull();

    if (!force && existing?.value == checksum) {
      return ContentPackImportResult(
        packId: packId,
        version: version,
        checksum: checksum,
        imported: false,
      );
    }

    await db.transaction(() async {
      await _importCalendarDays(_list(decoded, 'calendar_days'));
      await _importCelebrations(_list(decoded, 'celebrations'));
      await _importReadings(_list(decoded, 'readings'));
      await _importActionRules(_list(decoded, 'action_rules'), packId);
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

    return ContentPackImportResult(
      packId: packId,
      version: version,
      checksum: checksum,
      imported: true,
    );
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
    if (pack['schema_version'] != '0.1') {
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
