import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_row.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class TodayTasksCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  const TodayTasksCard({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<TasksBloc, TasksState>(
      listener: showActionOutcome,
      builder: (context, state) {
        final now = AppClock.now();
        final loaded = state is TasksLoaded ? state : null;
        final overdue = loaded?.overdue(now) ?? const [];
        final today = [...overdue, ...?loaded?.dueLaterToday(now)];

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(child: EyebrowLabel(l10n.dashboardTasksToday)),
                  if (overdue.isNotEmpty)
                    Flexible(
                      child: Text(
                          l10n.dashboardTasksOverdueCount(overdue.length),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: t.dangerText)),
                    ),
                ],
              ),
              const SizedBox(height: 11),
              if (state is TasksError)
                Text(l10n.tasksLoadFailed,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
                        color: t.textSecondary))
              else if (loaded == null)
                const ShimmerGroup(
                  child: Column(children: [
                    ShimmerBar(widthFactor: 0.72, height: 12),
                    SizedBox(height: 10),
                    ShimmerBar(widthFactor: 0.5, height: 10),
                  ]),
                )
              else if (today.isEmpty)
                Text(l10n.dashboardTasksClear,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
                        color: t.textSecondary))
              else
                for (var i = 0; i < today.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  TaskRow(
                    task: today[i],
                    currentUserId: context.currentUserId,
                    onToggle: () => context
                        .read<TasksBloc>()
                        .add(TasksCompleteEvent(today[i].id)),
                    onTap: () => showTaskSheet(context, task: today[i]),
                  ),
                ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppGhostButton(
                      label: l10n.tasksAllTasks,
                      onPressed: onSeeAll,
                      height: AppMetrics.buttonHeightInline,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppGhostButton(
                      label: l10n.tasksAdd,
                      onPressed: () => showTaskSheet(context),
                      height: AppMetrics.buttonHeightInline,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
