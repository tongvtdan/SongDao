import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_system.dart';
import '../../../app/theme.dart';
import '../../../data/local/app_database.dart';

class ReadingReferencesCard extends StatelessWidget {
  const ReadingReferencesCard({super.key, required this.readings});

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
                  _ReadingSourceLink(
                    reading: gospel,
                    textStyle: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: AppColors.textPrimary, height: 1.35),
                    iconSize: 22,
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
                          child: _ReadingSourceLink(
                            reading: reading,
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                            iconSize: 16,
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

class _ReadingSourceLink extends StatelessWidget {
  const _ReadingSourceLink({
    required this.reading,
    required this.textStyle,
    required this.iconSize,
  });

  final Reading reading;
  final TextStyle? textStyle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = textStyle ?? Theme.of(context).textTheme.bodyMedium;
    final title = reading.type == 'gospel'
        ? 'Tin Mừng hôm nay'
        : reading.displayLabel ?? _readingLabel(reading.type);

    return Semantics(
      link: true,
      button: true,
      label: '$title ${reading.citation}',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _openReadingInApp(context, title),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Text(reading.citation, style: effectiveStyle)),
              const SizedBox(width: AppSpacing.x2),
              Icon(Icons.open_in_new, size: iconSize, color: AppColors.brand),
            ],
          ),
        ),
      ),
    );
  }
}

void _openReadingInApp(BuildContext context, String title) {
  context.push(
    Uri(
      path: '/readings/web',
      queryParameters: {
        'url': 'https://ktcgkpv.org/readings/mass-reading',
        'title': title,
      },
    ).toString(),
  );
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
