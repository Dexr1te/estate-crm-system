import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/calendar/domain/calendar_grid.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/meeting_row.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class DayAgenda extends StatelessWidget {
  final DateTime day;
  final DateTime now;
  final CalendarPage? page;
  final ApiFailure? failure;
  final VoidCallback? onAdd;
  final VoidCallback? onToday;
  final VoidCallback onRetry;
  final ValueChanged<MeetingResponse> onOpenMeeting;
  final ValueChanged<TaskResponse> onOpenTask;
  final ValueChanged<TaskResponse> onToggleTask;

  const DayAgenda({
    super.key,
    required this.day,
    required this.now,
    required this.page,
    required this.failure,
    required this.onRetry,
    required this.onOpenMeeting,
    required this.onOpenTask,
    required this.onToggleTask,
    this.onAdd,
    this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: EyebrowLabel(
                isSameDay(day, now)
                    ? '${l10n.calendarToday}, ${formatDayMonth(day, locale)}'
                    : formatWeekdayDate(day, locale),
                color: t.textSecondary,
              ),
            ),
            if (onToday != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 104),
                  child: AppGhostButton(
                    label: l10n.calendarToday,
                    onPressed: onToday!,
                    height: AppMetrics.minHitTarget,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
            if (onAdd != null) ...[
              const SizedBox(width: 4),
              AppIconTile(
                key: const ValueKey('calendar-add'),
                icon: Icons.add_rounded,
                tooltip: l10n.calendarAdd,
                onPressed: onAdd!,
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        ..._body(context, l10n),
      ],
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l10n) {
    if (failure != null && page == null) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.calendarLoadFailed,
          subtitle: apiFailureLabel(l10n, failure!),
          action: AppGhostButton(label: l10n.coreRetry, onPressed: onRetry),
        ),
      ];
    }
    final loaded = page;
    if (loaded == null) {
      return [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: 9),
          ShimmerGroup(
            child: ShimmerRowCard(
              leading: const ShimmerCircle(size: 22),
              titleFactor: [0.6, 0.45, 0.52][i],
              subtitleFactor: [0.4, 0.3, 0.36][i],
            ),
          ),
        ],
      ];
    }

    final entries = <(DateTime, Widget)>[
      for (final m in loaded.meetingsOn(day))
        (m.scheduledAt, _meeting(m, l10n)),
      for (final task in loaded.tasksOn(day))
        (
          task.dueAt,
          TaskRow(
            key: ValueKey('calendar-task-${task.id}'),
            task: task,
            currentUserId: context.currentUserId,
            onToggle: () => onToggleTask(task),
            onTap: () => onOpenTask(task),
          )
        ),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    if (entries.isEmpty) {
      return [
        EmptyState(
          icon: Icons.event_available_outlined,
          title: l10n.calendarDayEmpty,
          subtitle: onAdd == null ? null : l10n.calendarDayEmptyHint,
        ),
      ];
    }
    return [
      for (var i = 0; i < entries.length; i++) ...[
        if (i > 0) const SizedBox(height: 9),
        entries[i].$2,
      ],
    ];
  }

  Widget _meeting(MeetingResponse m, AppLocalizations l10n) {
    final place = m.propertyTitle ?? m.propertyAddress;
    final meta = [
      m.clientName,
      if (place != null) place,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    final row = MeetingRow(
      key: ValueKey('calendar-meeting-${m.id}'),
      time: formatTimeOfDay(m.scheduledAt),
      dayOrType: m.propertyId != null
          ? l10n.calendarLegendViewing
          : l10n.calendarLegendMeeting,
      title: m.title,
      meta: meta,
      onTap: () => onOpenMeeting(m),
    );
    return m.completed ? Opacity(opacity: 0.6, child: row) : row;
  }
}
