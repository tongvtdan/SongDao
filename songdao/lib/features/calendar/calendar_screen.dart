import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/design_system.dart';
import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/user_event_repository.dart';
import '../../l10n/app_localizations.dart';
import '../shared/widgets/async_state_view.dart';
import 'calendar_controller.dart';
import 'user_event_editor_screen.dart';
import 'user_event_localization.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key, this.initialDate, this.focusedEventId});

  final DateTime? initialDate;
  final int? focusedEventId;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late final CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(
      database: ref.read(databaseProvider),
      settings: ref.read(userSettingsRepositoryProvider),
      dailyActionEngine: ref.read(dailyActionEngineProvider),
      userEvents: ref.read(userEventRepositoryProvider),
      eventReminders: ref.read(eventReminderServiceProvider),
      bootstrapContent: () async {
        await ref.read(seedContentBootstrapProvider.future);
      },
      invalidateBootstrap: () {
        ref.invalidate(seedContentBootstrapProvider);
      },
      initialDate: widget.initialDate,
      focusedEventId: widget.focusedEventId,
    );
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addEvent() async {
    final result = await context.push<EventEditorResult>(
      '/calendar/events/new?date=${dateKey(_controller.selectedDate)}',
    );
    await _handleEditorResult(result);
  }

  Future<void> _editEvent(int eventId) async {
    final result = await context.push<EventEditorResult>(
      '/calendar/events/$eventId/edit',
    );
    await _handleEditorResult(result);
  }

  Future<void> _handleEditorResult(EventEditorResult? result) async {
    if (result == null || !mounted) {
      return;
    }
    await _controller.load();
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final message = result == EventEditorResult.savedWithoutReminderPermission
        ? l10n.calendarEventReminderPermissionDenied
        : l10n.calendarEventSaved;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteEvent(int eventId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.calendarDeleteEventTitle),
        content: Text(l10n.calendarDeleteEventMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _controller.deleteEvent(eventId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.calendarEventDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendarTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvent,
        tooltip: l10n.calendarAddEvent,
        icon: const Icon(Icons.add),
        label: Text(l10n.calendarAddEvent),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final data = _controller.data;
          if (_controller.isLoading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.error != null && data == null) {
            return AsyncErrorState(onRetry: _controller.load);
          }
          if (data == null) {
            return const SizedBox.shrink();
          }
          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              _CalendarHeader(
                month: _controller.visibleMonth,
                onPrevious: () => _controller.changeMonth(-1),
                onNext: () => _controller.changeMonth(1),
              ),
              const SizedBox(height: 12),
              if (data.liturgicalBootstrapFailed) ...[
                _LiturgicalWarning(onRetry: _controller.retryLiturgicalContent),
                const SizedBox(height: 12),
              ],
              _MonthGrid(
                month: _controller.visibleMonth,
                days: data.days,
                eventsByDate: data.occurrencesByDate,
                selectedDate: dateKey(_controller.selectedDate),
                onSelect: _controller.selectDate,
              ),
              const SizedBox(height: 14),
              if (data.days.values.every(
                (day) =>
                    DateTime.parse(day.date).month !=
                    _controller.visibleMonth.month,
              )) ...[
                AsyncEmptyState(
                  title: l10n.calendarEmptyTitle,
                  message: l10n.calendarEmptyMessage,
                ),
                const SizedBox(height: 14),
              ],
              _UserEventsCard(
                events: data.selectedEvents,
                onEdit: _editEvent,
                onDelete: _deleteEvent,
              ),
              const SizedBox(height: 14),
              if (data.selectedDay == null)
                AppBentoCard(child: Text(l10n.calendarNoLiturgicalDay))
              else
                _LiturgicalDayCard(data: data),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        IconButton(
          tooltip: l10n.calendarPreviousMonth,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                l10n.calendarMonthYear(month.month, month.year),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.calendarLocalDataSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.calendarNextMonth,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _LiturgicalWarning extends StatelessWidget {
  const _LiturgicalWarning({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBentoCard(
      accentColor: AppColors.statusWarning,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.statusWarning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.calendarLiturgicalUnavailableTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(l10n.calendarLiturgicalUnavailableMessage),
                TextButton(onPressed: onRetry, child: Text(l10n.retry)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.days,
    required this.eventsByDate,
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime month;
  final Map<String, CalendarDay> days;
  final Map<String, List<UserEventOccurrence>> eventsByDate;
  final String selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final first = DateTime(month.year, month.month, 1);
    final gridStart = first.subtract(Duration(days: first.weekday % 7));
    final todayKey = dateKey(DateTime.now());
    final labels = [
      l10n.weekdayShortSunday,
      l10n.weekdayShortMonday,
      l10n.weekdayShortTuesday,
      l10n.weekdayShortWednesday,
      l10n.weekdayShortThursday,
      l10n.weekdayShortFriday,
      l10n.weekdayShortSaturday,
    ];

    return AppBentoCard(
      child: Column(
        children: [
          Row(
            children: [
              for (var index = 0; index < labels.length; index += 1)
                _WeekdayLabel(labels[index], sunday: index == 0),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final date = gridStart.add(Duration(days: index));
              final key = dateKey(date);
              final day = days[key];
              final eventColors = <Color>[];
              for (final occurrence
                  in eventsByDate[key] ?? const <UserEventOccurrence>[]) {
                final eventColor = userEventColorValue(
                  UserEventColor.fromStorage(occurrence.event.color),
                );
                if (!eventColors.contains(eventColor)) {
                  eventColors.add(eventColor);
                }
              }
              final hasEvents = eventColors.isNotEmpty;
              final inMonth = date.month == month.month;
              final selected = key == selectedDate;
              final isToday = key == todayKey;
              final color = day == null
                  ? AppColors.textTertiary
                  : liturgicalColor(day.color);

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onSelect(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.brand
                        : isToday
                        ? AppColors.brandSoft
                        : day == null
                        ? Colors.transparent
                        : color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppColors.brand
                          : day == null && !hasEvents
                          ? Colors.transparent
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? Colors.white
                              : inMonth
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          fontWeight: isToday || selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CalendarMarker(
                            visible: day != null,
                            color: selected
                                ? Colors.white
                                : color == LiturgicalColors.white
                                ? AppColors.gold
                                : color,
                          ),
                          if (day != null && hasEvents)
                            const SizedBox(width: 3),
                          for (
                            var eventIndex = 0;
                            eventIndex < eventColors.length && eventIndex < 3;
                            eventIndex += 1
                          )
                            _CalendarMarker(
                              key: eventIndex == 0
                                  ? ValueKey('user-event-marker-$key')
                                  : ValueKey(
                                      'user-event-marker-$key-$eventIndex',
                                    ),
                              visible: true,
                              color: eventColors[eventIndex],
                              square: true,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarMarker extends StatelessWidget {
  const _CalendarMarker({
    super.key,
    required this.visible,
    required this.color,
    this.square = false,
  });

  final bool visible;
  final Color color;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: visible ? color : Colors.transparent,
        borderRadius: square ? BorderRadius.circular(1) : null,
        shape: square ? BoxShape.rectangle : BoxShape.circle,
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label, {this.sunday = false});

  final String label;
  final bool sunday;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: sunday ? AppColors.burgundy : AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _UserEventsCard extends StatelessWidget {
  const _UserEventsCard({
    required this.events,
    required this.onEdit,
    required this.onDelete,
  });

  final List<UserEventOccurrence> events;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBentoCard(
      accentColor: AppColors.burgundy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.calendarEventsSectionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.burgundy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            Text(
              l10n.calendarNoEvents,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            )
          else
            for (var index = 0; index < events.length; index += 1) ...[
              if (index > 0) const SizedBox(height: 10),
              _UserEventRow(
                occurrence: events[index],
                onEdit: () => onEdit(events[index].event.id),
                onDelete: () => onDelete(events[index].event.id),
              ),
            ],
        ],
      ),
    );
  }
}

class _UserEventRow extends StatelessWidget {
  const _UserEventRow({
    required this.occurrence,
    required this.onEdit,
    required this.onDelete,
  });

  final UserEventOccurrence occurrence;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = occurrence.event;
    final type = UserEventType.fromStorage(event.type);
    final eventColor = userEventColorValue(
      UserEventColor.fromStorage(event.color),
    );
    return Semantics(
      container: true,
      label: userEventColorLabel(l10n, UserEventColor.fromStorage(event.color)),
      child: AppBentoCard(
        accentColor: eventColor,
        gradient: LinearGradient(
          colors: [eventColor.withValues(alpha: 0.12), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(userEventTypeIcon(type), color: eventColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      AppSignalChip(label: userEventTypeLabel(l10n, type)),
                      if (event.reminderOffsetMinutes != null ||
                          event.reminderOffsetDays != null)
                        AppSignalChip(
                          icon: Icons.notifications_outlined,
                          label: eventReminderLabel(l10n, event),
                        ),
                    ],
                  ),
                  if (event.note != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.note!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.calendarEditEvent,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: l10n.calendarDeleteEvent,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiturgicalDayCard extends StatelessWidget {
  const _LiturgicalDayCard({required this.data});

  final CalendarState data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final day = data.selectedDay!;
    final celebration = data.celebrations.isEmpty
        ? _formatCalendarDate(l10n, day.date)
        : data.celebrations.first.name;
    final showLunar =
        data.locale == 'vi' && data.showLunarDate && day.lunarDate != null;
    final accentColor = _liturgicalAccentColor(day.color);

    return AppBentoCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            celebration,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppSignalChip(
                label: _seasonLabel(l10n, day.season),
                color: accentColor,
              ),
              AppSignalChip(label: _colorLabel(l10n, day.color)),
              if (showLunar) AppSignalChip(label: day.lunarDate!),
            ],
          ),
          if (data.action != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.calendarPracticeTitle,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.brand,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(data.action!.prompt),
          ],
          if (data.readings.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              l10n.calendarReadingsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            for (final reading in data.readings)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${reading.displayLabel ?? _readingLabel(l10n, reading.type)}: ${reading.citation}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
          if (data.reflection != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              data.reflection!.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              data.reflection!.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatCalendarDate(AppLocalizations l10n, String date) {
  final parsed = DateTime.parse(date);
  final weekday = switch (parsed.weekday) {
    DateTime.monday => l10n.weekdayMonday,
    DateTime.tuesday => l10n.weekdayTuesday,
    DateTime.wednesday => l10n.weekdayWednesday,
    DateTime.thursday => l10n.weekdayThursday,
    DateTime.friday => l10n.weekdayFriday,
    DateTime.saturday => l10n.weekdaySaturday,
    _ => l10n.weekdaySunday,
  };
  return '$weekday, ${DateFormat('dd/MM/yyyy').format(parsed)}';
}

String _seasonLabel(AppLocalizations l10n, String season) {
  return switch (season) {
    'advent' => l10n.calendarSeasonAdvent,
    'christmas' => l10n.calendarSeasonChristmas,
    'lent' => l10n.calendarSeasonLent,
    'easter' => l10n.calendarSeasonEaster,
    'ordinary' => l10n.calendarSeasonOrdinary,
    _ => l10n.calendarSeasonLocal,
  };
}

String _colorLabel(AppLocalizations l10n, String color) {
  return switch (color) {
    'green' => l10n.calendarColorGreen,
    'white' => l10n.calendarColorWhite,
    'gold' => l10n.calendarColorGold,
    'red' => l10n.calendarColorRed,
    'purple' => l10n.calendarColorPurple,
    'rose' => l10n.calendarColorRose,
    'black' => l10n.calendarColorBlack,
    _ => l10n.calendarColorLiturgical,
  };
}

Color _liturgicalAccentColor(String color) {
  return color == 'white' ? AppColors.gold : liturgicalColor(color);
}

String _readingLabel(AppLocalizations l10n, String type) {
  return switch (type) {
    'first' || 'first_reading' => l10n.calendarReadingFirst,
    'second' || 'second_reading' => l10n.calendarReadingSecond,
    'psalm' => l10n.calendarReadingPsalm,
    'alleluia' || 'gospel_acclamation' => l10n.calendarReadingAlleluia,
    'gospel' => l10n.calendarReadingGospel,
    _ => l10n.calendarReadingDefault,
  };
}
