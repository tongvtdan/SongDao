import 'package:flutter/material.dart';

import '../../data/local/app_database.dart';
import '../../data/local/user_event_repository.dart';
import '../../l10n/app_localizations.dart';

String userEventTypeLabel(AppLocalizations l10n, UserEventType type) {
  return switch (type) {
    UserEventType.general => l10n.eventTypeGeneral,
    UserEventType.deathAnniversary => l10n.eventTypeDeathAnniversary,
    UserEventType.baptismAnniversary => l10n.eventTypeBaptismAnniversary,
    UserEventType.patronalFeast => l10n.eventTypePatronalFeast,
    UserEventType.weddingAnniversary => l10n.eventTypeWeddingAnniversary,
  };
}

IconData userEventTypeIcon(UserEventType type) {
  return switch (type) {
    UserEventType.general => Icons.event_outlined,
    UserEventType.deathAnniversary => Icons.local_florist_outlined,
    UserEventType.baptismAnniversary => Icons.water_drop_outlined,
    UserEventType.patronalFeast => Icons.church_outlined,
    UserEventType.weddingAnniversary => Icons.favorite_outline,
  };
}

String eventCalendarSystemLabel(
  AppLocalizations l10n,
  EventCalendarSystem system,
) {
  return system == EventCalendarSystem.solar
      ? l10n.eventCalendarSolar
      : l10n.eventCalendarLunar;
}

String eventRecurrenceLabel(AppLocalizations l10n, EventRecurrence recurrence) {
  return switch (recurrence) {
    EventRecurrence.once => l10n.eventRecurrenceOnce,
    EventRecurrence.daily => l10n.eventRecurrenceDaily,
    EventRecurrence.weekly => l10n.eventRecurrenceWeekly,
    EventRecurrence.monthly => l10n.eventRecurrenceMonthly,
    EventRecurrence.yearly => l10n.eventRecurrenceYearly,
  };
}

String userEventColorLabel(AppLocalizations l10n, UserEventColor color) {
  return switch (color) {
    UserEventColor.burgundy => l10n.eventColorBurgundy,
    UserEventColor.blue => l10n.eventColorBlue,
    UserEventColor.teal => l10n.eventColorTeal,
    UserEventColor.green => l10n.eventColorGreen,
    UserEventColor.gold => l10n.eventColorGold,
    UserEventColor.orange => l10n.eventColorOrange,
    UserEventColor.purple => l10n.eventColorPurple,
    UserEventColor.gray => l10n.eventColorGray,
  };
}

Color userEventColorValue(UserEventColor color) {
  return switch (color) {
    UserEventColor.burgundy => const Color(0xFF8A1C3A),
    UserEventColor.blue => const Color(0xFF2563EB),
    UserEventColor.teal => const Color(0xFF0F766E),
    UserEventColor.green => const Color(0xFF2E7D32),
    UserEventColor.gold => const Color(0xFFB7791F),
    UserEventColor.orange => const Color(0xFFEA580C),
    UserEventColor.purple => const Color(0xFF7C3AED),
    UserEventColor.gray => const Color(0xFF64748B),
  };
}

String eventReminderLabel(AppLocalizations l10n, UserEvent event) {
  final offset =
      event.reminderOffsetMinutes ??
      (event.reminderOffsetDays == null
          ? null
          : event.reminderOffsetDays! * 1440);
  if (offset == null) {
    return '';
  }
  if (event.eventHour != null) {
    return switch (offset) {
      0 => l10n.eventReminderAtTime,
      5 => l10n.eventReminderMinutesBefore(5),
      10 => l10n.eventReminderMinutesBefore(10),
      15 => l10n.eventReminderMinutesBefore(15),
      30 => l10n.eventReminderMinutesBefore(30),
      60 => l10n.eventReminderHoursBefore(1),
      120 => l10n.eventReminderHoursBefore(2),
      1440 => l10n.eventReminderDaysBefore(1),
      10080 => l10n.eventReminderWeekBefore,
      _ => l10n.eventReminderEnable,
    };
  }
  return switch (offset) {
    0 => l10n.eventReminderSameDay,
    1440 => l10n.eventReminderDaysBefore(1),
    2880 => l10n.eventReminderDaysBefore(2),
    4320 => l10n.eventReminderDaysBefore(3),
    10080 => l10n.eventReminderWeekBefore,
    _ => l10n.eventReminderEnable,
  };
}
