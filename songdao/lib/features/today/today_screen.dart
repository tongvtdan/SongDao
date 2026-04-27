import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late Future<_TodayViewData> _todayFuture;
  final _noteController = TextEditingController();
  bool _isCompleting = false;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    _todayFuture = _loadToday();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<_TodayViewData> _loadToday() async {
    await ref.read(seedContentBootstrapProvider.future);

    final db = ref.read(databaseProvider);
    final engine = ref.read(dailyActionEngineProvider);
    final date = _todayDateKey();
    final action = await engine.getOrCreateActionForDate(date);
    final calendarDay =
        await (db.select(db.calendarDays)..where(
              (t) => t.date.equals(date) & t.locale.equals(action.locale),
            ))
            .getSingle();
    final celebrations =
        await (db.select(db.celebrations)
              ..where(
                (t) => t.date.equals(date) & t.locale.equals(action.locale),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.rank)]))
            .get();
    final readings =
        await (db.select(db.readings)..where(
              (t) => t.date.equals(date) & t.locale.equals(action.locale),
            ))
            .get();
    readings.sort(
      (a, b) => _readingOrder(a.type).compareTo(_readingOrder(b.type)),
    );
    final log = await db.todayDao.getActionLogForAction(action.id);

    _noteController.text = log?.note ?? '';
    return _TodayViewData(
      date: date,
      calendarDay: calendarDay,
      celebrations: celebrations,
      readings: readings,
      action: action,
      log: log,
    );
  }

  Future<void> _completeAction(_TodayViewData data) async {
    if (_isCompleting) {
      return;
    }
    setState(() => _isCompleting = true);
    try {
      final note = _noteController.text.trim();
      await ref
          .read(databaseProvider)
          .actionLogDao
          .markCompleted(data.action.id, note: note.isEmpty ? null : note);
      if (!mounted) {
        return;
      }
      setState(() => _todayFuture = _loadToday());
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  Future<void> _saveNote(_TodayViewData data) async {
    if (_isSavingNote) {
      return;
    }
    setState(() => _isSavingNote = true);
    try {
      await ref
          .read(databaseProvider)
          .actionLogDao
          .saveNote(data.action.id, _noteController.text.trim());
      if (!mounted) {
        return;
      }
      setState(() => _todayFuture = _loadToday());
    } finally {
      if (mounted) {
        setState(() => _isSavingNote = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hôm nay')),
      body: FutureBuilder<_TodayViewData>(
        future: _todayFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _TodayError(onRetry: _refresh);
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                _LiturgicalContextCard(data: data),
                const SizedBox(height: 12),
                _DailyActionCard(
                  data: data,
                  isCompleting: _isCompleting,
                  onComplete: () => _completeAction(data),
                ),
                const SizedBox(height: 12),
                _CompletionStateCard(log: data.log),
                const SizedBox(height: 12),
                _ReadingReferencesCard(readings: data.readings),
                const SizedBox(height: 12),
                const _ImportantMassCard(),
                const SizedBox(height: 12),
                _ReflectionNoteCard(
                  controller: _noteController,
                  isSaving: _isSavingNote,
                  onSave: () => _saveNote(data),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _todayFuture = _loadToday());
    await _todayFuture;
  }

  String _todayDateKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}

class _LiturgicalContextCard extends StatelessWidget {
  const _LiturgicalContextCard({required this.data});

  final _TodayViewData data;

  @override
  Widget build(BuildContext context) {
    final celebration = data.celebrations.isEmpty
        ? 'Ngày thường'
        : data.celebrations.first.name;
    final color = liturgicalColor(data.calendarDay.color);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatVietnameseDate(data.date),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    celebration,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SignalChip(label: _seasonLabel(data.calendarDay.season)),
                      _SignalChip(label: _colorLabel(data.calendarDay.color)),
                      if (data.calendarDay.liturgicalWeek > 0)
                        _SignalChip(
                          label: 'Tuần ${data.calendarDay.liturgicalWeek}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyActionCard extends StatelessWidget {
  const _DailyActionCard({
    required this.data,
    required this.isCompleting,
    required this.onComplete,
  });

  final _TodayViewData data;
  final bool isCompleting;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = data.log?.status == 'completed';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Việc sống đạo hôm nay',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.brand,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.action.prompt,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isCompleted || isCompleting ? null : onComplete,
                icon: Icon(isCompleted ? Icons.check_circle : Icons.check),
                label: Text(
                  isCompleted
                      ? 'Đã ghi nhận nhịp sống hôm nay'
                      : isCompleting
                      ? 'Đang ghi nhận...'
                      : 'Hoàn thành hôm nay',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionStateCard extends StatelessWidget {
  const _CompletionStateCard({required this.log});

  final ActionLog? log;

  @override
  Widget build(BuildContext context) {
    final completed = log?.status == 'completed';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completed ? AppColors.brandSoft : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            color: completed ? AppColors.brand : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              completed
                  ? 'Một bước nhỏ đã được ghi lại cho hôm nay.'
                  : 'Bắt đầu với một hành động nhỏ, khi bạn sẵn sàng.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: completed
                    ? AppColors.brandPressed
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingReferencesCard extends StatelessWidget {
  const _ReadingReferencesCard({required this.readings});

  final List<Reading> readings;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Bài đọc',
      child: readings.isEmpty
          ? const Text(
              'Chưa có tham chiếu bài đọc cho ngày này. Bạn vẫn có thể sống một hành động nhỏ hôm nay.',
            )
          : Column(
              children: readings
                  .map(
                    (reading) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 92,
                            child: Text(
                              reading.displayLabel ??
                                  _readingLabel(reading.type),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              reading.citation,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ImportantMassCard extends StatelessWidget {
  const _ImportantMassCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Thánh lễ quan trọng',
      child: Text(
        'Chưa chọn giáo xứ. Khi bạn chọn giáo xứ, giờ lễ Chúa nhật hoặc lễ trọng sẽ hiện ở đây.',
      ),
    );
  }
}

class _ReflectionNoteCard extends StatelessWidget {
  const _ReflectionNoteCard({
    required this.controller,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ghi chú riêng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Viết một câu bạn muốn giữ lại cho hôm nay.',
              filled: true,
              fillColor: AppColors.surfaceSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lưu trên thiết bị của bạn.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: const Icon(Icons.lock_outline),
                label: Text(isSaving ? 'Đang lưu...' : 'Lưu ghi chú'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TodayError extends StatelessWidget {
  const _TodayError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Dữ liệu hôm nay đang ở trên thiết bị. Thử tải lại nếu nội dung chưa hiện.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Tải lại')),
          ],
        ),
      ),
    );
  }
}

class _TodayViewData {
  const _TodayViewData({
    required this.date,
    required this.calendarDay,
    required this.celebrations,
    required this.readings,
    required this.action,
    required this.log,
  });

  final String date;
  final CalendarDay calendarDay;
  final List<Celebration> celebrations;
  final List<Reading> readings;
  final DailyAction action;
  final ActionLog? log;
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
    'first' => 'Bài đọc I',
    'second' => 'Bài đọc II',
    'psalm' => 'Đáp ca',
    'alleluia' => 'Alleluia',
    'gospel' => 'Tin Mừng',
    _ => 'Bài đọc',
  };
}

int _readingOrder(String type) {
  return switch (type) {
    'first' => 0,
    'psalm' => 1,
    'second' => 2,
    'alleluia' => 3,
    'gospel' => 4,
    _ => 5,
  };
}
