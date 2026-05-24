import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/content/content_pack_provider.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/daily_action_engine.dart';
import 'package:songdao/data/local/database_provider.dart';
import 'package:songdao/features/today/today_controller.dart';
import 'package:songdao/features/today/today_screen.dart';
import 'package:songdao/features/today/widgets/daily_action_card.dart';
import 'package:songdao/features/today/widgets/reflection_note_card.dart';
import 'package:songdao/features/today/widgets/swipeable_liturgical_context_card.dart';
import 'package:songdao/features/today/widgets/today_error_widget.dart';

AppDatabase _openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('TodayScreen Smoke Tests', () {
    late AppDatabase db;
    late String todayKey;

    setUp(() async {
      db = _openTestDb();
      todayKey = TodayController.todayDateKey();

      // Insert common testing data
      await db.into(db.calendarDays).insert(
        CalendarDaysCompanion.insert(
          date: todayKey,
          season: 'ordinary',
          liturgicalWeek: 1,
          color: 'green',
          cycleYear: 'C',
          locale: 'vi',
          lunarDate: const Value('Mồng 5 tháng Tư'),
        ),
      );

      await db.into(db.celebrations).insert(
        CelebrationsCompanion.insert(
          id: 'celebration-$todayKey',
          date: todayKey,
          name: 'Thánh Lễ Thử Nghiệm',
          rank: 'memorial',
          locale: 'vi',
        ),
      );

      await db.into(db.dailyActions).insert(
        DailyActionsCompanion.insert(
          id: 'action-$todayKey',
          date: todayKey,
          sourceRule: 'test_rule',
          prompt: 'Làm một việc lành nhỏ hôm nay',
          type: 'kindness',
          priority: 1,
          locale: 'vi',
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('Verify normal initial state presentation', (tester) async {
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

      // Verify Swipeable Liturgical Context Card details are rendered
      expect(find.byType(SwipeableLiturgicalContextCard), findsOneWidget);
      expect(find.text('Thánh Lễ Thử Nghiệm'), findsOneWidget);
      expect(find.text('Mồng 5 tháng Tư'), findsOneWidget); // Lunar calendar date
      expect(find.text('Thường niên'), findsOneWidget); // Localized season
      expect(find.text('Xanh'), findsOneWidget); // Localized color

      // Verify Daily Action details are rendered
      expect(find.byType(DailyActionCard), findsOneWidget);
      expect(find.text('Làm một việc lành nhỏ hôm nay'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsOneWidget);

      // Action log is not complete, so reflection note should not be shown yet
      expect(find.byType(ReflectionNoteCard), findsNothing);
    });

    testWidgets('Verify daily action completion and reflection note saving', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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

      // Tap "Hoàn thành" to complete today's action
      await tester.ensureVisible(find.text('Hoàn thành'));
      await tester.tap(find.text('Hoàn thành'));
      await tester.pumpAndSettle();

      // Action card should transition to completion view
      expect(find.text('Bạn đã sống đạo hôm nay!'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsNothing);

      // The reflection note card should now be displayed
      expect(find.byType(ReflectionNoteCard), findsOneWidget);

      // Enter a reflection note
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Tôi đã đọc Kinh Thánh hôm nay.');
      await tester.pumpAndSettle();

      // Save the note
      await tester.ensureVisible(find.text('Lưu'));
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      // Verify the note is saved inside the Drift DB
      final log = await (db.select(db.actionLogs)..limit(1)).getSingleOrNull();
      expect(log, isNotNull);
      expect(log!.status, equals('completed'));
      expect(log.note, equals('Tôi đã đọc Kinh Thánh hôm nay.'));
    });

    testWidgets('Verify today screen displays error state and supports retry', (
      tester,
    ) async {
      var bootAttempts = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async {
              bootAttempts++;
              if (bootAttempts == 1) {
                throw Exception('Simulated bootstrap load error');
              }
              return [];
            }),
          ],
          child: const MaterialApp(home: TodayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Displays error widget instead of normal widgets
      expect(find.byType(TodayErrorWidget), findsOneWidget);
      expect(
        find.text(
          'Dữ liệu hôm nay đang ở trên thiết bị. Thử tải lại nếu nội dung chưa hiện.',
        ),
        findsOneWidget,
      );
      expect(find.byType(SwipeableLiturgicalContextCard), findsNothing);

      // Tap the retry button "Tải lại"
      await tester.tap(find.text('Tải lại'));
      await tester.pumpAndSettle();

      // Verify that after retry, it compiles and loads the main screen details
      expect(bootAttempts, equals(2));
      expect(find.byType(TodayErrorWidget), findsNothing);
      expect(find.byType(SwipeableLiturgicalContextCard), findsOneWidget);
      expect(find.text('Thánh Lễ Thử Nghiệm'), findsOneWidget);
    });

    testWidgets('Verify liturgical card swiping displays error on missing days', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            dailyActionEngineProvider.overrideWithValue(MockDailyActionEngine(db)),
            seedContentBootstrapProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: TodayScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Swipe to the next day (tomorrow) which is NOT seeded with a calendarDay
      await tester.tap(find.byTooltip('Ngày sau'));
      await tester.pump(); // Start navigation/loading future

      // Should display the preview loading card briefly
      expect(find.text('Chưa mở được ngày này'), findsNothing);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // Since tomorrow has no calendarDay seeded in DB, it should show error preview card
      expect(find.text('Chưa mở được ngày này'), findsOneWidget);
      expect(
        find.text('Xem ngày khác. Hành động bên dưới vẫn là hôm nay.'),
        findsOneWidget,
      );
    });
  });
}

class MockDailyActionEngine extends DailyActionEngine {
  MockDailyActionEngine(super.db);

  @override
  Future<DailyAction> getOrCreateActionForDate(
    String date, {
    String locale = 'vi',
    bool publishWidgetSnapshot = true,
  }) async {
    if (date != TodayController.todayDateKey()) {
      throw Exception('Simulated load error for preview date');
    }
    return super.getOrCreateActionForDate(
      date,
      locale: locale,
      publishWidgetSnapshot: publishWidgetSnapshot,
    );
  }
}
