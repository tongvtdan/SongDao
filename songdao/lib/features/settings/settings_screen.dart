import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/design_system.dart';
import '../../app/theme.dart';
import '../../data/local/database_provider.dart';
import '../../data/local/user_settings_repository.dart';

const _privacyPolicyUrl = 'https://songdao.dantino.com/privacy';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late Future<_SettingsViewData> _future;
  bool _savingLunar = false;
  bool _savingReminder = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SettingsViewData> _load() async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final locale = await repo.locale();
    final showLunarDate = await repo.showLunarDate();
    final dailyReminder = await repo.dailyReminder();
    return _SettingsViewData(
      locale: locale,
      showLunarDate: showLunarDate,
      dailyReminder: dailyReminder,
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

  Future<void> _setReminderEnabled(bool value, _SettingsViewData data) async {
    if (_savingReminder) {
      return;
    }
    setState(() => _savingReminder = true);
    try {
      if (value) {
        final allowed = await ref
            .read(dailyReminderServiceProvider)
            .enableDailyReminder(
              hour: data.dailyReminder.hour,
              minute: data.dailyReminder.minute,
            );
        if (!allowed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bạn có thể bật quyền thông báo trong Cài đặt hệ thống.',
              ),
            ),
          );
        }
      } else {
        await ref.read(dailyReminderServiceProvider).disableDailyReminder();
      }
      if (mounted) {
        setState(() => _future = _load());
      }
    } finally {
      if (mounted) {
        setState(() => _savingReminder = false);
      }
    }
  }

  Future<void> _pickReminderTime(_SettingsViewData data) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: data.dailyReminder.hour,
        minute: data.dailyReminder.minute,
      ),
    );
    if (selected == null || _savingReminder) {
      return;
    }
    setState(() => _savingReminder = true);
    try {
      if (data.dailyReminder.enabled) {
        await ref
            .read(dailyReminderServiceProvider)
            .enableDailyReminder(hour: selected.hour, minute: selected.minute);
      } else {
        await ref
            .read(userSettingsRepositoryProvider)
            .setDailyReminderTime(hour: selected.hour, minute: selected.minute);
      }
      if (mounted) {
        setState(() => _future = _load());
      }
    } finally {
      if (mounted) {
        setState(() => _savingReminder = false);
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
            padding: AppSpacing.screenPadding,
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
                title: 'Nhắc nhở',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: data.dailyReminder.enabled,
                      onChanged: _savingReminder
                          ? null
                          : (value) => _setReminderEnabled(value, data),
                      title: const Text('Nhắc việc sống đạo mỗi ngày'),
                      subtitle: Text(
                        'Thông báo cục bộ lúc ${_formatReminderTime(context, data.dailyReminder)}. Không cần tài khoản hay máy chủ.',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _savingReminder
                            ? null
                            : () => _pickReminderTime(data),
                        icon: const Icon(Icons.schedule),
                        label: const Text('Đổi giờ nhắc'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'Quyền riêng tư',
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch sử thực hành của bạn được lưu trên thiết bị này, trừ khi bạn chọn sao lưu.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sống Đạo hoạt động ngoại tuyến cho việc hôm nay, lịch sử hoàn thành, ghi chú và dữ liệu widget. Đồng bộ, phân tích sử dụng và vị trí là tuỳ chọn, không bắt buộc.',
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Chính sách quyền riêng tư',
                      style: TextStyle(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    SelectableText(_privacyPolicyUrl),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatReminderTime(
  BuildContext context,
  DailyReminderSettings reminder,
) {
  return TimeOfDay(
    hour: reminder.hour,
    minute: reminder.minute,
  ).format(context);
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppBentoCard(
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
    );
  }
}

class _SettingsViewData {
  const _SettingsViewData({
    required this.locale,
    required this.showLunarDate,
    required this.dailyReminder,
  });

  final String locale;
  final bool showLunarDate;
  final DailyReminderSettings dailyReminder;
}
