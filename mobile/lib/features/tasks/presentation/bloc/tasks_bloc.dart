import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:real_estate_crm/features/tasks/presentation/bloc/tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState>
    with SingleFlight, CollectionBloc<TasksEvent, TasksState> {
  final TasksRepository _repo;
  final TaskQuery query;
  late final StreamSubscription<void> _changes;

  TasksBloc(this._repo, {this.query = const TaskQuery()})
      : super(TasksInitial()) {
    on<TasksLoadEvent>(_onLoad);
    on<TasksResetEvent>(_onReset);
    on<TasksCompleteEvent>(_onComplete);
    on<TasksReopenEvent>(_onReopen);
    on<TasksDeleteEvent>(_onDelete);
    _changes = _repo.changes.listen((_) {
      if (!isClosed && state is! TasksInitial) add(TasksLoadEvent());
    });
  }

  List<TaskResponse> get _current {
    final s = state;
    return s is TasksLoaded ? s.tasks : const [];
  }

  void _onReset(TasksResetEvent e, Emitter<TasksState> emit) {
    invalidate();
    emit(TasksInitial());
  }

  Future<void> _onLoad(TasksLoadEvent e, Emitter<TasksState> emit) => load(
        emit,
        keepVisible: state is TasksLoaded,
        skeleton: TasksLoading(),
        fetch: () => _repo.getTasks(query),
        onData: TasksLoaded.new,
        onFailure: TasksError.new,
      );

  Future<void> _act(Emitter<TasksState> emit, String key, ActionMessage message,
          int id, bool leavesList, Future<void> Function() action) =>
      write(
        emit,
        key: key,
        perform: action,
        onSuccess: (_) => TasksActionSuccess(
          message,
          leavesList ? _current.where((t) => t.id != id).toList() : _current,
        ),
        onFailure: (ApiFailure f) => _current.isEmpty && state is! TasksLoaded
            ? TasksError(f)
            : TasksActionFailure(f, _current),
      );

  Future<void> _onComplete(TasksCompleteEvent e, Emitter<TasksState> emit) =>
      _act(emit, 'complete-${e.id}', ActionMessage.taskCompleted, e.id,
          !query.done, () => _repo.completeTask(e.id));

  Future<void> _onReopen(TasksReopenEvent e, Emitter<TasksState> emit) => _act(
      emit,
      'reopen-${e.id}',
      ActionMessage.taskReopened,
      e.id,
      query.done,
      () => _repo.reopenTask(e.id));

  Future<void> _onDelete(TasksDeleteEvent e, Emitter<TasksState> emit) => _act(
      emit,
      'delete-${e.id}',
      ActionMessage.taskDeleted,
      e.id,
      true,
      () => _repo.deleteTask(e.id));

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
