import 'package:flutter/material.dart';

import '../../../app/design_system.dart';
import '../../../app/theme.dart';
import '../../../data/local/app_database.dart';

class DailyReflectionCard extends StatelessWidget {
  const DailyReflectionCard({super.key, required this.reflection});

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
