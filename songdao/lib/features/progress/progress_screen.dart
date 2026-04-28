import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiến trình')),
      body: FutureBuilder<_ProgressViewData>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Text(
                'Nhịp sống đức tin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.brand,
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
              _WeekRhythmCard(data: data),
              const SizedBox(height: 14),
              _RecentLogsCard(logs: data.recentLogs),
            ],
          );
        },
      ),
    );
  }

  Future<_ProgressViewData> _load(WidgetRef ref) async {
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
    for (final log in logs.where((log) => log.status == 'completed')) {
      final action = await (db.select(
        db.dailyActions,
      )..where((t) => t.id.equals(log.actionId))).getSingleOrNull();
      if (action != null) {
        recentLogs.add(_CompletedLog(log: log, action: action));
      }
      if (recentLogs.length == 8) {
        break;
      }
    }
    return _ProgressViewData(
      weekKeys: weekKeys,
      weekCompleted: weekCompleted,
      recentLogs: recentLogs,
    );
  }
}

class _WeekRhythmCard extends StatelessWidget {
  const _WeekRhythmCard({required this.data});

  final _ProgressViewData data;

  @override
  Widget build(BuildContext context) {
    final count = data.weekCompleted.values.where((value) => value).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.completed});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: completed ? AppColors.brand : AppColors.surfaceSecondary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Icon(
            completed ? Icons.check : Icons.circle_outlined,
            size: 16,
            color: completed ? Colors.white : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RecentLogsCard extends StatelessWidget {
  const _RecentLogsCard({required this.logs});

  final List<_CompletedLog> logs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Việc đã hoàn thành',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (logs.isEmpty)
              Text(
                'Chưa có lịch sử hoàn thành. Khi bạn ghi nhận một việc nhỏ, nó sẽ hiện ở đây.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
      ),
    );
  }
}

class _ProgressViewData {
  const _ProgressViewData({
    required this.weekKeys,
    required this.weekCompleted,
    required this.recentLogs,
  });

  final List<String> weekKeys;
  final Map<String, bool> weekCompleted;
  final List<_CompletedLog> recentLogs;
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
