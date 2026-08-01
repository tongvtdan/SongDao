import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/mass_occurrence.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('selects the next Mass later on the same day', () {
    final result = MassOccurrenceCalculator.next(
      massTimes: [
        _mass(id: 'morning', weekday: 'monday', time: '07:00'),
        _mass(id: 'evening', weekday: 'monday', time: '18:00'),
      ],
      now: DateTime.utc(2026, 8, 3, 9),
      timezone: 'Asia/Ho_Chi_Minh',
    );

    expect(result?.massTime.id, 'evening');
  });

  test('moves to the next day after the last Mass', () {
    final result = MassOccurrenceCalculator.next(
      massTimes: [
        _mass(id: 'monday', weekday: 'monday', time: '18:00'),
        _mass(id: 'tuesday', weekday: 'tuesday', time: '06:30'),
      ],
      now: DateTime.utc(2026, 8, 3, 12),
      timezone: 'Asia/Ho_Chi_Minh',
    );

    expect(result?.massTime.id, 'tuesday');
  });

  test('wraps to Monday after the final Sunday Mass', () {
    final result = MassOccurrenceCalculator.next(
      massTimes: [
        _mass(id: 'sunday', weekday: 'sunday', time: '18:00'),
        _mass(id: 'monday', weekday: 'monday', time: '05:30'),
      ],
      now: DateTime.utc(2026, 8, 2, 12),
      timezone: 'Asia/Ho_Chi_Minh',
    );

    expect(result?.massTime.id, 'monday');
  });

  test('ignores invalid and expired rows', () {
    final result = MassOccurrenceCalculator.next(
      massTimes: [
        _mass(id: 'bad-time', weekday: 'monday', time: '25:00'),
        _mass(
          id: 'expired',
          weekday: 'monday',
          time: '10:00',
          validTo: DateTime(2026, 8, 2),
        ),
        _mass(id: 'bad-day', weekday: 'funday', time: '11:00'),
      ],
      now: DateTime.utc(2026, 8, 3, 8),
      timezone: 'Asia/Ho_Chi_Minh',
    );

    expect(result, isNull);
  });

  test('uses the configured timezone across a DST transition', () {
    final result = MassOccurrenceCalculator.next(
      massTimes: [_mass(id: 'dst-mass', weekday: 'sunday', time: '09:30')],
      now: DateTime.utc(2026, 3, 8, 13),
      timezone: 'America/New_York',
    );

    expect(result?.massTime.id, 'dst-mass');
    expect(result?.scheduledAt.toUtc(), DateTime.utc(2026, 3, 8, 13, 30));
  });
}

MassTime _mass({
  required String id,
  required String weekday,
  required String time,
  DateTime? validTo,
}) {
  return MassTime(
    id: id,
    churchId: 'church',
    weekday: weekday,
    context: 'weekday',
    time: time,
    language: 'vi',
    validFrom: DateTime(2026),
    validTo: validTo,
    isImportantDefault: false,
    source: '{}',
    createdAt: DateTime(2026),
  );
}
