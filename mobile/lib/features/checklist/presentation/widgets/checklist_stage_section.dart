import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_item_row.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_sheets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One stage of a deal's checklist: a header that folds it, and its lines.
class ChecklistStageSection extends StatelessWidget {
  final ChecklistStage stage;
  final List<ChecklistItem> items;
  final bool open;
  final Set<int> busyIds;
  final bool canDelete;
  final VoidCallback onHeader;
  final ValueChanged<ChecklistItem> onToggle;
  final void Function(ChecklistItem, ChecklistRowAction) onAction;

  const ChecklistStageSection({
    super.key,
    required this.stage,
    required this.items,
    required this.open,
    required this.onHeader,
    required this.onToggle,
    required this.onAction,
    this.busyIds = const {},
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final done = items.where((i) => i.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: ValueKey('checklist-stage-${stage.name}'),
          onTap: onHeader,
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppMetrics.minHitTarget),
            child: Row(children: [
              Expanded(
                child: Text(
                  checklistStageLabel(l10n, stage),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              Text(
                '$done/${items.length}',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    color: t.textSecondary),
              ),
              const SizedBox(width: 4),
              Icon(
                open
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: t.textHint,
              ),
            ]),
          ),
        ),
        if (open && items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.dealsChecklistEmptyStage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12,
                  color: t.textSecondary),
            ),
          ),
        if (open)
          for (final item in items)
            ChecklistItemRow(
              key: ValueKey('checklist-item-${item.id}'),
              item: item,
              busy: busyIds.contains(item.id),
              canDelete: canDelete,
              onToggle: () => onToggle(item),
              onAction: (a) => onAction(item, a),
            ),
      ],
    );
  }
}

/// The checklist on its way: a header's height and two lines.
class ChecklistBones extends StatelessWidget {
  const ChecklistBones({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 12),
            ShimmerBar(widthFactor: 0.4, height: 12),
            SizedBox(height: 18),
            _LineBone(),
            SizedBox(height: 14),
            _LineBone(),
            SizedBox(height: 8),
          ],
        ),
      );
}

class _LineBone extends StatelessWidget {
  const _LineBone();

  @override
  Widget build(BuildContext context) => const Row(children: [
        ShimmerBox(width: 22, height: 22, radius: 7),
        SizedBox(width: 14),
        Expanded(child: ShimmerBar(widthFactor: 0.7, height: 12)),
      ]);
}

class ChecklistLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ChecklistLoadError(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans, fontSize: 12, color: t.dangerText),
        ),
        const SizedBox(height: 11),
        SizedBox(
          width: 150,
          child: AppGhostButton(
            label: AppLocalizations.of(context).coreRetry,
            height: AppMetrics.buttonHeightInline,
            onPressed: onRetry,
          ),
        ),
      ],
    );
  }
}
