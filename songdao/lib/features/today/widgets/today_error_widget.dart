import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class TodayErrorWidget extends StatelessWidget {
  const TodayErrorWidget({super.key, required this.onRetry});

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
