import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../l10n/app_localizations.dart';
import '../../notifications/local_notification_service.dart';
import 'app_database.dart';
import 'user_event_repository.dart';
import 'user_settings_repository.dart';
import 'vietnamese_lunar_calendar_service.dart';

class EventReminderRefreshResult {
  const EventReminderRefreshResult({
    required this.scheduledCount,
    required this.skippedCount,
  });

  final int scheduledCount;
  final int skippedCount;
}

class EventReminderService {
  EventReminderService(
    this._repository,
    this._settings,
    this._notifications, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const int maxScheduledEvents = 50;
  static const int reminderHorizonYears = 3;

  final UserEventRepository _repository;
  final UserSettingsRepository _settings;
  final LocalNotificationService _notifications;
  final DateTime Function() _now;

  Future<bool> requestPermission() async {
    try {
      return await _notifications.requestReminderPermission();
    } on Object {
      return false;
    }
  }

  Future<EventReminderRefreshResult> refreshScheduledReminders() async {
    await _notifications.configureTimezone();
    await _notifications.cancelAllPersonalEventReminders();

    final now = _now();
    final start = DateTime(now.year, now.month, now.day);
    final endYear = (now.year + reminderHorizonYears).clamp(
      start.year,
      VietnameseLunarCalendarService.maxYear,
    );
    final end = DateTime(endYear, 12, 31);
    final candidates = <_ReminderCandidate>[];

    for (final event in await _repository.getReminderEnabledEvents()) {
      final nativeComponents = _nativeComponents(event);
      if (nativeComponents != null) {
        final scheduledDate = _nextScheduledDate(event, start, end, now);
        if (scheduledDate != null) {
          candidates.add(
            _ReminderCandidate(
              event: event,
              scheduledDate: scheduledDate,
              matchDateTimeComponents: nativeComponents,
            ),
          );
        }
        continue;
      }

      for (final occurrence in _repository.occurrencesForEventBetween(
        event,
        start,
        end,
      )) {
        final scheduledDate = _scheduledDate(event, occurrence.date);
        if (scheduledDate.isAfter(now)) {
          candidates.add(
            _ReminderCandidate(event: event, scheduledDate: scheduledDate),
          );
        }
      }
    }

    candidates.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final locale = await _settings.locale();
    final l10n = lookupAppLocalizations(Locale(locale));
    final scheduled = candidates
        .take(LocalNotificationService.maxPersonalEventReminders)
        .toList();

    for (var index = 0; index < scheduled.length; index += 1) {
      final candidate = scheduled[index];
      final offset = _reminderOffsetMinutes(candidate.event);
      await _notifications.schedulePersonalEventReminder(
        notificationId: _notifications.personalEventNotificationId(index),
        scheduledDate: candidate.scheduledDate,
        title: _reminderTitle(l10n, candidate.event, offset),
        body: candidate.event.title,
        payload: NotificationRoutes.calendarEventUri(candidate.event.id),
        matchDateTimeComponents: candidate.matchDateTimeComponents,
        channelName: l10n.eventReminderChannelName,
        channelDescription: l10n.eventReminderChannelDescription,
      );
    }

    return EventReminderRefreshResult(
      scheduledCount: scheduled.length,
      skippedCount: candidates.length - scheduled.length,
    );
  }

  DateTime _scheduledDate(UserEvent event, DateTime occurrenceDate) {
    final offset = _reminderOffsetMinutes(event)!;
    final eventHour = event.eventHour;
    final eventMinute = event.eventMinute;
    if (eventHour != null && eventMinute != null) {
      return DateTime(
        occurrenceDate.year,
        occurrenceDate.month,
        occurrenceDate.day,
        eventHour,
        eventMinute,
      ).subtract(Duration(minutes: offset));
    }

    final reminderDay = occurrenceDate.subtract(
      Duration(days: offset ~/ Duration.minutesPerDay),
    );
    return DateTime(
      reminderDay.year,
      reminderDay.month,
      reminderDay.day,
      event.reminderHour ?? 19,
      event.reminderMinute ?? 0,
    );
  }

  DateTime? _nextScheduledDate(
    UserEvent event,
    DateTime start,
    DateTime end,
    DateTime now,
  ) {
    for (final occurrence in _repository.occurrencesForEventBetween(
      event,
      start,
      end,
    )) {
      final scheduledDate = _scheduledDate(event, occurrence.date);
      if (scheduledDate.isAfter(now)) {
        return scheduledDate;
      }
    }
    return null;
  }

  int? _reminderOffsetMinutes(UserEvent event) =>
      event.reminderOffsetMinutes ??
      (event.reminderOffsetDays == null
          ? null
          : event.reminderOffsetDays! * Duration.minutesPerDay);

  DateTimeComponents? _nativeComponents(UserEvent event) {
    final recurrence = EventRecurrence.fromStorage(event.recurrence);
    final system = EventCalendarSystem.fromStorage(event.calendarSystem);
    final offset = _reminderOffsetMinutes(event);
    if (offset == null || system == EventCalendarSystem.lunar) {
      return null;
    }

    return switch (recurrence) {
      EventRecurrence.daily => DateTimeComponents.time,
      EventRecurrence.weekly => DateTimeComponents.dayOfWeekAndTime,
      EventRecurrence.monthly =>
        offset < Duration.minutesPerDay && event.anchorDay <= 28
            ? DateTimeComponents.dayOfMonthAndTime
            : null,
      EventRecurrence.yearly =>
        event.anchorMonth == DateTime.february && event.anchorDay == 29
            ? null
            : _isStableSolarYearlyReminder(event)
            ? DateTimeComponents.dateAndTime
            : null,
      EventRecurrence.once => null,
    };
  }

  bool _isStableSolarYearlyReminder(UserEvent event) {
    final firstYear = event.anchorYear;
    final lastYear = (firstYear + 399).clamp(
      firstYear,
      VietnameseLunarCalendarService.maxYear,
    );
    final occurrences = _repository.occurrencesForEventBetween(
      event,
      DateTime(firstYear, 1, 1),
      DateTime(lastYear, 12, 31),
    );
    if (occurrences.isEmpty) {
      return false;
    }

    final firstScheduled = _scheduledDate(event, occurrences.first.date);
    return occurrences.skip(1).every((occurrence) {
      final scheduled = _scheduledDate(event, occurrence.date);
      return scheduled.month == firstScheduled.month &&
          scheduled.day == firstScheduled.day &&
          scheduled.hour == firstScheduled.hour &&
          scheduled.minute == firstScheduled.minute;
    });
  }

  String _reminderTitle(AppLocalizations l10n, UserEvent event, int? offset) {
    if (event.eventHour == null && offset == 0) {
      return l10n.eventReminderTodayTitle;
    }
    if (event.eventHour == null && offset == Duration.minutesPerDay) {
      return l10n.eventReminderUpcomingTitle;
    }
    return l10n.eventReminderScheduledTitle;
  }
}

class _ReminderCandidate {
  const _ReminderCandidate({
    required this.event,
    required this.scheduledDate,
    this.matchDateTimeComponents,
  });

  final UserEvent event;
  final DateTime scheduledDate;
  final DateTimeComponents? matchDateTimeComponents;
}
