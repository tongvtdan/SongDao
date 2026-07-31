import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:songdao/data/content/content_pack_provider.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/database_provider.dart';
import 'package:songdao/features/today/today_controller.dart';
import 'package:songdao/features/today/today_screen.dart';

AppDatabase _openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  testWidgets(
    'swiping date card previews another date without changing action',
    (tester) async {
      final db = _openTestDb();
      addTearDown(db.close);

      final todayKey = TodayController.todayDateKey();
      final tomorrowKey = _dateKey(
        DateTime.parse(todayKey).add(const Duration(days: 1)),
      );

      await _insertCalendarDay(db, todayKey);
      await _insertCalendarDay(db, tomorrowKey);
      await _insertCelebration(db, todayKey, name: 'Ngày hôm nay thử nghiệm');
      await _insertCelebration(db, tomorrowKey, name: 'Ngày mai thử nghiệm');
      await _insertDailyAction(
        db,
        id: 'today-action',
        date: todayKey,
        prompt: 'Hành động của hôm nay',
      );
      await _insertDailyAction(
        db,
        id: 'tomorrow-action',
        date: tomorrowKey,
        prompt: 'Hành động của ngày mai',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: TodayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ngày hôm nay thử nghiệm'), findsOneWidget);
      expect(find.text('Hành động của hôm nay'), findsOneWidget);

      await tester.tap(find.byTooltip('Ngày sau'));
      await tester.pumpAndSettle();

      expect(find.text('Ngày mai thử nghiệm'), findsOneWidget);
      expect(
        find.text('Xem ngày khác. Hành động bên dưới vẫn là hôm nay.'),
        findsOneWidget,
      );
      expect(find.text('Hành động của hôm nay'), findsOneWidget);
      expect(find.text('Hành động của ngày mai'), findsNothing);

      await tester.tap(find.text('Hôm nay'));
      await tester.pumpAndSettle();

      expect(find.text('Ngày hôm nay thử nghiệm'), findsOneWidget);
      expect(find.text('Ngày mai thử nghiệm'), findsNothing);
    },
  );
}

Future<void> _insertCalendarDay(AppDatabase db, String date) {
  return db
      .into(db.calendarDays)
      .insert(
        CalendarDaysCompanion.insert(
          date: date,
          season: 'ordinary',
          liturgicalWeek: 1,
          color: 'green',
          cycleYear: 'C',
          locale: 'vi',
        ),
      );
}

Future<void> _insertCelebration(
  AppDatabase db,
  String date, {
  required String name,
}) {
  return db
      .into(db.celebrations)
      .insert(
        CelebrationsCompanion.insert(
          id: 'celebration-$date',
          date: date,
          name: name,
          rank: 'memorial',
          locale: 'vi',
        ),
      );
}

Future<void> _insertDailyAction(
  AppDatabase db, {
  required String id,
  required String date,
  required String prompt,
}) {
  return db
      .into(db.dailyActions)
      .insert(
        DailyActionsCompanion.insert(
          id: id,
          date: date,
          sourceRule: 'test_rule',
          prompt: prompt,
          type: 'reflection',
          priority: 1,
          locale: 'vi',
        ),
      );
}

String _dateKey(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
