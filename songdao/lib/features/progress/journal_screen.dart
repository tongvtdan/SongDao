import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/design_system.dart';
import '../../app/sentence_capitalization_formatter.dart';
import '../../app/theme.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/daos/action_log_dao.dart';
import '../../data/local/daily_action_engine.dart';
import '../../data/local/database_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _searchController = TextEditingController();
  late Future<List<JournalEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
    _searchController.addListener(_refreshEntries);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshEntries)
      ..dispose();
    super.dispose();
  }

  Future<List<JournalEntry>> _loadEntries() async {
    await ref.read(seedContentBootstrapProvider.future);
    return ref
        .read(databaseProvider)
        .actionLogDao
        .getJournalEntries(query: _searchController.text);
  }

  void _refreshEntries() {
    setState(() => _entriesFuture = _loadEntries());
  }

  Future<void> _saveEntry(String actionId, String note) async {
    await ref.read(databaseProvider).actionLogDao.saveNote(actionId, note);
    _refreshEntries();
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú?'),
        content: const Text(
          'Ghi chú riêng này sẽ được xóa khỏi thiết bị của bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(databaseProvider).actionLogDao.clearNote(entry.action.id);
    _refreshEntries();
  }

  Future<void> _addEntry() async {
    final result = await _showNoteEditor();
    if (result == null) {
      return;
    }

    await ref.read(seedContentBootstrapProvider.future);
    final db = ref.read(databaseProvider);
    final locale = await ref.read(userSettingsRepositoryProvider).locale();
    final action = await DailyActionEngine(
      db,
    ).getOrCreateActionForDate(_dateKey(result.date), locale: locale);
    await db.actionLogDao.saveNote(action.id, result.note);
    _refreshEntries();
  }

  Future<void> _editEntry(JournalEntry entry) async {
    final result = await _showNoteEditor(entry: entry);
    if (result == null) {
      return;
    }
    await _saveEntry(entry.action.id, result.note);
  }

  Future<_NoteEditorResult?> _showNoteEditor({JournalEntry? entry}) {
    final initialDate = entry == null
        ? DateTime.now()
        : DateTime.parse(entry.log.date);
    final noteController = TextEditingController(text: entry?.note ?? '');
    var selectedDate = initialDate;

    return showDialog<_NoteEditorResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canSave = noteController.text.trim().isNotEmpty;
            return AlertDialog(
              title: Text(entry == null ? 'Thêm ghi chú' : 'Sửa ghi chú'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (entry == null) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2026),
                            lastDate: DateTime(2026, 12, 31),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(_formatDate(selectedDate)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: noteController,
                      minLines: 4,
                      maxLines: 8,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      inputFormatters: const [
                        SentenceCapitalizationFormatter(),
                      ],
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Viết một câu bạn muốn giữ lại.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lưu riêng trên thiết bị của bạn.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton.icon(
                  onPressed: canSave
                      ? () => Navigator.of(context).pop(
                          _NoteEditorResult(
                            date: selectedDate,
                            note: noteController.text.trim(),
                          ),
                        )
                      : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(noteController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhật ký riêng')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        tooltip: 'Thêm ghi chú',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? const <JournalEntry>[];
          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Text(
                'Ghi chú đức tin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Riêng tư và chỉ lưu trên thiết bị.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm ghi chú hoặc việc đã làm',
                ),
              ),
              const SizedBox(height: 14),
              if (entries.isEmpty)
                AppSectionCard(
                  icon: Icons.lock_outline,
                  title: 'Chưa có ghi chú',
                  child: Text(
                    _searchController.text.trim().isEmpty
                        ? 'Khi bạn ghi lại một câu riêng tư, nó sẽ hiện ở đây.'
                        : 'Không tìm thấy ghi chú phù hợp.',
                  ),
                )
              else
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _JournalEntryCard(
                      entry: entry,
                      onEdit: () => _editEntry(entry),
                      onDelete: () => _deleteEntry(entry),
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

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppBentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(DateTime.parse(entry.log.date)),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.action.prompt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Sửa',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Xóa',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.note,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteEditorResult {
  const _NoteEditorResult({required this.date, required this.note});

  final DateTime date;
  final String note;
}

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
