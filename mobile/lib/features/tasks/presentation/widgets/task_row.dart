import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_time.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class TaskRow extends StatelessWidget {
  final TaskResponse task;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  final int? currentUserId;
  final bool showLink;

  const TaskRow({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
    this.currentUserId,
    this.showLink = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final overdue = isOverdue(task, now);
    final link = showLink ? (task.clientName ?? task.dealTitle) : null;
    final assignee = task.assigneeName?.trim();
    final forSomeoneElse = currentUserId != null &&
        task.assigneeId != null &&
        task.assigneeId != currentUserId &&
        assignee != null &&
        assignee.isNotEmpty;
    final when = task.isDone && task.completedAt != null
        ? l10n.tasksDoneOn(formatDayMonth(task.completedAt!, locale))
        : dueLabel(l10n, task.dueAt, now, locale);
    final meta = [
      if (link != null && link.trim().isNotEmpty) link.trim(),
      if (forSomeoneElse) l10n.tasksAssignedTo(assignee),
    ].join(' · ');

    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: AppMetrics.minHitTarget,
            height: AppMetrics.minHitTarget,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: task.isDone ? l10n.tasksReopen : l10n.tasksComplete,
              onPressed: onToggle,
              icon: Icon(
                task.isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: task.isDone ? t.textSecondary : t.textHint,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? t.textSecondary : t.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta.isEmpty ? when : '$when · $meta',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11,
                        color: overdue ? t.dangerText : t.textHint),
                  ),
                ],
              ),
            ),
          ),
          if (overdue) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child:
                  StatusChip(label: l10n.tasksOverdue, hue: StatusHue.danger),
            ),
          ],
        ],
      ),
    );
  }
}
