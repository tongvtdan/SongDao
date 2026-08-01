// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabToday => 'Today';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabPray => 'Pray';

  @override
  String get tabChurch => 'Church';

  @override
  String get tabProgress => 'Progress';

  @override
  String get prayerTagDaily => 'Daily';

  @override
  String get prayerTagMorning => 'Morning';

  @override
  String get prayerTagEvening => 'Evening';

  @override
  String get prayerTagReflection => 'Examen';

  @override
  String get prayerTagWork => 'Work';

  @override
  String get prayerTagPeace => 'Peace';

  @override
  String get asyncErrorTitle => 'Unable to load this content';

  @override
  String get asyncErrorMessage =>
      'Your data stays on this device. Try loading it again.';

  @override
  String get retry => 'Try again';

  @override
  String get calendarEmptyTitle => 'No liturgical calendar data';

  @override
  String get calendarEmptyMessage =>
      'This month is not included in the calendar pack on this device.';

  @override
  String get progressEmptyTitle => 'No completed actions yet';

  @override
  String get progressEmptyMessage =>
      'Complete one small action today to start your rhythm.';
}
