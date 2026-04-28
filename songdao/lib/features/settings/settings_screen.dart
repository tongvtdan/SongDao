import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/local/database_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late Future<_SettingsViewData> _future;
  bool _savingLunar = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SettingsViewData> _load() async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final locale = await repo.locale();
    final showLunarDate = await repo.showLunarDate();
    final selectedChurchId = await repo.selectedChurchId();
    return _SettingsViewData(
      locale: locale,
      showLunarDate: showLunarDate,
      selectedChurchId: selectedChurchId,
    );
  }

  Future<void> _setShowLunarDate(bool value) async {
    if (_savingLunar) {
      return;
    }
    setState(() => _savingLunar = true);
    try {
      await ref.read(userSettingsRepositoryProvider).setShowLunarDate(value);
      if (mounted) {
        setState(() => _future = _load());
      }
    } finally {
      if (mounted) {
        setState(() => _savingLunar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: FutureBuilder<_SettingsViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final lunarSupported = data.locale == 'vi';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _SettingsCard(
                title: 'Lịch Việt',
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: lunarSupported && data.showLunarDate,
                  onChanged: lunarSupported && !_savingLunar
                      ? _setShowLunarDate
                      : null,
                  title: const Text('Hiển thị ngày âm'),
                  subtitle: Text(
                    lunarSupported
                        ? 'Ngày âm chỉ áp dụng cho giao diện tiếng Việt.'
                        : 'Ngày âm đang tắt vì ngôn ngữ hiện tại không phải tiếng Việt.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'Quyền riêng tư',
                child: const Text(
                  'Lịch sử thực hành và ghi chú suy niệm mặc định chỉ lưu trên máy. Đồng bộ, phân tích sử dụng và vị trí là tuỳ chọn, không bắt buộc.',
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'Giáo xứ',
                child: Text(
                  data.selectedChurchId == null
                      ? 'Chưa chọn giáo xứ. Bạn có thể chọn thủ công trong tab Nhà thờ.'
                      : 'Giáo xứ đã chọn được lưu trên thiết bị.',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsViewData {
  const _SettingsViewData({
    required this.locale,
    required this.showLunarDate,
    required this.selectedChurchId,
  });

  final String locale;
  final bool showLunarDate;
  final String? selectedChurchId;
}
