import 'package:timezone/timezone.dart' as tz;

import 'app_database.dart';

class MassOccurrence {
  const MassOccurrence({required this.massTime, required this.scheduledAt});

  final MassTime massTime;
  final tz.TZDateTime scheduledAt;
}

class MassOccurrenceCalculator {
  const MassOccurrenceCalculator._();

  static const _weekdays = <String, int>{
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  static MassOccurrence? next({
    required Iterable<MassTime> massTimes,
    required DateTime now,
    required String timezone,
  }) {
    final tz.Location location;
    try {
      location = tz.getLocation(timezone);
    } on Object {
      return null;
    }
    final localNow = tz.TZDateTime.from(now.toUtc(), location);

    for (var offset = 0; offset <= DateTime.daysPerWeek; offset += 1) {
      final date = tz.TZDateTime(
        location,
        localNow.year,
        localNow.month,
        localNow.day + offset,
      );
      final candidates = <MassOccurrence>[];
      for (final mass in massTimes) {
        final time = _parseTime(mass.time);
        final weekday = _weekdays[mass.weekday];
        if (time == null || weekday == null || weekday != date.weekday) {
          continue;
        }
        if (!_isValidOn(mass, date)) {
          continue;
        }
        final scheduledAt = tz.TZDateTime(
          location,
          date.year,
          date.month,
          date.day,
          time.$1,
          time.$2,
        );
        if (scheduledAt.isAfter(localNow)) {
          candidates.add(
            MassOccurrence(massTime: mass, scheduledAt: scheduledAt),
          );
        }
      }
      if (candidates.isNotEmpty) {
        candidates.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        return candidates.first;
      }
    }
    return null;
  }

  static (int, int)? _parseTime(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) {
      return null;
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) {
      return null;
    }
    return (hour, minute);
  }

  static bool _isValidOn(MassTime mass, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final from = DateTime(
      mass.validFrom.year,
      mass.validFrom.month,
      mass.validFrom.day,
    );
    final to = mass.validTo == null
        ? null
        : DateTime(mass.validTo!.year, mass.validTo!.month, mass.validTo!.day);
    return !day.isBefore(from) && (to == null || !day.isAfter(to));
  }
}
