import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songdao/data/content/content_pack_provider.dart';
import 'package:songdao/data/local/app_info_service.dart';
import 'package:songdao/data/local/app_database.dart';
import 'package:songdao/data/local/database_provider.dart';
import 'package:songdao/features/calendar/calendar_screen.dart';
import 'package:songdao/features/church_finder/church_search_screen.dart';
import 'package:songdao/features/progress/progress_screen.dart';
import 'package:songdao/features/progress/journal_screen.dart';
import 'package:songdao/features/prayer/prayer_library_screen.dart';
import 'package:songdao/features/settings/settings_screen.dart';
import 'package:songdao/l10n/app_localizations.dart';

void main() {
  group('async feature states', () {
    testWidgets('Calendar shows an empty state for an empty dataset', (
      tester,
    ) async {
      final db = _openTestDb();
      addTearDown(db.close);

      await tester.pumpWidget(
        _testApp(
          const CalendarScreen(),
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async => []),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thêm sự kiện'), findsOneWidget);
      expect(find.text('CN'), findsOneWidget);
    });

    testWidgets('Calendar shows an error and retries without changing state', (
      tester,
    ) async {
      final db = _openTestDb();
      addTearDown(db.close);
      var attempts = 0;

      await tester.pumpWidget(
        _testApp(
          const CalendarScreen(),
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async {
              attempts++;
              if (attempts == 1) {
                throw Exception('calendar test failure');
              }
              return [];
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa thể cập nhật lịch phụng vụ'), findsOneWidget);
      expect(find.text('Thêm sự kiện'), findsOneWidget);
      await tester.tap(find.text('Tải lại'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('Chưa thể cập nhật lịch phụng vụ'), findsNothing);
      expect(find.text('Thêm sự kiện'), findsOneWidget);
    });

    testWidgets('Church Finder shows an empty state for an empty dataset', (
      tester,
    ) async {
      final db = _openTestDb();
      addTearDown(db.close);

      await tester.pumpWidget(
        _testApp(
          const ChurchSearchScreen(),
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async => []),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Chưa tìm thấy giáo xứ trong gói dữ liệu hiện tại. Bạn vẫn có thể dùng Today và Progress offline.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Church Finder shows an error and retries', (tester) async {
      final db = _openTestDb();
      addTearDown(db.close);
      var attempts = 0;

      await tester.pumpWidget(
        _testApp(
          const ChurchSearchScreen(),
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async {
              attempts++;
              if (attempts == 1) {
                throw Exception('church test failure');
              }
              return [];
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không thể tải nội dung'), findsOneWidget);
      await tester.tap(find.text('Tải lại'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(
        find.text(
          'Chưa tìm thấy giáo xứ trong gói dữ liệu hiện tại. Bạn vẫn có thể dùng Today và Progress offline.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Prayer shows an error and retries', (tester) async {
      final db = _openTestDb();
      addTearDown(db.close);
      var attempts = 0;

      await tester.pumpWidget(
        _testApp(
          const PrayerLibraryScreen(),
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async {
              attempts++;
              if (attempts == 1) {
                throw Exception('prayer test failure');
              }
              return [];
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không thể tải nội dung'), findsOneWidget);
      await tester.tap(find.text('Tải lại'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('Cầu nguyện'), findsWidgets);
    });

    testWidgets('Journal remains available when content bootstrap fails', (
      tester,
    ) async {
      final db = _openTestDb();
      addTearDown(db.close);
      await db
          .into(db.dailyActions)
          .insert(
            DailyActionsCompanion.insert(
              id: 'journal-action',
              date: '2026-07-31',
              sourceRule: 'test',
              prompt: 'Giữ một phút thinh lặng.',
              type: 'prayer',
              priority: 1,
              locale: 'vi',
            ),
          );
      await db
          .into(db.actionLogs)
          .insert(
            ActionLogsCompanion.insert(
              id: 'journal-log',
              actionId: 'journal-action',
              date: '2026-07-31',
              note: const Value('Một ghi chú riêng.'),
            ),
          );

      await tester.pumpWidget(
        _testApp(
          const JournalScreen(),
          overrides: [
            databaseProvider.overrideWithValue(db),
            seedContentBootstrapProvider.overrideWith((ref) async {
              throw Exception('bootstrap unavailable');
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Một ghi chú riêng.'), findsOneWidget);
      expect(find.text('Không thể tải nội dung'), findsNothing);
    });

    testWidgets('Progress shows an empty state for an empty dataset', (
      tester,
    ) async {
      final db = _openTestDb();
      addTearDown(db.close);

      await tester.pumpWidget(
        _testApp(
          const ProgressScreen(),
          overrides: [databaseProvider.overrideWithValue(db)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có việc hoàn thành'), findsOneWidget);
    });

    testWidgets('Progress shows an error for a failed future', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const ProgressScreen(),
          overrides: [
            databaseProvider.overrideWith((ref) {
              throw StateError('progress test failure');
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không thể tải nội dung'), findsOneWidget);
    });

    testWidgets('Settings renders defaults for an empty settings database', (
      tester,
    ) async {
      final db = _openTestDb();
      addTearDown(db.close);

      await tester.pumpWidget(
        _testApp(
          const SettingsScreen(),
          overrides: [
            databaseProvider.overrideWithValue(db),
            appInfoServiceProvider.overrideWithValue(
              const _FakeAppInfoService(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Lịch Việt'), findsOneWidget);
    });

    testWidgets('Settings shows an error for a failed future', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const SettingsScreen(),
          overrides: [
            databaseProvider.overrideWith((ref) {
              throw StateError('settings test failure');
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không thể tải nội dung'), findsOneWidget);
    });
  });
}

AppDatabase _openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

Widget _testApp(Widget home, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

class _FakeAppInfoService extends AppInfoService {
  const _FakeAppInfoService();

  @override
  Future<AppVersionInfo> versionInfo() async {
    return const AppVersionInfo(version: '0.1.0', buildNumber: '3');
  }
}
