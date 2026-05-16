import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/app/router.dart';
import 'package:songdao/data/content/content_pack_provider.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/database_provider.dart';
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
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
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
