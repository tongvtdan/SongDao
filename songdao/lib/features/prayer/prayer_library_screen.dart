import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_system.dart';
import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';

class PrayerLibraryScreen extends ConsumerWidget {
  const PrayerLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cầu nguyện')),
      body: FutureBuilder<List<Prayer>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final prayers = snapshot.data ?? const <Prayer>[];
          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Text(
                'Cầu nguyện',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Một thư viện nhỏ để hỗ trợ việc sống đạo hằng ngày.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const _FeaturedPrayerCard(),
              const SizedBox(height: 14),
              Text(
                'Thư viện kinh',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (prayers.isEmpty)
                const _EmptyPrayerState()
              else
                ...prayers.map(
                  (prayer) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PrayerListItem(prayer: prayer),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Prayer>> _load(WidgetRef ref) async {
    await ref.read(seedContentBootstrapProvider.future);
    final db = ref.read(databaseProvider);
    final locale = await ref.read(userSettingsRepositoryProvider).locale();
    return (db.select(db.prayers)
          ..where((t) => t.locale.equals(locale))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }
}

class _FeaturedPrayerCard extends StatelessWidget {
  const _FeaturedPrayerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSignalChip(
              label: '5 phút',
              color: AppColors.brand,
              icon: Icons.schedule_outlined,
            ),
            const SizedBox(height: 12),
            Text(
              'Kinh hằng ngày',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu hoặc kết thúc ngày bằng một lời kinh ngắn, không cần mở mạng.',
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

class _PrayerListItem extends StatelessWidget {
  const _PrayerListItem({required this.prayer});

  final Prayer prayer;

  @override
  Widget build(BuildContext context) {
    final tags = _decodeTags(prayer.tags);
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const Icon(
          Icons.auto_stories_outlined,
          color: AppColors.brand,
        ),
        title: Text(prayer.title),
        subtitle: Text(
          tags.isEmpty ? 'Kinh nguyện Công giáo' : tags.join(' · '),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              prayer.body ??
                  'Nội dung kinh đang chờ rà soát bản quyền. Bản beta chỉ lưu tiêu đề và nguồn để tránh dùng nội dung chưa được phép.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _decodeTags(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      return const [];
    }
    return decoded.map((item) => item.toString()).toList(growable: false);
  }
}

class _EmptyPrayerState extends StatelessWidget {
  const _EmptyPrayerState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Text(
          'Chưa có kinh nguyện trong gói nội dung hiện tại. Today vẫn hoạt động với hành động hằng ngày và ghi chú riêng.',
        ),
      ),
    );
  }
}
