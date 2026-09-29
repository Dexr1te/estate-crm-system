import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum ChecklistRowAction { attach, detach, delete }

/// One line of a deal's checklist: a box to tick, who ticked it and when,
/// the document that proves it, and what else can be done with it.
class ChecklistItemRow extends StatelessWidget {
  final ChecklistItem item;
  final bool busy;
  final bool canDelete;
  final VoidCallback onToggle;
  final ValueChanged<ChecklistRowAction> onAction;

  const ChecklistItemRow({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onAction,
    this.busy = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final doneAt = item.doneAt == null
        ? null
        : formatDayMonth(item.doneAt!.toLocal(), language);
    final small = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11.5, color: t.textSecondary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          checked: item.done,
          label: item.title,
          child: InkWell(
            key: ValueKey('checklist-toggle-${item.id}'),
            onTap: busy ? null : onToggle,
            borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
            child: SizedBox.square(
              dimension: AppMetrics.minHitTarget,
              child: Center(child: _Box(done: item.done, busy: busy)),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13.5,
                    height: 1.3,
                    color: item.done ? t.textSecondary : t.textPrimary,
                    decoration: item.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.required && !item.done) ...[
                  const SizedBox(height: 3),
                  Text(
                    l10n.dealsChecklistRequired,
                    key: ValueKey('checklist-required-${item.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: small.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: t.dangerText),
                  ),
                ],
                if (item.done && doneAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.doneByName == null || item.doneByName!.isEmpty
                        ? l10n.dealsChecklistDoneAt(doneAt)
                        : l10n.dealsChecklistDoneBy(doneAt, item.doneByName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: small,
                  ),
                ],
                if (item.documentName != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.attach_file_rounded,
                        size: 13, color: t.textSecondary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(item.documentName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ),
        PopupMenuButton<ChecklistRowAction>(
          key: ValueKey('checklist-menu-${item.id}'),
          tooltip: l10n.dealsChecklistMore,
          enabled: !busy,
          icon: Icon(Icons.more_horiz_rounded, size: 20, color: t.textHint),
          onSelected: onAction,
          itemBuilder: (_) => [
            _entry(ChecklistRowAction.attach, l10n.dealsChecklistAttach),
            if (item.documentId != null)
              _entry(ChecklistRowAction.detach, l10n.dealsChecklistDetach),
            if (canDelete && item.custom)
              _entry(ChecklistRowAction.delete, l10n.dealsChecklistDelete),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<ChecklistRowAction> _entry(
          ChecklistRowAction action, String label) =>
      PopupMenuItem(
        value: action,
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: AppFonts.sans, fontSize: 13.5)),
      );
}

class _Box extends StatelessWidget {
  final bool done;
  final bool busy;
  const _Box({required this.done, required this.busy});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: busy ? 0.5 : 1,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: done ? t.primary : t.surface,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: done ? t.primary : t.border, width: 1.5),
        ),
        child: done
            ? Icon(Icons.check_rounded, size: 16, color: t.onPrimary)
            : null,
      ),
    );
  }
}
