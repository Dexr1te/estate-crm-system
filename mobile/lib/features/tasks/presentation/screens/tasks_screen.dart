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

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _open = TasksBloc(Injector.tasksRepository)..add(TasksLoadEvent());
  final _done =
      TasksBloc(Injector.tasksRepository, query: const TaskQuery(done: true));
  int _tab = 0;

  TasksBloc get _shown => _tab == 0 ? _open : _done;

  @override
  void dispose() {
    _open.close();
    _done.close();
    super.dispose();
  }

  void _select(int tab) {
    setState(() => _tab = tab);
    if (tab == 1 && _done.state is TasksInitial) _done.add(TasksLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _shown,
      child: BlocConsumer<TasksBloc, TasksState>(
        listener: showActionOutcome,
        builder: (context, state) => DetailScaffold(
          title: l10n.tasksTitle,
          trailingLabel: _tab == 0 && state is TasksLoaded
              ? l10n.tasksCounter(state.tasks.length)
              : null,
          onRefresh: () async => _shown.add(TasksLoadEvent()),
          bottomAction: AppFilledButton(
            label: l10n.tasksAdd,
            onPressed: () => showTaskSheet(context),
          ),
          children: [
            SegmentedTabs(
              labels: [l10n.tasksOpenTab, l10n.tasksDoneTab],
              selectedIndex: _tab,
              onSelected: _select,
            ),
            ..._body(context, state, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
      BuildContext context, TasksState state, AppLocalizations l10n) {
    if (state is TasksError) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.tasksLoadFailed,
          subtitle: apiFailureLabel(l10n, state.failure),
          action: AppGhostButton(
              label: l10n.coreRetry,
              onPressed: () => _shown.add(TasksLoadEvent())),
        ),
      ];
    }
    if (state is! TasksLoaded) {
      return [
        for (var i = 0; i < 4; i++)
          const ShimmerGroup(
            child: ShimmerRowCard(
              leading: ShimmerCircle(size: 22),
              titleFactor: 0.6,
              subtitleFactor: 0.4,
            ),
          ),
      ];
    }
    if (state.tasks.isEmpty) {
      return [
        _tab == 0
            ? EmptyState(
                icon: Icons.task_alt_rounded,
                title: l10n.tasksEmptyOpen,
                subtitle: l10n.tasksEmptyOpenHint,
              )
            : EmptyState(
                icon: Icons.history_rounded,
                title: l10n.tasksEmptyDone,
              ),
      ];
    }
    return [
      for (final task in state.tasks)
        TaskRow(
          task: task,
          currentUserId: context.currentUserId,
          onToggle: () => _shown.add(task.isDone
              ? TasksReopenEvent(task.id)
              : TasksCompleteEvent(task.id)),
          onTap: () => showTaskSheet(context, task: task),
        ),
    ];
  }
}
