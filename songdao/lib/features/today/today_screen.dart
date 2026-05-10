import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/design_system.dart';
import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/mass_service.dart';

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
    final settings = ref.read(userSettingsRepositoryProvider);
    final engine = ref.read(dailyActionEngineProvider);
    final date = _todayDateKey();
    final locale = await settings.locale();
    final showLunarDate = await settings.showLunarDate();
    final action = await engine.getOrCreateActionForDate(date, locale: locale);
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
    final importantMass = await ref
        .read(massServiceProvider)
        .nextImportantMassForDate(date);

    _noteController.text = log?.note ?? '';
    return _TodayViewData(
      date: date,
      locale: locale,
      showLunarDate: showLunarDate,
      calendarDay: calendarDay,
      celebrations: celebrations,
      readings: readings,
      action: action,
      log: log,
      importantMass: importantMass,
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
      if (mounted) {
        setState(() => _todayFuture = _loadToday());
      }
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
      if (mounted) {
        setState(() => _todayFuture = _loadToday());
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingNote = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sống Đạo'),
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
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
              padding: AppSpacing.screenPadding,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LiturgicalContextCard(data: data),
                        const SizedBox(height: AppSpacing.x6),
                        _DailyActionCard(
                          data: data,
                          isCompleting: _isCompleting,
                          onComplete: () => _completeAction(data),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        _CompletionStateCard(log: data.log),
                        const SizedBox(height: AppSpacing.x4),
                        _TodayBento(
                          readings: data.readings,
                          importantMass: data.importantMass,
                          onChooseChurch: () => context.go('/church'),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        _ReflectionNoteCard(
                          controller: _noteController,
                          isSaving: _isSavingNote,
                          onSave: () => _saveNote(data),
                        ),
                      ],
                    ),
                  ),
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
    final parsed = DateTime.parse(data.date);
    final celebration = data.celebrations.isEmpty
        ? _formatVietnameseDate(data.date)
        : data.celebrations.first.name;
    final accentColor = _liturgicalAccentColor(data.calendarDay.color);
    final showLunar =
        data.locale == 'vi' &&
        data.showLunarDate &&
        data.calendarDay.lunarDate != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withValues(alpha: 0.09),
              AppColors.surface,
              AppColors.surfaceSecondary,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                'Tháng ${parsed.month.toString().padLeft(2, '0')} - ${parsed.year}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x5),
            Text(
              parsed.day.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 96,
                height: 0.9,
                color: accentColor,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: accentColor.withValues(alpha: 0.16),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            if (showLunar) ...[
              const SizedBox(height: AppSpacing.x4),
              Text(
                data.calendarDay.lunarDate!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.x4),
            Text(
              celebration,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                AppSignalChip(
                  label: _seasonLabel(data.calendarDay.season),
                  color: accentColor,
                  icon: Icons.eco_outlined,
                ),
                AppSignalChip(label: _colorLabel(data.calendarDay.color)),
                if (data.calendarDay.liturgicalWeek > 0)
                  AppSignalChip(
                    label: 'Tuần ${data.calendarDay.liturgicalWeek}',
                  ),
              ],
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
    final color = _liturgicalAccentColor(data.calendarDay.color);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volunteer_activism_outlined, color: color),
                        const SizedBox(width: 8),
                        Text(
                          _actionTitle(data.action.type),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.action.prompt,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: isCompleted || isCompleting
                          ? null
                          : onComplete,
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                      ),
                      label: Text(
                        isCompleted
                            ? 'Đã ghi nhận hôm nay'
                            : isCompleting
                            ? 'Đang ghi nhận...'
                            : 'Tôi đã làm',
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

class _CompletionStateCard extends StatelessWidget {
  const _CompletionStateCard({required this.log});

  final ActionLog? log;

  @override
  Widget build(BuildContext context) {
    final completed = log?.status == 'completed';
    return Container(
      padding: AppSpacing.cardPadding,
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
            size: 20,
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

class _TodayBento extends StatelessWidget {
  const _TodayBento({
    required this.readings,
    required this.importantMass,
    required this.onChooseChurch,
  });

  final List<Reading> readings;
  final ImportantMass? importantMass;
  final VoidCallback onChooseChurch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final children = [
          _ReadingReferencesCard(readings: readings),
          _ImportantMassCard(
            importantMass: importantMass,
            onChooseChurch: onChooseChurch,
          ),
        ];
        if (!wide) {
          return Column(
            children: [
              children.first,
              const SizedBox(height: 16),
              children.last,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children.first),
            const SizedBox(width: 16),
            Expanded(child: children.last),
          ],
        );
      },
    );
  }
}

class _ReadingReferencesCard extends StatelessWidget {
  const _ReadingReferencesCard({required this.readings});

  final List<Reading> readings;

  @override
  Widget build(BuildContext context) {
    Reading? gospel;
    for (final reading in readings) {
      if (reading.type == 'gospel') {
        gospel = reading;
        break;
      }
    }
    final supportingReadings = gospel == null
        ? readings
        : readings.where((reading) => reading.id != gospel!.id);
    return AppSectionCard(
      icon: Icons.auto_stories_outlined,
      title: 'Lời Chúa',
      child: readings.isEmpty
          ? const Text(
              'Chưa có tham chiếu bài đọc cho ngày này. Bạn vẫn có thể sống một hành động nhỏ hôm nay.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gospel != null) ...[
                  Text(
                    'Tin Mừng hôm nay',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    gospel.citation,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                ],
                if (supportingReadings.isNotEmpty)
                  const Divider(color: AppColors.borderSubtle),
                ...supportingReadings.map(
                  (reading) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 88,
                          child: Text(
                            reading.displayLabel ?? _readingLabel(reading.type),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            reading.citation,
                            style: Theme.of(context).textTheme.bodyMedium,
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

class _ImportantMassCard extends StatelessWidget {
  const _ImportantMassCard({
    required this.importantMass,
    required this.onChooseChurch,
  });

  final ImportantMass? importantMass;
  final VoidCallback onChooseChurch;

  @override
  Widget build(BuildContext context) {
    final mass = importantMass;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.surfaceContainer,
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 14,
            child: Icon(
              Icons.church_outlined,
              size: 58,
              color: AppColors.borderStrong.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Text(
                        mass == null ? 'Thánh lễ quan trọng' : mass.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x4),
                if (mass == null) ...[
                  const Text(
                    'Chưa chọn giáo xứ. Khi bạn chọn giáo xứ, giờ lễ Chúa nhật hoặc lễ trọng sẽ hiện ở đây.',
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  OutlinedButton.icon(
                    onPressed: onChooseChurch,
                    icon: const Icon(Icons.church_outlined),
                    label: const Text('Chọn giáo xứ'),
                  ),
                ] else ...[
                  Text(
                    mass.massTime.time,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    mass.church.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    mass.church.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
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
    return AppSectionCard(
      icon: Icons.lock_outline,
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
                icon: const Icon(Icons.save_outlined),
                label: Text(isSaving ? 'Đang lưu...' : 'Lưu'),
              ),
            ],
          ),
        ],
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
    required this.locale,
    required this.showLunarDate,
    required this.calendarDay,
    required this.celebrations,
    required this.readings,
    required this.action,
    required this.log,
    required this.importantMass,
  });

  final String date;
  final String locale;
  final bool showLunarDate;
  final CalendarDay calendarDay;
  final List<Celebration> celebrations;
  final List<Reading> readings;
  final DailyAction action;
  final ActionLog? log;
  final ImportantMass? importantMass;
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

Color _liturgicalAccentColor(String color) {
  if (color == 'white') {
    return AppColors.gold;
  }

  return liturgicalColor(color);
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

String _actionTitle(String type) {
  return switch (type) {
    'sacrifice' => 'Hy sinh hôm nay',
    'mass_preparation' => 'Chuẩn bị Thánh lễ',
    'reflection' => 'Suy niệm hôm nay',
    'solemnity' => 'Mừng lễ hôm nay',
    _ => 'Một việc nhỏ hôm nay',
  };
}
