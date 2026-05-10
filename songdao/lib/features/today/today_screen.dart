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
import 'today_controller.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late Future<TodayViewData> _todayFuture;
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

  Future<TodayViewData> _loadToday() async {
    await ref.read(seedContentBootstrapProvider.future);
    final data = await TodayController(
      db: ref.read(databaseProvider),
      settings: ref.read(userSettingsRepositoryProvider),
      engine: ref.read(dailyActionEngineProvider),
      massService: ref.read(massServiceProvider),
    ).load();

    _noteController.text = data.log?.note ?? '';
    return data;
  }

  Future<void> _completeAction(TodayViewData data) async {
    if (_isCompleting) {
      return;
    }
    setState(() => _isCompleting = true);
    try {
      await _controller.completeAction(data, note: _noteController.text);
      if (mounted) {
        setState(() => _todayFuture = _loadToday());
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  Future<void> _saveNote(TodayViewData data) async {
    if (_isSavingNote) {
      return;
    }
    setState(() => _isSavingNote = true);
    try {
      await _controller.saveNote(data, _noteController.text);
      if (mounted) {
        setState(() => _todayFuture = _loadToday());
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingNote = false);
      }
    }
  }

  TodayController get _controller {
    return TodayController(
      db: ref.read(databaseProvider),
      settings: ref.read(userSettingsRepositoryProvider),
      engine: ref.read(dailyActionEngineProvider),
      massService: ref.read(massServiceProvider),
    );
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
      body: FutureBuilder<TodayViewData>(
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
}

class _LiturgicalContextCard extends StatelessWidget {
  const _LiturgicalContextCard({required this.data});

  final TodayViewData data;

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
    final quote = _dailyQuoteFor(data.date);
    final saintOfDay = _saintOfDayLabel(data);

    final screenHeight = MediaQuery.sizeOf(context).height;
    final cardHeight = (screenHeight * 0.58).clamp(430.0, 560.0);

    return SizedBox(
      height: cardHeight,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: accentColor, width: 5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Tháng ${parsed.month.toString().padLeft(2, '0')} - ${parsed.year}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.textInverse,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  parsed.day.toString().padLeft(2, '0'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontSize: 112,
                                        height: 0.9,
                                        color: accentColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.x3),
                                Text(
                                  celebration,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                      ),
                                ),
                                if (showLunar) ...[
                                  const SizedBox(height: AppSpacing.x1),
                                  Text(
                                    data.calendarDay.lunarDate!,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.x3),
                                _DailyQuoteBlock(quote: quote),
                                const SizedBox(height: AppSpacing.x2),
                                _SaintOfDayBlock(label: saintOfDay),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
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
      ),
    );
  }
}

class _DailyQuoteBlock extends StatelessWidget {
  const _DailyQuoteBlock({required this.quote});

  final _DailyQuote quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            size: 18,
            color: AppColors.gold,
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            quote.text,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            quote.attribution,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaintOfDayBlock extends StatelessWidget {
  const _SaintOfDayBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandSoft.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(
              Icons.local_florist_outlined,
              size: 18,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vị thánh hôm nay',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.brandPressed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  final TodayViewData data;
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
                        Expanded(
                          child: Text(
                            'Một việc nhỏ để sống đức tin hôm nay',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      _actionTitle(data.action.type),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Text(
                      data.action.prompt,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
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
    final gospelId = gospel?.id;
    final supportingReadings = gospelId == null
        ? readings
        : readings.where((reading) => reading.id != gospelId);
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

_DailyQuote _dailyQuoteFor(String date) {
  final parsed = DateTime.parse(date);
  final dayOfYear = int.parse(DateFormat('D').format(parsed));
  return _dailyQuotes[dayOfYear % _dailyQuotes.length];
}

String _saintOfDayLabel(TodayViewData data) {
  final rankedCelebrations = data.celebrations.where(
    (celebration) =>
        celebration.rank == 'memorial' ||
        celebration.rank == 'optional_memorial' ||
        celebration.rank == 'feast',
  );
  for (final celebration in rankedCelebrations) {
    final name = celebration.name;
    if (name.startsWith('Thánh ') || name.startsWith('Các Thánh ')) {
      return name;
    }
  }
  return 'Các thánh nam nữ của Chúa, cầu cho chúng con.';
}

class _DailyQuote {
  const _DailyQuote({required this.text, required this.attribution});

  final String text;
  final String attribution;
}

const _dailyQuotes = [
  _DailyQuote(
    text: 'Một việc nhỏ được làm với lòng yêu mến có thể đổi hướng cả ngày.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _DailyQuote(
    text: 'Bình an bắt đầu khi con trao cho Chúa điều con không tự giữ nổi.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _DailyQuote(
    text: 'Đức tin lớn lên trong những lựa chọn rất nhỏ và rất thật.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _DailyQuote(
    text: 'Hãy bắt đầu lại nhẹ nhàng; lòng thương xót luôn đi trước con.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _DailyQuote(
    text: 'Yêu thương hôm nay không cần lớn tiếng, chỉ cần cụ thể.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _DailyQuote(
    text: 'Một phút thinh lặng có thể mở lại cánh cửa của lòng mình.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
  _DailyQuote(
    text: 'Chúa thường gặp ta trong bổn phận nhỏ đang ở ngay trước mặt.',
    attribution: 'Lời gợi hứng hôm nay',
  ),
];

String _actionTitle(String type) {
  return switch (type) {
    'sacrifice' => 'Hy sinh hôm nay',
    'mass_preparation' => 'Chuẩn bị Thánh lễ',
    'reflection' => 'Suy niệm hôm nay',
    'solemnity' => 'Mừng lễ hôm nay',
    _ => 'Một việc nhỏ hôm nay',
  };
}
