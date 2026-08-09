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

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String calendarMonthYear(int month, int year) {
    return 'Month $month, $year';
  }

  @override
  String get calendarLocalDataSubtitle =>
      'Liturgical data and events on this device';

  @override
  String get calendarLiturgicalUnavailableTitle =>
      'Unable to update the liturgical calendar';

  @override
  String get calendarLiturgicalUnavailableMessage =>
      'Personal events are still available. Try loading the liturgical data again.';

  @override
  String get calendarNoLiturgicalDay =>
      'No liturgical data for this date is included on this device.';

  @override
  String get calendarEventsSectionTitle => 'Your events';

  @override
  String get calendarNoEvents => 'No events for this date.';

  @override
  String get calendarAddEvent => 'Add event';

  @override
  String get calendarEditEvent => 'Edit event';

  @override
  String get calendarDeleteEvent => 'Delete event';

  @override
  String get calendarDeleteEventTitle => 'Delete event?';

  @override
  String get calendarDeleteEventMessage =>
      'This event and all yearly occurrences will be removed from this device.';

  @override
  String get calendarEventSaved => 'Event saved.';

  @override
  String get calendarEventDeleted => 'Event deleted.';

  @override
  String get calendarEventReminderPermissionDenied =>
      'The event was saved with reminders off. You can enable notification permission in system settings.';

  @override
  String get calendarEventReminderLimit =>
      'You can enable reminders for up to 50 events.';

  @override
  String get calendarEventReminderPast =>
      'The reminder time for this one-time event has passed.';

  @override
  String get eventTypeLabel => 'Event type';

  @override
  String get eventTypeGeneral => 'Event';

  @override
  String get eventTypeDeathAnniversary => 'Death anniversary';

  @override
  String get eventTypeBaptismAnniversary => 'Baptism anniversary';

  @override
  String get eventTypePatronalFeast => 'Patronal feast';

  @override
  String get eventTypeWeddingAnniversary => 'Wedding anniversary';

  @override
  String get eventTitleLabel => 'Event name';

  @override
  String get eventTitleHint => 'For example: Grandfather\'s death anniversary';

  @override
  String get eventTitleRequired => 'Enter an event name.';

  @override
  String get eventNoteLabel => 'Note';

  @override
  String get eventNoteHint => 'Private details you want to remember';

  @override
  String get eventPrivateNote => 'Stored only on your device.';

  @override
  String get eventCalendarSystemLabel => 'Calendar system';

  @override
  String get eventCalendarSolar => 'Gregorian';

  @override
  String get eventCalendarLunar => 'Lunar';

  @override
  String get eventDateLabel => 'Event date';

  @override
  String get eventDayLabel => 'Day';

  @override
  String get eventMonthLabel => 'Month';

  @override
  String get eventYearLabel => 'Year';

  @override
  String get eventLunarLeapMonth => 'Leap month';

  @override
  String eventSolarEquivalent(String date) {
    return 'Gregorian: $date';
  }

  @override
  String eventLunarEquivalent(String date) {
    return 'Lunar: $date';
  }

  @override
  String get eventRecurrenceLabel => 'Repeat';

  @override
  String get eventRecurrenceOnce => 'Once';

  @override
  String get eventRecurrenceDaily => 'Every day';

  @override
  String get eventRecurrenceWeekly => 'Every week';

  @override
  String get eventRecurrenceMonthly => 'Every month';

  @override
  String get eventRecurrenceYearly => 'Every year';

  @override
  String get eventEditSeriesNote =>
      'Changes apply to the entire recurring series.';

  @override
  String get eventAllDay => 'All day';

  @override
  String get eventStartTime => 'Start time';

  @override
  String get eventColorLabel => 'Event color';

  @override
  String get eventColorBurgundy => 'Burgundy';

  @override
  String get eventColorBlue => 'Blue';

  @override
  String get eventColorTeal => 'Teal';

  @override
  String get eventColorGreen => 'Green';

  @override
  String get eventColorGold => 'Gold';

  @override
  String get eventColorOrange => 'Orange';

  @override
  String get eventColorPurple => 'Purple';

  @override
  String get eventColorGray => 'Gray';

  @override
  String get eventReminderLabel => 'Event reminder';

  @override
  String get eventReminderEnable => 'Enable reminder';

  @override
  String get eventReminderAtTime => 'At event time';

  @override
  String eventReminderMinutesBefore(int minutes) {
    return '$minutes minutes before';
  }

  @override
  String eventReminderHoursBefore(int hours) {
    return '$hours hours before';
  }

  @override
  String eventReminderDaysBefore(int days) {
    return '$days days before';
  }

  @override
  String get eventReminderWeekBefore => 'One week before';

  @override
  String get eventReminderSameDay => 'Same day';

  @override
  String get eventReminderDayBefore => 'One day before';

  @override
  String get eventReminderTime => 'Reminder time';

  @override
  String get eventReminderTodayTitle => 'Event today';

  @override
  String get eventReminderUpcomingTitle => 'Event tomorrow';

  @override
  String get eventReminderScheduledTitle => 'Upcoming event';

  @override
  String get eventReminderChannelName => 'Personal events';

  @override
  String get eventReminderChannelDescription =>
      'Reminders for anniversaries saved in SongDao.';

  @override
  String get eventInvalidDate => 'The selected date is invalid.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get calendarPracticeTitle => 'Daily practice';

  @override
  String get calendarReadingsTitle => 'Readings';

  @override
  String get calendarSeasonAdvent => 'Advent';

  @override
  String get calendarSeasonChristmas => 'Christmas';

  @override
  String get calendarSeasonLent => 'Lent';

  @override
  String get calendarSeasonEaster => 'Easter';

  @override
  String get calendarSeasonOrdinary => 'Ordinary Time';

  @override
  String get calendarSeasonLocal => 'Local data';

  @override
  String get calendarColorGreen => 'Green';

  @override
  String get calendarColorWhite => 'White';

  @override
  String get calendarColorGold => 'Gold';

  @override
  String get calendarColorRed => 'Red';

  @override
  String get calendarColorPurple => 'Purple';

  @override
  String get calendarColorRose => 'Rose';

  @override
  String get calendarColorBlack => 'Black';

  @override
  String get calendarColorLiturgical => 'Liturgical';

  @override
  String get calendarReadingFirst => 'First reading';

  @override
  String get calendarReadingSecond => 'Second reading';

  @override
  String get calendarReadingPsalm => 'Psalm';

  @override
  String get calendarReadingAlleluia => 'Alleluia';

  @override
  String get calendarReadingGospel => 'Gospel';

  @override
  String get calendarReadingDefault => 'Reading';

  @override
  String get weekdayShortSunday => 'Sun';

  @override
  String get weekdayShortMonday => 'Mon';

  @override
  String get weekdayShortTuesday => 'Tue';

  @override
  String get weekdayShortWednesday => 'Wed';

  @override
  String get weekdayShortThursday => 'Thu';

  @override
  String get weekdayShortFriday => 'Fri';

  @override
  String get weekdayShortSaturday => 'Sat';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';
}
