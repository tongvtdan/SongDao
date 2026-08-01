import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

Future<T> loadWithDiagnostics<T>(
  String screen,
  Future<T> Function() load,
) async {
  try {
    return await load();
  } catch (error, stackTrace) {
    debugPrint('$screen load failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

class AsyncErrorState extends StatelessWidget {
  const AsyncErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              l10n?.asyncErrorTitle ?? 'Không thể tải nội dung',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.asyncErrorMessage ??
                  'Dữ liệu vẫn được lưu trên thiết bị. Hãy thử tải lại.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n?.retry ?? 'Tải lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class AsyncEmptyState extends StatelessWidget {
  const AsyncEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceSecondary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
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
