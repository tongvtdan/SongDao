import 'package:flutter/material.dart';

import '../../../app/design_system.dart';
import '../../../app/theme.dart';
import '../today_controller.dart';

class DailyActionCard extends StatelessWidget {
  const DailyActionCard({
    super.key,
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

Color _liturgicalAccentColor(String color) {
  if (color == 'white') {
    return AppColors.gold;
  }

  return liturgicalColor(color);
}
