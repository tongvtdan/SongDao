import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late String _selectedDate = _dateKey(DateTime.now());
  late Future<_CalendarViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CalendarViewData> _load() async {
    await ref.read(seedContentBootstrapProvider.future);
    final db = ref.read(databaseProvider);
    final settings = ref.read(userSettingsRepositoryProvider);
    final locale = await settings.locale();
    final showLunarDate = await settings.showLunarDate();
    final start = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final end = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
    final days =
        await (db.select(db.calendarDays)
              ..where(
                (t) =>
                    t.date.isBiggerOrEqualValue(_dateKey(start)) &
                    t.date.isSmallerOrEqualValue(_dateKey(end)) &
                    t.locale.equals(locale),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.date)]))
            .get();

    final selectedDay =
        await (db.select(db.calendarDays)..where(
              (t) => t.date.equals(_selectedDate) & t.locale.equals(locale),
            ))
            .getSingleOrNull();
    final celebrations =
        await (db.select(db.celebrations)
              ..where(
                (t) => t.date.equals(_selectedDate) & t.locale.equals(locale),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.rank)]))
            .get();
    final readings =
        await (db.select(db.readings)..where(
              (t) => t.date.equals(_selectedDate) & t.locale.equals(locale),
            ))
            .get();
    readings.sort(
      (a, b) => _readingOrder(a.type).compareTo(_readingOrder(b.type)),
    );
    DailyAction? action;
    if (selectedDay != null) {
      action = await ref
          .read(dailyActionEngineProvider)
          .getOrCreateActionForDate(_selectedDate, locale: locale);
    }

    return _CalendarViewData(
      locale: locale,
      showLunarDate: showLunarDate,
      days: {for (final day in days) day.date: day},
      selectedDay: selectedDay,
      celebrations: celebrations,
      readings: readings,
      action: action,
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _future = _load();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _dateKey(date);
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch')),
      body: FutureBuilder<_CalendarViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _CalendarHeader(
                month: _visibleMonth,
                onPrevious: () => _changeMonth(-1),
                onNext: () => _changeMonth(1),
              ),
              const SizedBox(height: 12),
              _MonthGrid(
                month: _visibleMonth,
                days: data.days,
                selectedDate: _selectedDate,
                onSelect: _selectDate,
              ),
              const SizedBox(height: 14),
              _SelectedDayCard(data: data),
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
    return Row(
      children: [
        IconButton(
          tooltip: 'Tháng trước',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Tháng ${month.month}, ${month.year}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Dữ liệu phụng vụ trên thiết bị',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Tháng sau',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.days,
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime month;
  final Map<String, CalendarDay> days;
  final String selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final startOffset = first.weekday % 7;
    final gridStart = first.subtract(Duration(days: startOffset));
    final todayKey = _dateKey(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Row(
              children: [
                _WeekdayLabel('CN', sunday: true),
                _WeekdayLabel('T2'),
                _WeekdayLabel('T3'),
                _WeekdayLabel('T4'),
                _WeekdayLabel('T5'),
                _WeekdayLabel('T6'),
                _WeekdayLabel('T7'),
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
                final key = _dateKey(date);
                final day = days[key];
                final inMonth = date.month == month.month;
                final selected = key == selectedDate;
                final isToday = key == todayKey;
                final color = day == null
                    ? AppColors.textTertiary
                    : liturgicalColor(day.color);

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.brand
                            : day == null
                            ? Colors.transparent
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: day == null
                                ? Colors.transparent
                                : selected
                                ? Colors.white
                                : color == AppColors.canvas
                                ? AppColors.gold
                                : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
          color: sunday ? AppColors.tertiary : AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({required this.data});

  final _CalendarViewData data;

  @override
  Widget build(BuildContext context) {
    final day = data.selectedDay;
    if (day == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Chưa có dữ liệu phụng vụ cho ngày này trong gói nội dung trên thiết bị.',
          ),
        ),
      );
    }
    final celebration = data.celebrations.isEmpty
        ? _formatVietnameseDate(day.date)
        : data.celebrations.first.name;
    final showLunar =
        data.locale == 'vi' && data.showLunarDate && day.lunarDate != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                _Chip(label: _seasonLabel(day.season)),
                _Chip(label: _colorLabel(day.color)),
                if (showLunar) _Chip(label: day.lunarDate!),
              ],
            ),
            if (data.action != null) ...[
              const SizedBox(height: 16),
              Text(
                'Việc sống đạo',
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
                'Bài đọc',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ...data.readings.map(
                (reading) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${reading.displayLabel ?? _readingLabel(reading.type)}: ${reading.citation}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CalendarViewData {
  const _CalendarViewData({
    required this.locale,
    required this.showLunarDate,
    required this.days,
    required this.selectedDay,
    required this.celebrations,
    required this.readings,
    required this.action,
  });

  final String locale;
  final bool showLunarDate;
  final Map<String, CalendarDay> days;
  final CalendarDay? selectedDay;
  final List<Celebration> celebrations;
  final List<Reading> readings;
  final DailyAction? action;
}

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatVietnameseDate(String date) {
  final parsed = DateTime.parse(date);
  final formattedDate = DateFormat('dd/MM/yyyy').format(parsed);
  if (parsed.weekday == DateTime.sunday) {
    return 'Chúa nhật, $formattedDate';
  }
  return 'Thứ ${parsed.weekday + 1}, $formattedDate';
}

String _seasonLabel(String season) {
  return switch (season) {
    'advent' => 'Mùa Vọng',
    'christmas' => 'Mùa Giáng Sinh',
    'lent' => 'Mùa Chay',
    'easter' => 'Mùa Phục Sinh',
    'ordinary' => 'Thường niên',
    _ => 'Dữ liệu địa phương',
  };
}

String _colorLabel(String color) {
  return switch (color) {
    'green' => 'Xanh',
    'white' => 'Trắng',
    'gold' => 'Vàng',
    'red' => 'Đỏ',
    'purple' => 'Tím',
    'rose' => 'Hồng',
    'black' => 'Đen',
    _ => 'Phụng vụ',
  };
}

String _readingLabel(String type) {
  return switch (type) {
    'first' || 'first_reading' => 'Bài đọc I',
    'second' || 'second_reading' => 'Bài đọc II',
    'psalm' => 'Đáp ca',
    'alleluia' || 'gospel_acclamation' => 'Alleluia',
    'gospel' => 'Tin Mừng',
    _ => 'Bài đọc',
  };
}

int _readingOrder(String type) {
  return switch (type) {
    'first' || 'first_reading' => 0,
    'psalm' => 1,
    'second' || 'second_reading' => 2,
    'alleluia' || 'gospel_acclamation' => 3,
    'gospel' => 4,
    _ => 5,
  };
}
