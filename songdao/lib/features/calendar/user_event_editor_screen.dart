import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/design_system.dart';
import '../../app/sentence_capitalization_formatter.dart';
import '../../app/theme.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/event_reminder_service.dart';
import '../../data/local/user_event_repository.dart';
import '../../data/local/vietnamese_lunar_calendar_service.dart';
import '../../l10n/app_localizations.dart';
import 'user_event_localization.dart';

enum EventEditorResult { saved, savedWithoutReminderPermission }

class UserEventEditorScreen extends ConsumerStatefulWidget {
  const UserEventEditorScreen({
    super.key,
    required this.initialDate,
    this.eventId,
  });

  final DateTime initialDate;
  final int? eventId;

  @override
  ConsumerState<UserEventEditorScreen> createState() =>
      _UserEventEditorScreenState();
}

class _UserEventEditorScreenState extends ConsumerState<UserEventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  UserEventType _type = UserEventType.general;
  EventCalendarSystem _calendarSystem = EventCalendarSystem.solar;
  EventRecurrence _recurrence = EventRecurrence.once;
  late DateTime _solarDate;
  late int _lunarYear;
  late int _lunarMonth;
  late int _lunarDay;
  bool _isLeapMonth = false;
  bool _allDay = true;
  TimeOfDay _eventTime = const TimeOfDay(hour: 19, minute: 0);
  UserEventColor _color = UserEventColor.burgundy;
  bool _reminderEnabled = false;
  int _reminderOffsetMinutes = 1440;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  bool _loading = false;
  bool _saving = false;
  Object? _loadError;

  VietnameseLunarCalendarService get _lunarCalendar =>
      ref.read(vietnameseLunarCalendarServiceProvider);

  @override
  void initState() {
    super.initState();
    _solarDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _setLunarFromSolar(_solarDate);
    if (widget.eventId != null) {
      _loading = true;
      _loadExisting();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    try {
      final event = await ref
          .read(userEventRepositoryProvider)
          .getById(widget.eventId!);
      if (event == null) {
        throw StateError('Event not found');
      }
      _applyEvent(event);
    } on Object catch (error) {
      _loadError = error;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyEvent(UserEvent event) {
    _type = UserEventType.fromStorage(event.type);
    _calendarSystem = EventCalendarSystem.fromStorage(event.calendarSystem);
    _recurrence = EventRecurrence.fromStorage(event.recurrence);
    _allDay = event.eventHour == null || event.eventMinute == null;
    _eventTime = TimeOfDay(
      hour: event.eventHour ?? 19,
      minute: event.eventMinute ?? 0,
    );
    _color = UserEventColor.fromStorage(event.color);
    _titleController.text = event.title;
    _noteController.text = event.note ?? '';
    _lunarYear = event.anchorYear;
    _lunarMonth = event.anchorMonth;
    _lunarDay = event.anchorDay;
    _isLeapMonth = event.isLeapMonth;
    if (_calendarSystem == EventCalendarSystem.solar) {
      _solarDate = DateTime(
        event.anchorYear,
        event.anchorMonth,
        event.anchorDay,
      );
      _setLunarFromSolar(_solarDate);
    } else {
      _solarDate = _lunarCalendar.lunarToSolarExact(_currentLunarDate);
    }
    _reminderEnabled =
        event.reminderOffsetMinutes != null || event.reminderOffsetDays != null;
    _reminderOffsetMinutes =
        event.reminderOffsetMinutes ?? (event.reminderOffsetDays ?? 1) * 1440;
    _reminderTime = TimeOfDay(
      hour: event.reminderHour ?? 19,
      minute: event.reminderMinute ?? 0,
    );
  }

  LunarDateValue get _currentLunarDate => LunarDateValue(
    year: _lunarYear,
    month: _lunarMonth,
    day: _lunarDay,
    isLeapMonth: _isLeapMonth,
  );

  void _setLunarFromSolar(DateTime date) {
    final lunar = _lunarCalendar.solarToLunar(date);
    _lunarYear = lunar.year;
    _lunarMonth = lunar.month;
    _lunarDay = lunar.day;
    _isLeapMonth = lunar.isLeapMonth;
  }

  void _changeType(UserEventType type) {
    final l10n = AppLocalizations.of(context)!;
    final oldDefault = userEventTypeLabel(l10n, _type);
    final currentTitle = _titleController.text.trim();
    setState(() {
      _type = type;
      _recurrence = type == UserEventType.general
          ? EventRecurrence.once
          : EventRecurrence.yearly;
      if (currentTitle.isEmpty || currentTitle == oldDefault) {
        _titleController.text = type == UserEventType.general
            ? ''
            : userEventTypeLabel(l10n, type);
      }
    });
  }

  void _changeCalendarSystem(EventCalendarSystem system) {
    if (system == _calendarSystem) {
      return;
    }
    setState(() {
      if (system == EventCalendarSystem.lunar) {
        _setLunarFromSolar(_solarDate);
      } else {
        final converted = _lunarCalendar.tryLunarToSolarExact(
          _currentLunarDate,
        );
        if (converted != null) {
          _solarDate = converted;
        }
      }
      _calendarSystem = system;
    });
  }

  void _changeLunarDate({int? year, int? month, int? day}) {
    setState(() {
      _lunarYear = year ?? _lunarYear;
      _lunarMonth = month ?? _lunarMonth;
      _lunarDay = day ?? _lunarDay;
      final leapMonth = _lunarCalendar.leapMonthForYear(_lunarYear);
      if (leapMonth != _lunarMonth) {
        _isLeapMonth = false;
      }
      final converted = _lunarCalendar.tryLunarToSolarExact(_currentLunarDate);
      if (converted != null) {
        _solarDate = converted;
      }
    });
  }

  Future<void> _pickSolarDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _solarDate,
      firstDate: DateTime(VietnameseLunarCalendarService.minYear),
      lastDate: DateTime(VietnameseLunarCalendarService.maxYear, 12, 31),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _solarDate = picked;
      _setLunarFromSolar(picked);
    });
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _pickEventTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eventTime,
    );
    if (picked != null) {
      setState(() => _eventTime = picked);
    }
  }

  DateTime _reminderDateFor(DateTime eventDate) {
    if (!_allDay) {
      return DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        _eventTime.hour,
        _eventTime.minute,
      ).subtract(Duration(minutes: _reminderOffsetMinutes));
    }
    final reminderDay = eventDate.subtract(
      Duration(days: _reminderOffsetMinutes ~/ Duration.minutesPerDay),
    );
    return DateTime(
      reminderDay.year,
      reminderDay.month,
      reminderDay.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );
  }

  void _toggleAllDay(bool value) {
    setState(() {
      _allDay = value;
      if (_allDay && !_isAllDayReminderOffset(_reminderOffsetMinutes)) {
        _reminderOffsetMinutes = 1440;
      }
    });
  }

  bool _isAllDayReminderOffset(int value) =>
      const [0, 1440, 2880, 4320, 10080].contains(value);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate() || _saving) {
      return;
    }
    final selectedSolarDate = _calendarSystem == EventCalendarSystem.solar
        ? _solarDate
        : _lunarCalendar.tryLunarToSolarExact(_currentLunarDate);
    if (selectedSolarDate == null) {
      _showMessage(l10n.eventInvalidDate);
      return;
    }
    if (_reminderEnabled && _recurrence == EventRecurrence.once) {
      final reminderDate = _reminderDateFor(selectedSolarDate);
      if (!reminderDate.isAfter(DateTime.now())) {
        _showMessage(l10n.calendarEventReminderPast);
        return;
      }
    }

    setState(() => _saving = true);
    var reminderAllowed = true;
    try {
      if (_reminderEnabled) {
        final reminderCount = await ref
            .read(userEventRepositoryProvider)
            .countReminderEnabled(excludingId: widget.eventId);
        if (reminderCount >= EventReminderService.maxScheduledEvents) {
          _showMessage(l10n.calendarEventReminderLimit);
          return;
        }
        reminderAllowed = await ref
            .read(eventReminderServiceProvider)
            .requestPermission();
      }

      final draft = UserEventDraft(
        type: _type,
        title: _titleController.text,
        note: _noteController.text,
        calendarSystem: _calendarSystem,
        anchorYear: _calendarSystem == EventCalendarSystem.solar
            ? _solarDate.year
            : _lunarYear,
        anchorMonth: _calendarSystem == EventCalendarSystem.solar
            ? _solarDate.month
            : _lunarMonth,
        anchorDay: _calendarSystem == EventCalendarSystem.solar
            ? _solarDate.day
            : _lunarDay,
        isLeapMonth:
            _calendarSystem == EventCalendarSystem.lunar && _isLeapMonth,
        recurrence: _recurrence,
        eventHour: _allDay ? null : _eventTime.hour,
        eventMinute: _allDay ? null : _eventTime.minute,
        color: _color,
        reminderOffsetMinutes: _reminderEnabled && reminderAllowed
            ? _reminderOffsetMinutes
            : null,
        reminderHour: _reminderEnabled && reminderAllowed && _allDay
            ? _reminderTime.hour
            : null,
        reminderMinute: _reminderEnabled && reminderAllowed && _allDay
            ? _reminderTime.minute
            : null,
      );
      final repository = ref.read(userEventRepositoryProvider);
      if (widget.eventId == null) {
        await repository.create(draft);
      } else {
        await repository.updateEvent(widget.eventId!, draft);
      }
      await ref.read(eventReminderServiceProvider).refreshScheduledReminders();
      if (mounted) {
        Navigator.of(context).pop(
          reminderAllowed
              ? EventEditorResult.saved
              : EventEditorResult.savedWithoutReminderPermission,
        );
      }
    } on UserEventValidationException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.calendarEditEvent)),
        body: Center(child: Text(l10n.asyncErrorTitle)),
      );
    }

    final leapMonth = _lunarCalendar.leapMonthForYear(_lunarYear);
    final convertedLunarDate = _lunarCalendar.tryLunarToSolarExact(
      _currentLunarDate,
    );
    final lunarLabel = _lunarCalendar.solarToLunar(_solarDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eventId == null
              ? l10n.calendarAddEvent
              : l10n.calendarEditEvent,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            AppBentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<UserEventType>(
                    initialValue: _type,
                    decoration: InputDecoration(labelText: l10n.eventTypeLabel),
                    items: [
                      for (final type in UserEventType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(userEventTypeIcon(type), size: 18),
                              const SizedBox(width: 8),
                              Text(userEventTypeLabel(l10n, type)),
                            ],
                          ),
                        ),
                    ],
                    onChanged: _saving
                        ? null
                        : (type) {
                            if (type != null) {
                              _changeType(type);
                            }
                          },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titleController,
                    maxLength: UserEventRepository.maxTitleLength,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: const [SentenceCapitalizationFormatter()],
                    decoration: InputDecoration(
                      labelText: l10n.eventTitleLabel,
                      hintText: l10n.eventTitleHint,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.eventTitleRequired
                        : null,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _noteController,
                    maxLength: UserEventRepository.maxNoteLength,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: const [SentenceCapitalizationFormatter()],
                    decoration: InputDecoration(
                      labelText: l10n.eventNoteLabel,
                      hintText: l10n.eventNoteHint,
                    ),
                  ),
                  Text(
                    l10n.eventPrivateNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppBentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.eventCalendarSystemLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<EventCalendarSystem>(
                    segments: [
                      ButtonSegment(
                        value: EventCalendarSystem.solar,
                        label: Text(l10n.eventCalendarSolar),
                      ),
                      ButtonSegment(
                        value: EventCalendarSystem.lunar,
                        label: Text(l10n.eventCalendarLunar),
                      ),
                    ],
                    selected: {_calendarSystem},
                    onSelectionChanged: _saving
                        ? null
                        : (selection) => _changeCalendarSystem(selection.first),
                  ),
                  const SizedBox(height: 14),
                  if (_calendarSystem == EventCalendarSystem.solar) ...[
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickSolarDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(_formatDate(_solarDate)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.eventLunarEquivalent(
                        _formatLunarDate(l10n, lunarLabel),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _LunarDropdown(
                            label: l10n.eventDayLabel,
                            value: _lunarDay,
                            values: List.generate(30, (index) => index + 1),
                            onChanged: (day) => _changeLunarDate(day: day),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LunarDropdown(
                            label: l10n.eventMonthLabel,
                            value: _lunarMonth,
                            values: List.generate(12, (index) => index + 1),
                            onChanged: (month) =>
                                _changeLunarDate(month: month),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _LunarDropdown(
                            label: l10n.eventYearLabel,
                            value: _lunarYear,
                            values: List.generate(
                              VietnameseLunarCalendarService.maxYear -
                                  VietnameseLunarCalendarService.minYear +
                                  1,
                              (index) =>
                                  VietnameseLunarCalendarService.minYear +
                                  index,
                            ),
                            onChanged: (year) => _changeLunarDate(year: year),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.eventLunarLeapMonth),
                      value: _isLeapMonth,
                      onChanged: leapMonth == _lunarMonth
                          ? (value) {
                              setState(() {
                                _isLeapMonth = value;
                                final converted = _lunarCalendar
                                    .tryLunarToSolarExact(_currentLunarDate);
                                if (converted != null) {
                                  _solarDate = converted;
                                }
                              });
                            }
                          : null,
                    ),
                    Text(
                      convertedLunarDate == null
                          ? l10n.eventInvalidDate
                          : l10n.eventSolarEquivalent(
                              _formatDate(convertedLunarDate),
                            ),
                      style: TextStyle(
                        color: convertedLunarDate == null
                            ? AppColors.statusError
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.eventAllDay),
                    value: _allDay,
                    onChanged: _saving ? null : _toggleAllDay,
                  ),
                  if (!_allDay)
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickEventTime,
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(
                        '${l10n.eventStartTime}: ${_eventTime.format(context)}',
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.eventRecurrenceLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<EventRecurrence>(
                    initialValue: _recurrence,
                    decoration: InputDecoration(
                      labelText: l10n.eventRecurrenceLabel,
                    ),
                    items: [
                      for (final recurrence in EventRecurrence.values)
                        DropdownMenuItem(
                          value: recurrence,
                          child: Text(eventRecurrenceLabel(l10n, recurrence)),
                        ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _recurrence = value);
                            }
                          },
                  ),
                  if (widget.eventId != null &&
                      _recurrence != EventRecurrence.once) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.eventEditSeriesNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppBentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.eventColorLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EventColorPicker(
                    selected: _color,
                    onChanged: _saving
                        ? null
                        : (color) => setState(() => _color = color),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.eventReminderEnable),
                    value: _reminderEnabled,
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _reminderEnabled = value),
                  ),
                  if (_reminderEnabled) ...[
                    DropdownButtonFormField<int>(
                      initialValue: _reminderOffsetMinutes,
                      decoration: InputDecoration(
                        labelText: l10n.eventReminderLabel,
                      ),
                      items: _reminderOptions(l10n, _allDay),
                      onChanged: _saving
                          ? null
                          : (value) => setState(
                              () => _reminderOffsetMinutes = value ?? 1440,
                            ),
                    ),
                    if (_allDay) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _pickReminderTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(
                          '${l10n.eventReminderTime}: ${_reminderTime.format(context)}',
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}

List<DropdownMenuItem<int>> _reminderOptions(
  AppLocalizations l10n,
  bool allDay,
) {
  if (allDay) {
    return [
      DropdownMenuItem(value: 0, child: Text(l10n.eventReminderSameDay)),
      DropdownMenuItem(
        value: 1440,
        child: Text(l10n.eventReminderDaysBefore(1)),
      ),
      DropdownMenuItem(
        value: 2880,
        child: Text(l10n.eventReminderDaysBefore(2)),
      ),
      DropdownMenuItem(
        value: 4320,
        child: Text(l10n.eventReminderDaysBefore(3)),
      ),
      DropdownMenuItem(value: 10080, child: Text(l10n.eventReminderWeekBefore)),
    ];
  }
  return [
    DropdownMenuItem(value: 0, child: Text(l10n.eventReminderAtTime)),
    DropdownMenuItem(value: 5, child: Text(l10n.eventReminderMinutesBefore(5))),
    DropdownMenuItem(
      value: 10,
      child: Text(l10n.eventReminderMinutesBefore(10)),
    ),
    DropdownMenuItem(
      value: 15,
      child: Text(l10n.eventReminderMinutesBefore(15)),
    ),
    DropdownMenuItem(
      value: 30,
      child: Text(l10n.eventReminderMinutesBefore(30)),
    ),
    DropdownMenuItem(value: 60, child: Text(l10n.eventReminderHoursBefore(1))),
    DropdownMenuItem(value: 120, child: Text(l10n.eventReminderHoursBefore(2))),
    DropdownMenuItem(value: 1440, child: Text(l10n.eventReminderDaysBefore(1))),
    DropdownMenuItem(value: 10080, child: Text(l10n.eventReminderWeekBefore)),
  ];
}

class _EventColorPicker extends StatelessWidget {
  const _EventColorPicker({required this.selected, required this.onChanged});

  final UserEventColor selected;
  final ValueChanged<UserEventColor>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        for (final color in UserEventColor.values)
          Semantics(
            button: true,
            selected: color == selected,
            label: userEventColorLabel(l10n, color),
            child: Tooltip(
              message: userEventColorLabel(l10n, color),
              child: InkWell(
                onTap: onChanged == null ? null : () => onChanged!(color),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: userEventColorValue(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color == selected
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: color == selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LunarDropdown extends StatelessWidget {
  const _LunarDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> values;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          isDense: true,
          style: Theme.of(context).textTheme.bodySmall,
          value: value,
          items: [
            for (final item in values)
              DropdownMenuItem(
                value: item,
                child: Text(
                  '$item',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
          onChanged: (item) {
            if (item != null) {
              onChanged(item);
            }
          },
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

String _formatLunarDate(AppLocalizations l10n, LunarDateValue date) {
  final leap = date.isLeapMonth ? ' (${l10n.eventLunarLeapMonth})' : '';
  return '${date.day}/${date.month}/${date.year}$leap';
}
