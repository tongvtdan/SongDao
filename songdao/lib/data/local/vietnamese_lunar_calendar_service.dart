import 'package:vnlunar/vnlunar.dart';

class LunarDateValue {
  const LunarDateValue({
    required this.year,
    required this.month,
    required this.day,
    this.isLeapMonth = false,
  });

  final int year;
  final int month;
  final int day;
  final bool isLeapMonth;

  @override
  bool operator ==(Object other) {
    return other is LunarDateValue &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.isLeapMonth == isLeapMonth;
  }

  @override
  int get hashCode => Object.hash(year, month, day, isLeapMonth);
}

class VietnameseLunarCalendarService {
  const VietnameseLunarCalendarService();

  static const int minYear = 1800;
  static const int maxYear = 2199;
  static const int vietnamTimeZone = 7;

  LunarDateValue solarToLunar(DateTime solarDate) {
    _validateYear(solarDate.year);
    final values = convertSolar2Lunar(
      solarDate.day,
      solarDate.month,
      solarDate.year,
      vietnamTimeZone,
    );
    return LunarDateValue(
      day: values[0],
      month: values[1],
      year: values[2],
      isLeapMonth: values[3] == 1,
    );
  }

  DateTime lunarToSolarExact(LunarDateValue lunarDate) {
    final result = tryLunarToSolarExact(lunarDate);
    if (result == null) {
      throw ArgumentError.value(lunarDate, 'lunarDate', 'Invalid lunar date');
    }
    return result;
  }

  DateTime? tryLunarToSolarExact(LunarDateValue lunarDate) {
    if (!_hasValidComponents(lunarDate)) {
      return null;
    }
    final values = convertLunar2Solar(
      lunarDate.day,
      lunarDate.month,
      lunarDate.year,
      lunarDate.isLeapMonth,
      vietnamTimeZone,
    );
    if (values.length != 3 || values.any((value) => value <= 0)) {
      return null;
    }
    final solarDate = DateTime(values[2], values[1], values[0]);
    final roundTrip = solarToLunar(solarDate);
    return roundTrip == lunarDate ? solarDate : null;
  }

  DateTime lunarOccurrence({
    required LunarDateValue anchor,
    required int targetYear,
  }) {
    _validateYear(targetYear);
    final leapOptions = anchor.isLeapMonth
        ? const [true, false]
        : const [false];
    final dayOptions = anchor.day == 30 ? const [30, 29] : [anchor.day];

    for (final leapMonth in leapOptions) {
      for (final day in dayOptions) {
        final result = tryLunarToSolarExact(
          LunarDateValue(
            year: targetYear,
            month: anchor.month,
            day: day,
            isLeapMonth: leapMonth,
          ),
        );
        if (result != null) {
          return result;
        }
      }
    }
    throw StateError('No valid occurrence for the lunar event');
  }

  int? leapMonthForYear(int year) {
    _validateYear(year);
    for (var month = 1; month <= 12; month += 1) {
      final leapDate = LunarDateValue(
        year: year,
        month: month,
        day: 1,
        isLeapMonth: true,
      );
      if (tryLunarToSolarExact(leapDate) != null) {
        return month;
      }
    }
    return null;
  }

  bool _hasValidComponents(LunarDateValue date) {
    return date.year >= minYear &&
        date.year <= maxYear &&
        date.month >= 1 &&
        date.month <= 12 &&
        date.day >= 1 &&
        date.day <= 30;
  }

  void _validateYear(int year) {
    if (year < minYear || year > maxYear) {
      throw RangeError.range(year, minYear, maxYear, 'year');
    }
  }
}
