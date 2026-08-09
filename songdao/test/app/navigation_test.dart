import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/app/router.dart';
import 'package:songdao/data/content/content_pack_provider.dart';
import 'package:songdao/data/local/app_info_service.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/database_provider.dart';
import 'package:songdao/data/local/user_event_repository.dart';
import 'package:songdao/data/local/vietnamese_lunar_calendar_service.dart';
import 'package:songdao/features/today/today_controller.dart';
import 'package:songdao/l10n/app_localizations.dart';

AppDatabase _openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  testWidgets('bottom navigation demotes Church from the primary shell', (
    tester,
  ) async {
    final db = _openTestDb();
    addTearDown(db.close);
    await _seedToday(db);

    await tester.pumpWidget(_TestApp(db: db));
    await tester.pumpAndSettle();

    expect(find.text('Hôm nay'), findsWidgets);
    expect(find.text('Lịch'), findsOneWidget);
    expect(find.text('Cầu nguyện'), findsOneWidget);
    expect(find.text('Tiến trình'), findsOneWidget);
    expect(find.text('Nhà thờ'), findsNothing);
  });

  testWidgets('settings hides beta parish selection', (tester) async {
    final db = _openTestDb();
    addTearDown(db.close);
    await _seedToday(db);

    await tester.pumpWidget(_TestApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Giáo xứ của tôi'), findsNothing);
    expect(find.text('Chọn giáo xứ'), findsNothing);
  });

  testWidgets('Calendar deep link selects its event even when date differs', (
    tester,
  ) async {
    final db = _openTestDb();
    addTearDown(db.close);
    final repository = UserEventRepository(
      db,
      const VietnameseLunarCalendarService(),
    );
    final id = await repository.create(
      const UserEventDraft(
        type: UserEventType.deathAnniversary,
        title: 'Ngày giỗ bà ngoại',
        calendarSystem: EventCalendarSystem.solar,
        anchorYear: 2026,
        anchorMonth: 8,
        anchorDay: 9,
        recurrence: EventRecurrence.once,
      ),
    );

    await tester.pumpWidget(
      _TestApp(db: db, initialRoute: '/calendar?date=2030-01-01&eventId=$id'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tháng 8, 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ngày giỗ bà ngoại'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Ngày giỗ bà ngoại'), findsOneWidget);
  });

  testWidgets('new event route preselects its Calendar query date', (
    tester,
  ) async {
    final db = _openTestDb();
    addTearDown(db.close);

    await tester.pumpWidget(
      _TestApp(db: db, initialRoute: '/calendar/events/new?date=2026-02-17'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thêm sự kiện'), findsOneWidget);
    expect(find.text('17/02/2026'), findsOneWidget);
    expect(find.text('Âm lịch: 1/1/2026'), findsOneWidget);
  });

  testWidgets('edit event route loads the whole recurring series', (
    tester,
  ) async {
    final db = _openTestDb();
    addTearDown(db.close);
    final repository = UserEventRepository(
      db,
      const VietnameseLunarCalendarService(),
    );
    final id = await repository.create(
      const UserEventDraft(
        type: UserEventType.weddingAnniversary,
        title: 'Kỷ niệm Hôn phối của bố mẹ',
        calendarSystem: EventCalendarSystem.solar,
        anchorYear: 1990,
        anchorMonth: 5,
        anchorDay: 12,
        recurrence: EventRecurrence.yearly,
      ),
    );

    await tester.pumpWidget(
      _TestApp(db: db, initialRoute: '/calendar/events/$id/edit'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sửa sự kiện'), findsOneWidget);
    expect(find.text('Kỷ niệm Hôn phối của bố mẹ'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.db, this.initialRoute});

  final AppDatabase db;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialDeepLinkRouteProvider.overrideWithValue(initialRoute),
        appInfoServiceProvider.overrideWithValue(const _FakeAppInfoService()),
        seedContentBootstrapProvider.overrideWith((ref) async => []),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          return MaterialApp.router(
            routerConfig: ref.watch(routerProvider),
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}

class _FakeAppInfoService extends AppInfoService {
  const _FakeAppInfoService();

  @override
  Future<AppVersionInfo> versionInfo() async {
    return const AppVersionInfo(version: '0.1.0', buildNumber: '3');
  }
}

Future<void> _seedToday(AppDatabase db) async {
  final todayKey = TodayController.todayDateKey();
  await db
      .into(db.calendarDays)
      .insert(
        CalendarDaysCompanion.insert(
          date: todayKey,
          season: 'ordinary',
          liturgicalWeek: 1,
          color: 'green',
          cycleYear: 'C',
          locale: 'vi',
        ),
      );
  await db
      .into(db.dailyActions)
      .insert(
        DailyActionsCompanion.insert(
          id: 'today-action',
          date: todayKey,
          sourceRule: 'test_rule',
          prompt: 'Hành động hôm nay',
          type: 'reflection',
          priority: 1,
          locale: 'vi',
        ),
      );
}
