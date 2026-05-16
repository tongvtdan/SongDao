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
  String get settingsParishTitle => 'My parish';

  @override
  String get settingsParishUnset =>
      'Optional for beta. Choose a parish manually only if it appears in the local seed pack.';

  @override
  String get settingsParishSelected =>
      'Your parish is saved on this device. You can change it anytime.';

  @override
  String get settingsParishButton => 'My parish';

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
}
