import 'package:flutter/material.dart';

import '../../../app/design_system.dart';
import '../../../app/sentence_capitalization_formatter.dart';
import '../../../app/theme.dart';

class ReflectionNoteCard extends StatelessWidget {
  const ReflectionNoteCard({
    super.key,
    required this.controller,
    required this.isSaving,
    required this.isDirty,
    required this.hasSavedNote,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool isSaving;
  final bool isDirty;
  final bool hasSavedNote;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final statusText = isSaving
        ? 'Đang lưu...'
        : isDirty || !hasSavedNote
        ? 'Chưa lưu'
        : 'Đã lưu trên thiết bị';
    final statusColor = isDirty || !hasSavedNote
        ? AppColors.gold
        : AppColors.brand;

    return AppSectionCard(
      icon: Icons.lock_outline,
      title: 'Ghi chú riêng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            inputFormatters: const [SentenceCapitalizationFormatter()],
            decoration: const InputDecoration(
              hintText: 'Viết một câu bạn muốn giữ lại cho hôm nay.',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: isSaving || !isDirty ? null : onSave,
                icon: const Icon(Icons.save_outlined),
                label: Text(isSaving ? 'Đang lưu...' : 'Lưu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
