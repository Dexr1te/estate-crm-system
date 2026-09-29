import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One line of the agency template in the editor: a handle to drag it by,
/// its words (tap to rename), whether it is required, and a way to remove it.
class TemplateLineRow extends StatelessWidget {
  final TemplateLine line;
  final int index;
  final VoidCallback onRename;
  final VoidCallback onToggleRequired;
  final VoidCallback onDelete;

  const TemplateLineRow({
    super.key,
    required this.line,
    required this.index,
    required this.onRename,
    required this.onToggleRequired,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Tooltip(
              message: l10n.teamsChecklistReorder,
              child: SizedBox.square(
                key: ValueKey('template-handle-${line.key}'),
                dimension: AppMetrics.minHitTarget,
                child: Icon(Icons.drag_indicator_rounded,
                    size: 20, color: t.textHint),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    key: ValueKey('template-title-${line.key}'),
                    onTap: onRename,
                    borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        line.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 13.5,
                            height: 1.3,
                            color: t.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FilterPill(
                    key: ValueKey('template-required-${line.key}'),
                    label: l10n.dealsChecklistRequired,
                    selected: line.required,
                    onCard: true,
                    fontSize: 11,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    onTap: onToggleRequired,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            key: ValueKey('template-delete-${line.key}'),
            tooltip: l10n.teamsChecklistDelete,
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                size: 20, color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
