import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/design_system.dart';
import '../../../app/theme.dart';
import '../today_controller.dart';

const _initialCardPage = 10000;

class SwipeableLiturgicalContextCard extends StatelessWidget {
  const SwipeableLiturgicalContextCard({
    super.key,
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
                              const SizedBox(height: AppSpacing.x1),
                              Text(
                                _vietnameseWeekdayLabel(parsed.weekday),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
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

// Helpers
String _dateKeyForCardPage(int page, String todayDateKey) {
  final today = DateTime.parse(todayDateKey);
  final previewDate = today.add(Duration(days: page - _initialCardPage));
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

String _formatVietnameseDate(String date) {
  final parsed = DateTime.parse(date);
  final formattedDate = DateFormat('dd/MM/yyyy').format(parsed);
  return '${_vietnameseWeekdayLabel(parsed.weekday)}, $formattedDate';
}

String _vietnameseWeekdayLabel(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'Thứ Hai',
    DateTime.tuesday => 'Thứ Ba',
    DateTime.wednesday => 'Thứ Tư',
    DateTime.thursday => 'Thứ Năm',
    DateTime.friday => 'Thứ Sáu',
    DateTime.saturday => 'Thứ Bảy',
    DateTime.sunday => 'Chúa Nhật',
    _ => '',
  };
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
