import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_system.dart';
import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';

class ChurchSearchScreen extends ConsumerStatefulWidget {
  const ChurchSearchScreen({super.key});

  @override
  ConsumerState<ChurchSearchScreen> createState() => _ChurchSearchScreenState();
}

class _ChurchSearchScreenState extends ConsumerState<ChurchSearchScreen> {
  late Future<_ChurchViewData> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ChurchViewData> _load() async {
    await ref.read(seedContentBootstrapProvider.future);
    final db = ref.read(databaseProvider);
    final settings = ref.read(userSettingsRepositoryProvider);
    final locale = await settings.locale();
    final selectedChurchId = await settings.selectedChurchId();
    final churches =
        await (db.select(db.churches)
              ..where((t) => t.locale.equals(locale))
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
    Church? selectedChurch;
    if (selectedChurchId != null) {
      for (final church in churches) {
        if (church.id == selectedChurchId) {
          selectedChurch = church;
          break;
        }
      }
    }
    final churchForMass = selectedChurch;
    final massTimes = churchForMass == null
        ? <MassTime>[]
        : await (db.select(db.massTimes)
                ..where((t) => t.churchId.equals(churchForMass.id))
                ..orderBy([(t) => OrderingTerm.asc(t.time)]))
              .get();

    return _ChurchViewData(
      churches: churches,
      selectedChurch: selectedChurch,
      massTimes: massTimes,
    );
  }

  Future<void> _selectChurch(Church church) async {
    await ref
        .read(userSettingsRepositoryProvider)
        .setSelectedChurchId(church.id);
    if (mounted) {
      setState(() => _future = _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhà thờ')),
      body: FutureBuilder<_ChurchViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final churches = data.churches.where((church) {
            final value = _query.trim().toLowerCase();
            if (value.isEmpty) {
              return true;
            }
            return church.name.toLowerCase().contains(value) ||
                church.address.toLowerCase().contains(value) ||
                church.diocese.toLowerCase().contains(value);
          }).toList();

          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm nhà thờ hoặc giáo xứ',
                ),
              ),
              const SizedBox(height: 14),
              _SelectedChurchCard(
                church: data.selectedChurch,
                massTimes: data.massTimes,
              ),
              const SizedBox(height: 14),
              Text(
                'Danh sách giáo xứ',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (churches.isEmpty)
                const _EmptyChurchState()
              else
                ...churches.map(
                  (church) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ChurchListItem(
                      church: church,
                      selected: church.id == data.selectedChurch?.id,
                      onSelect: () => _selectChurch(church),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectedChurchCard extends StatelessWidget {
  const _SelectedChurchCard({required this.church, required this.massTimes});

  final Church? church;
  final List<MassTime> massTimes;

  @override
  Widget build(BuildContext context) {
    if (church == null) {
      return Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giáo xứ của tôi',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn thủ công một giáo xứ để Today có thể hiển thị Thánh lễ quan trọng. Không cần quyền vị trí.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSignalChip(
              label: 'Giáo xứ của tôi',
              color: AppColors.brand,
              icon: Icons.church_outlined,
            ),
            const SizedBox(height: 10),
            Text(
              church!.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              church!.address,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            if (massTimes.isNotEmpty) ...[
              Text(
                'Thánh lễ kế tiếp',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_weekdayLabel(massTimes.first.weekday)} ${massTimes.first.time}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dữ liệu giáo xứ lưu trên thiết bị. Không dùng vị trí.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'Lịch Thánh lễ',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (massTimes.isEmpty)
              const Text('Chưa có giờ lễ trong gói dữ liệu hiện tại.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: massTimes
                    .map(
                      (mass) => AppSignalChip(
                        label:
                            '${_weekdayLabel(mass.weekday)} ${mass.time} (${mass.language})',
                        color: AppColors.brand,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChurchListItem extends StatelessWidget {
  const _ChurchListItem({
    required this.church,
    required this.selected,
    required this.onSelect,
  });

  final Church church;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: selected
              ? AppColors.brand
              : AppColors.surfaceSecondary,
          foregroundColor: selected ? Colors.white : AppColors.brand,
          child: const Icon(Icons.church_outlined),
        ),
        title: Text(church.name),
        subtitle: Text(church.address),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.brand)
            : TextButton(onPressed: onSelect, child: const Text('Chọn')),
      ),
    );
  }
}

class _EmptyChurchState extends StatelessWidget {
  const _EmptyChurchState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Text(
          'Chưa tìm thấy giáo xứ trong gói dữ liệu hiện tại. Bạn vẫn có thể dùng Today và Progress offline.',
        ),
      ),
    );
  }
}

class _ChurchViewData {
  const _ChurchViewData({
    required this.churches,
    required this.selectedChurch,
    required this.massTimes,
  });

  final List<Church> churches;
  final Church? selectedChurch;
  final List<MassTime> massTimes;
}

String _weekdayLabel(String weekday) {
  return switch (weekday) {
    'monday' => 'T2',
    'tuesday' => 'T3',
    'wednesday' => 'T4',
    'thursday' => 'T5',
    'friday' => 'T6',
    'saturday' => 'T7',
    'sunday' => 'CN',
    _ => 'Ngày',
  };
}
