import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/design_system.dart';
import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';
import 'today_controller.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  static const _initialCardPage = 10000;

  late Future<TodayViewData> _todayFuture;
  late final PageController _cardPageController;
  final _noteController = TextEditingController();
  final Map<String, Future<TodayViewData>> _previewFutures = {};
  int _cardPage = _initialCardPage;
  String? _cardDateKey;
  bool _isCompleting = false;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController(initialPage: _initialCardPage);
    _todayFuture = _loadToday();
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<TodayViewData> _loadToday() async {
    try {
      await ref.read(seedContentBootstrapProvider.future);
      final data = await TodayController(
        db: ref.read(databaseProvider),
        settings: ref.read(userSettingsRepositoryProvider),
        engine: ref.read(dailyActionEngineProvider),
      ).load();

      _noteController.text = data.log?.note ?? '';
      return data;
    } catch (error, stackTrace) {
      debugPrint('Today load failed: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<TodayViewData> _loadPreviewDate(String dateKey) async {
    await ref.read(seedContentBootstrapProvider.future);
    return _controller.load(date: dateKey);
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
          _cardDateKey ??= data.date;
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
                        _SwipeableLiturgicalContextCard(
                          todayData: data,
                          cardPageController: _cardPageController,
                          cardDateKey: _cardDateKey ?? data.date,
                          previewForDate: _previewForDate,
                          onPageChanged: _changeCardPage,
                          onPrevious: () => _animateCardToPage(_cardPage - 1),
                          onNext: () => _animateCardToPage(_cardPage + 1),
                          onToday: _animateCardToToday,
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        _DailyActionCard(
                          data: data,
                          isCompleting: _isCompleting,
                          onComplete: () => _completeAction(data),
                        ),
                        if (data.log?.status == 'completed') ...[
                          const SizedBox(height: AppSpacing.x4),
                          _ReflectionNoteCard(
                            controller: _noteController,
                            isSaving: _isSavingNote,
                            onSave: () => _saveNote(data),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.x4),
                        Wrap(
                          spacing: AppSpacing.x4,
                          runSpacing: AppSpacing.x4,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: _ReadingReferencesCard(
                                readings: data.readings,
                              ),
                            ),
                            if (data.reflection != null)
                              SizedBox(
                                width: double.infinity,
                                child: _DailyReflectionCard(
                                  reflection: data.reflection!,
                                ),
                              ),
                          ],
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
    ref.invalidate(seedContentBootstrapProvider);
    _previewFutures.clear();
    setState(() => _todayFuture = _loadToday());
    await _todayFuture;
  }

  Future<TodayViewData> _previewForDate(String dateKey) {
    return _previewFutures.putIfAbsent(
      dateKey,
      () => _loadPreviewDate(dateKey),
    );
  }

  void _changeCardPage(int page, TodayViewData todayData) {
    setState(() {
      _cardPage = page;
      _cardDateKey = _dateKeyForCardPage(page, todayData.date);
    });
  }

  Future<void> _animateCardToPage(int page) {
    return _cardPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _animateCardToToday() {
    return _animateCardToPage(_initialCardPage);
  }
}

class _SwipeableLiturgicalContextCard extends StatelessWidget {
  const _SwipeableLiturgicalContextCard({
    required this.todayData,
    required this.cardPageController,
    required this.cardDateKey,
    required this.previewForDate,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final TodayViewData todayData;
  final PageController cardPageController;
  final String cardDateKey;
  final Future<TodayViewData> Function(String dateKey) previewForDate;
  final void Function(int page, TodayViewData todayData) onPageChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final isPreviewingAnotherDate = cardDateKey != todayData.date;

    return Column(
      children: [
        SizedBox(
          height: _liturgicalCardHeight(context),
          child: PageView.builder(
            controller: cardPageController,
            onPageChanged: (page) => onPageChanged(page, todayData),
            itemBuilder: (context, index) {
              final dateKey = _dateKeyForCardPage(index, todayData.date);
              if (dateKey == todayData.date) {
                return _LiturgicalContextCard(data: todayData);
              }

              return FutureBuilder<TodayViewData>(
                future: previewForDate(dateKey),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return _LiturgicalContextLoadingCard(dateKey: dateKey);
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _LiturgicalContextPreviewErrorCard(dateKey: dateKey);
                  }
                  return _LiturgicalContextCard(data: snapshot.data!);
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        _CardDateControls(
          isPreviewingAnotherDate: isPreviewingAnotherDate,
          onPrevious: onPrevious,
          onNext: onNext,
          onToday: onToday,
        ),
        if (isPreviewingAnotherDate) ...[
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Xem ngày khác. Hành động bên dưới vẫn là hôm nay.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _DailyReflectionCard extends StatelessWidget {
  const _DailyReflectionCard({required this.reflection});

  final DailyReflection reflection;

  @override
  Widget build(BuildContext context) {
    return AppBentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSignalChip(
            label: 'Suy niệm',
            color: AppColors.gold,
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 12),
          Text(
            reflection.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            reflection.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDateControls extends StatelessWidget {
  const _CardDateControls({
    required this.isPreviewingAnotherDate,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final bool isPreviewingAnotherDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          tooltip: 'Ngày trước',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isPreviewingAnotherDate
              ? Padding(
                  key: const ValueKey('today-button'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x2,
                  ),
                  child: TextButton.icon(
                    onPressed: onToday,
                    icon: const Icon(Icons.today_outlined, size: 18),
                    label: const Text('Hôm nay'),
                  ),
                )
              : const SizedBox(key: ValueKey('today-spacer'), width: 104),
        ),
        IconButton.filledTonal(
          tooltip: 'Ngày sau',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _LiturgicalContextLoadingCard extends StatelessWidget {
  const _LiturgicalContextLoadingCard({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _liturgicalCardHeight(context),
      child: AppBentoCard(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.x4),
              Text(
                _formatVietnameseDate(dateKey),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiturgicalContextPreviewErrorCard extends StatelessWidget {
  const _LiturgicalContextPreviewErrorCard({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _liturgicalCardHeight(context),
      child: AppBentoCard(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_busy_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.x3),
              Text(
                'Chưa mở được ngày này',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                _formatVietnameseDate(dateKey),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
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
    final saintOfDay = _saintOfDayLabel(data, celebration);

    return SizedBox(
      height: _liturgicalCardHeight(context),
      child: AppBentoCard(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        accentColor: accentColor,
        accentPlacement: AppAccentPlacement.top,
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
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                parsed.day.toString().padLeft(2, '0'),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      fontSize: 130,
                                      height: 0.9,
                                      color: accentColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              if (showLunar) ...[
                                _LunarDateText(
                                  label: data.calendarDay.lunarDate!,
                                ),
                                const SizedBox(height: AppSpacing.x1),
                              ],
                              Text(
                                celebration,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.x2),
                              _DailyQuoteBlock(quote: quote),
                              if (saintOfDay != null) ...[
                                const SizedBox(height: AppSpacing.x1),
                                _SaintOfDayBlock(label: saintOfDay),
                              ],
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
        vertical: AppSpacing.x1,
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
            size: 16,
            color: AppColors.gold,
          ),
          Text(
            quote.text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            quote.attribution,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LunarDateText extends StatelessWidget {
  const _LunarDateText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.18,
        fontWeight: FontWeight.w700,
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
        vertical: AppSpacing.x1,
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
              size: 16,
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.brandPressed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.18,
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
    required this.onComplete,
    required this.isCompleting,
  });

  final TodayViewData data;
  final bool isCompleting;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = data.log?.status == 'completed';
    final accentColor = _liturgicalAccentColor(data.calendarDay.color);

    return AppBentoCard(
      accentColor: isCompleted ? AppColors.statusComplete : accentColor,
      gradient: isCompleted
          ? LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.brandSoft.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Column(
          key: ValueKey(isCompleted),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSignalChip(
                  label: 'Hành động hôm nay',
                  color: accentColor,
                  icon: Icons.auto_awesome,
                ),
                const Spacer(),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.statusComplete,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.action.prompt,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            if (!isCompleted)
              FilledButton.icon(
                onPressed: isCompleting ? null : onComplete,
                icon: isCompleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: const Text('Hoàn thành'),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandSoft.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Bạn đã sống đạo hôm nay!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.brandPressed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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

String _dateKeyForCardPage(int page, String todayDateKey) {
  final today = DateTime.parse(todayDateKey);
  final previewDate = today.add(
    Duration(days: page - _TodayScreenState._initialCardPage),
  );
  return DateFormat('yyyy-MM-dd').format(previewDate);
}

double _liturgicalCardHeight(BuildContext context) {
  final screenHeight = MediaQuery.sizeOf(context).height;
  return (screenHeight * 0.58).clamp(430.0, 560.0);
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

String? _saintOfDayLabel(TodayViewData data, String primaryCelebration) {
  final rankedCelebrations = data.celebrations.where(
    (celebration) =>
        celebration.rank == 'memorial' ||
        celebration.rank == 'optional_memorial' ||
        celebration.rank == 'feast',
  );
  for (final celebration in rankedCelebrations) {
    final name = celebration.name;
    final isSaint = name.startsWith('Thánh ') || name.startsWith('Các Thánh ');
    final isDuplicate =
        name.trim().toLowerCase() == primaryCelebration.trim().toLowerCase();
    if (isSaint && !isDuplicate) {
      return name;
    }
  }
  return null;
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
