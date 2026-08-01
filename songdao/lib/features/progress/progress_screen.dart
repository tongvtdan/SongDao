import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/design_system.dart';
import '../../app/theme.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';
import '../../l10n/app_localizations.dart';
import '../shared/widgets/async_state_view.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String? _selectedDate;
  late Future<_ProgressViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadWithDiagnostics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiến trình')),
      body: FutureBuilder<_ProgressViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return AsyncErrorState(onRetry: _retry);
          }
          final data = snapshot.data!;
          final l10n = AppLocalizations.of(context);
          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Text(
                'Nhịp sống đức tin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Riêng tư, nhẹ nhàng, chỉ lưu trên thiết bị.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _JournalEntryPoint(
                onTap: () => context.push('/progress/journal'),
              ),
              const SizedBox(height: 14),
              _WeekRhythmCard(
                data: data,
                selectedDate: _selectedDate,
                onSelectDate: (date) {
                  setState(() {
                    _selectedDate = _selectedDate == date ? null : date;
                  });
                },
              ),
              const SizedBox(height: 14),
              if (data.completedLogs.isEmpty) ...[
                AsyncEmptyState(
                  title: l10n?.progressEmptyTitle ?? 'Chưa có việc hoàn thành',
                  message:
                      l10n?.progressEmptyMessage ??
                      'Hoàn thành một việc nhỏ hôm nay để bắt đầu nhịp sống đức tin.',
                ),
                const SizedBox(height: 14),
              ],
              _RecentLogsCard(
                logs: data.logsForDate(_selectedDate),
                selectedDate: _selectedDate,
              ),
            ],
          );
        },
      ),
    );
  }

  void _retry() {
    setState(() {
      _future = _loadWithDiagnostics();
    });
  }

  Future<_ProgressViewData> _loadWithDiagnostics() {
    return loadWithDiagnostics('Progress', _load);
  }

  Future<_ProgressViewData> _load() async {
    final db = ref.read(databaseProvider);
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekKeys = List.generate(
      7,
      (index) => _dateKey(monday.add(Duration(days: index))),
    );
    final logs =
        await (db.select(db.actionLogs)..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
              (t) => OrderingTerm(
                expression: t.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
    final weekCompleted = {
      for (final key in weekKeys)
        key: logs.any((log) => log.date == key && log.status == 'completed'),
    };
    final recentLogs = <_CompletedLog>[];
    final completedLogs = <_CompletedLog>[];
    for (final log in logs.where((log) => log.status == 'completed')) {
      final action = await (db.select(
        db.dailyActions,
      )..where((t) => t.id.equals(log.actionId))).getSingleOrNull();
      if (action != null) {
        final item = _CompletedLog(log: log, action: action);
        completedLogs.add(item);
        if (recentLogs.length < 8) {
          recentLogs.add(item);
        }
      }
    }
    return _ProgressViewData(
      weekKeys: weekKeys,
      weekCompleted: weekCompleted,
      recentLogs: recentLogs,
      completedLogs: completedLogs,
    );
  }
}

class _JournalEntryPoint extends StatelessWidget {
  const _JournalEntryPoint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBentoCard(
      accentColor: AppColors.gold,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book_outlined, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhật ký riêng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Xem, tìm và sửa ghi chú chỉ lưu trên thiết bị.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _WeekRhythmCard extends StatelessWidget {
  const _WeekRhythmCard({
    required this.data,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final _ProgressViewData data;
  final String? selectedDate;
  final ValueChanged<String> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final count = data.weekCompleted.values.where((value) => value).length;
    return AppBentoCard(
      accentColor: AppColors.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tuần này',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.weekKeys.map((key) {
              final completed = data.weekCompleted[key] ?? false;
              final date = DateTime.parse(key);
              return _DayDot(
                label: _weekdayShort(date.weekday),
                completed: completed,
                selected: selectedDate == key,
                onTap: () => onSelectDate(key),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: count / 7,
            minHeight: 7,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppColors.surfaceSecondary,
            color: AppColors.brand,
          ),
          const SizedBox(height: 10),
          Text(
            count == 0
                ? 'Một việc nhỏ hôm nay là đủ để bắt đầu lại.'
                : 'Bạn đã giữ nhịp $count/7 ngày trong tuần này.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.completed,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool completed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, xem việc đã hoàn thành',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.brand
                      : AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.gold : AppColors.borderSubtle,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Icon(
                  completed ? Icons.check : Icons.circle_outlined,
                  size: 17,
                  color: completed ? Colors.white : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? AppColors.brand : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentLogsCard extends StatelessWidget {
  const _RecentLogsCard({required this.logs, required this.selectedDate});

  final List<_CompletedLog> logs;
  final String? selectedDate;

  @override
  Widget build(BuildContext context) {
    final hasSelectedDate = selectedDate != null;
    return AppBentoCard(
      accentColor: AppColors.brand.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasSelectedDate
                ? 'Việc đã hoàn thành ngày này'
                : 'Việc đã hoàn thành',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (hasSelectedDate) ...[
            const SizedBox(height: 4),
            Text(
              _formatSelectedDate(selectedDate!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (logs.isEmpty)
            Text(
              hasSelectedDate
                  ? 'Chưa có việc hoàn thành trong ngày này.'
                  : 'Chưa có lịch sử hoàn thành. Khi bạn ghi nhận một việc nhỏ, nó sẽ hiện ở đây.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            )
          else
            ...logs.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.brand,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.action.prompt,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatLogDate(item.log),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          if ((item.log.note ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.log.note!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressViewData {
  const _ProgressViewData({
    required this.weekKeys,
    required this.weekCompleted,
    required this.recentLogs,
    required this.completedLogs,
  });

  final List<String> weekKeys;
  final Map<String, bool> weekCompleted;
  final List<_CompletedLog> recentLogs;
  final List<_CompletedLog> completedLogs;

  List<_CompletedLog> logsForDate(String? date) {
    if (date == null) {
      return recentLogs;
    }
    return completedLogs.where((item) => item.log.date == date).toList();
  }
}

class _CompletedLog {
  const _CompletedLog({required this.log, required this.action});

  final ActionLog log;
  final DailyAction action;
}

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _weekdayShort(int weekday) {
  return const {
    DateTime.monday: 'T2',
    DateTime.tuesday: 'T3',
    DateTime.wednesday: 'T4',
    DateTime.thursday: 'T5',
    DateTime.friday: 'T6',
    DateTime.saturday: 'T7',
    DateTime.sunday: 'CN',
  }[weekday]!;
}

String _formatLogDate(ActionLog log) {
  final when = log.completedAt ?? log.updatedAt;
  return DateFormat('dd/MM/yyyy, HH:mm').format(when);
}

String _formatSelectedDate(String date) {
  return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
}
