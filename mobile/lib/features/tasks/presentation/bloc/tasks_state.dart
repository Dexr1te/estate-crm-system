import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class TasksState {}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskResponse> tasks;
  TasksLoaded(this.tasks);

  List<TaskResponse> overdue(DateTime now) =>
      tasks.where((t) => !t.isDone && t.dueAt.isBefore(now)).toList();

  List<TaskResponse> dueLaterToday(DateTime now) {
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return tasks
        .where((t) =>
            !t.isDone && !t.dueAt.isBefore(now) && t.dueAt.isBefore(midnight))
        .toList();
  }
}

class TasksError extends TasksState {
  final ApiFailure failure;
  TasksError(this.failure);
}

class TasksActionSuccess extends TasksLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  TasksActionSuccess(this.message, super.tasks);
}

class TasksActionFailure extends TasksLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  TasksActionFailure(this.failure, super.tasks);
}
