import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/local/vietnamese_lunar_calendar_service.dart';

void main() {
  const service = VietnameseLunarCalendarService();

  group('VietnameseLunarCalendarService', () {
    test('matches checkpoints from the 2026 Vietnam calendar pack', () {
      expect(
        service.solarToLunar(DateTime(2026, 1, 1)),
        const LunarDateValue(year: 2025, month: 11, day: 13),
      );
      expect(
        service.solarToLunar(DateTime(2026, 2, 17)),
        const LunarDateValue(year: 2026, month: 1, day: 1),
      );
      expect(
        service.solarToLunar(DateTime(2026, 5, 3)),
        const LunarDateValue(year: 2026, month: 3, day: 17),
      );
      expect(
        service.solarToLunar(DateTime(2026, 12, 31)),
        const LunarDateValue(year: 2026, month: 11, day: 23),
      );
    });

    test('round-trips regular and leap-month dates in UTC+7 convention', () {
      final checkpoints = [
        const LunarDateValue(year: 2026, month: 1, day: 1),
        const LunarDateValue(year: 2023, month: 2, day: 2, isLeapMonth: true),
      ];

      for (final lunar in checkpoints) {
        final solar = service.lunarToSolarExact(lunar);
        expect(service.solarToLunar(solar), lunar);
      }
      expect(service.leapMonthForYear(2023), 2);
    });

    test('falls back from a missing leap month to the regular month', () {
      const anchor = LunarDateValue(
        year: 2023,
        month: 2,
        day: 2,
        isLeapMonth: true,
      );

      final occurrence = service.lunarOccurrence(
        anchor: anchor,
        targetYear: 2024,
      );
      final roundTrip = service.solarToLunar(occurrence);

      expect(roundTrip.year, 2024);
      expect(roundTrip.month, 2);
      expect(roundTrip.day, 2);
      expect(roundTrip.isLeapMonth, isFalse);
    });

    test('clamps lunar day 30 to day 29 in a short target month', () {
      LunarDateValue? anchor;
      for (var month = 1; month <= 12; month += 1) {
        final candidate = LunarDateValue(year: 2026, month: month, day: 30);
        if (service.tryLunarToSolarExact(candidate) != null) {
          anchor = candidate;
          break;
        }
      }
      expect(anchor, isNotNull);

      LunarDateValue? clamped;
      for (var year = 2027; year <= 2040; year += 1) {
        final occurrence = service.lunarOccurrence(
          anchor: anchor!,
          targetYear: year,
        );
        final roundTrip = service.solarToLunar(occurrence);
        if (roundTrip.day == 29) {
          clamped = roundTrip;
          break;
        }
      }

      expect(clamped, isNotNull);
      expect(clamped!.month, anchor!.month);
      expect(clamped.day, 29);
    });

    test('rejects dates outside the supported 1800-2199 range', () {
      expect(
        () => service.solarToLunar(DateTime(1799, 12, 31)),
        throwsRangeError,
      );
      expect(
        () => service.solarToLunar(DateTime(2200, 1, 1)),
        throwsRangeError,
      );
      expect(
        service.tryLunarToSolarExact(
          const LunarDateValue(year: 2026, month: 13, day: 1),
        ),
        isNull,
      );
    });
  });
}
