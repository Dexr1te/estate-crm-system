import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_row.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class RecordTasksCard extends StatelessWidget {
  final PickerItem? client;
  final PickerItem? deal;

  const RecordTasksCard({super.key, this.client, this.deal});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => TasksBloc(
          Injector.tasksRepository,
          query: TaskQuery(clientId: client?.id, dealId: deal?.id),
        )..add(TasksLoadEvent()),
        child: _RecordTasksBody(client: client, deal: deal),
      );
}

class _RecordTasksBody extends StatelessWidget {
  final PickerItem? client;
  final PickerItem? deal;
  const _RecordTasksBody({this.client, this.deal});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    void add() => showTaskSheet(context, client: client, deal: deal);

    return BlocConsumer<TasksBloc, TasksState>(
      listener: showActionOutcome,
      builder: (context, state) {
        final tasks = state is TasksLoaded ? state.tasks : null;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: EyebrowLabel(l10n.tasksTitle)),
                  if (tasks != null && tasks.isNotEmpty)
                    Text('${tasks.length}',
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: t.textSecondary)),
                ],
              ),
              const SizedBox(height: 11),
              if (state is TasksError)
                _Line(
                  text: l10n.tasksLoadFailed,
                  action: l10n.coreRetry,
                  onAction: () =>
                      context.read<TasksBloc>().add(TasksLoadEvent()),
                )
              else if (tasks == null)
                const ShimmerGroup(
                  child: Column(children: [
                    ShimmerBar(widthFactor: 0.7, height: 12),
                    SizedBox(height: 10),
                    ShimmerBar(widthFactor: 0.45, height: 10),
                  ]),
                )
              else if (tasks.isEmpty)
                _Line(text: l10n.tasksEmptyRecordHint)
              else
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  TaskRow(
                    task: tasks[i],
                    showLink: false,
                    currentUserId: context.currentUserId,
                    onToggle: () => context
                        .read<TasksBloc>()
                        .add(TasksCompleteEvent(tasks[i].id)),
                    onTap: () => showTaskSheet(context, task: tasks[i]),
                  ),
                ],
              const SizedBox(height: 12),
              AppGhostButton(
                label: l10n.tasksAdd,
                onPressed: add,
                height: AppMetrics.minHitTarget,
                fontSize: 12.5,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const _Line({required this.text, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Text(text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.4,
                  color: t.textSecondary)),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: AppGhostButton(
              label: action!,
              onPressed: onAction,
              height: AppMetrics.buttonHeightInline,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
