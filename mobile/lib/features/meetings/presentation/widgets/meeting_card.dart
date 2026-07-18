import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

/// List-item card for a single meeting: icon, title/client, schedule, location
/// and a completed badge. Actions are delegated via callbacks.
class MeetingCard extends StatelessWidget {
  final MeetingResponse meeting;
  final VoidCallback onComplete, onEdit, onDelete;
  const MeetingCard(
      {super.key,
      required this.meeting,
      required this.onComplete,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: meeting.completed
                      ? AppColors.success.withAlpha(26)
                      : cs.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                    meeting.completed
                        ? Icons.check_circle
                        : Icons.calendar_today,
                    color: meeting.completed ? AppColors.success : cs.primary,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(meeting.title,
                        style: tt.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(meeting.clientName, style: tt.bodySmall),
                  ])),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'complete') onComplete();
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  if (!meeting.completed)
                    const PopupMenuItem(
                        value: 'complete',
                        child: Row(children: [
                          Icon(Icons.check, size: 16, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('Mark Complete')
                        ])),
                  const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit')
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error))
                      ])),
                ],
                child:
                    Icon(Icons.more_vert, color: tt.bodySmall?.color, size: 20),
              ),
            ]),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.access_time_outlined,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(formatDateTime(meeting.scheduledAt),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500)),
              if (meeting.location != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.location_on_outlined,
                    size: 14, color: tt.bodySmall?.color),
                const SizedBox(width: 4),
                Flexible(
                    child: Text(meeting.location!,
                        style: tt.bodySmall, overflow: TextOverflow.ellipsis)),
              ],
            ]),
            if (meeting.completed)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(26),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Completed',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  )),
          ])),
    );
  }
}
