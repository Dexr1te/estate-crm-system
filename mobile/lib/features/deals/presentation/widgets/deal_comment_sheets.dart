import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What can be done to a comment from a long press: its author corrects or
/// removes it; a manager can remove anyone's.
Future<void> showCommentActions(
  BuildContext context, {
  required bool canEdit,
  required bool canDelete,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) async {
  final l10n = AppLocalizations.of(context);
  final choice = await showAppBottomSheet<String>(
    context,
    builder: (sheet) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canEdit)
          _ActionTile(
            key: const ValueKey('comment-action-edit'),
            icon: Icons.edit_outlined,
            label: l10n.dealsCommentEdit,
            onTap: () => Navigator.of(sheet).pop('edit'),
          ),
        if (canDelete)
          _ActionTile(
            key: const ValueKey('comment-action-delete'),
            icon: Icons.delete_outline_rounded,
            label: l10n.dealsCommentDelete,
            danger: true,
            onTap: () => Navigator.of(sheet).pop('delete'),
          ),
      ],
    ),
  );
  if (!context.mounted) return;
  if (choice == 'edit') onEdit();
  if (choice == 'delete') {
    final ok = await showConfirmDialog(context,
        title: l10n.dealsCommentDeleteTitle,
        content: l10n.dealsCommentDeleteBody);
    if (ok) onDelete();
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = danger ? t.dangerText : t.textPrimary;
    return InkWell(
      borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      onTap: onTap,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: AppMetrics.minHitTarget + 4),
        child: Row(children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color)),
          ),
        ]),
      ),
    );
  }
}

/// Corrects the text of a comment. The people it mentions stay mentioned as
/// long as their names are still in it.
Future<void> showEditCommentSheet(
  BuildContext context,
  DealComment comment, {
  required ValueChanged<String> onSave,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<void>(
    context,
    title: l10n.dealsCommentEdit,
    builder: (_) => _EditComment(initial: comment.body, onSave: onSave),
  );
}

class _EditComment extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onSave;
  const _EditComment({required this.initial, required this.onSave});

  @override
  State<_EditComment> createState() => _EditCommentState();
}

class _EditCommentState extends State<_EditComment> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    final changed = text.isNotEmpty && text != widget.initial.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        AppTextField(
          key: const ValueKey('comment-edit-field'),
          controller: _controller,
          keyboardType: TextInputType.multiline,
          minLines: 2,
          maxLines: 8,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        AppFilledButton(
          key: const ValueKey('comment-edit-save'),
          label: l10n.coreSave,
          onPressed: changed
              ? () {
                  widget.onSave(text);
                  Navigator.of(context).pop();
                }
              : null,
        ),
      ],
    );
  }
}
