import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_form.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Future<void> showTaskSheet(
  BuildContext context, {
  TaskResponse? task,
  PickerItem? client,
  PickerItem? deal,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = Injector.tasksRepository;
  final me = context.read<AuthBloc>().currentUser;
  final canAssign = context.isAdminOrManager;
  final assignee = task != null && task.assigneeId != null
      ? PickerItem(id: task.assigneeId!, title: task.assigneeName ?? '')
      : me == null
          ? null
          : PickerItem(id: me.userId, title: me.fullName);

  final message = await showAppBottomSheet<ActionMessage>(
    context,
    title: task == null ? l10n.tasksNew : l10n.tasksEdit,
    builder: (sheet) => TaskForm(
      task: task,
      client: task?.clientId != null
          ? PickerItem(id: task!.clientId!, title: task.clientName ?? '')
          : task == null
              ? client
              : null,
      deal: task?.dealId != null
          ? PickerItem(id: task!.dealId!, title: task.dealTitle ?? '')
          : task == null
              ? deal
              : null,
      assignee: assignee,
      canAssign: canAssign,
      onSave: (data) async {
        if (task == null) {
          await repo.createTask(data);
        } else {
          await repo.updateTask(task.id, data);
        }
        if (sheet.mounted) {
          Navigator.pop(
              sheet,
              task == null
                  ? ActionMessage.taskCreated
                  : ActionMessage.taskUpdated);
        }
      },
      onDelete: task == null
          ? null
          : () async {
              await repo.deleteTask(task.id);
              if (sheet.mounted) {
                Navigator.pop(sheet, ActionMessage.taskDeleted);
              }
            },
    ),
  );
  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(actionMessageLabel(l10n, message),
            maxLines: 2, overflow: TextOverflow.ellipsis)));
}
