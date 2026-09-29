import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/cold_clients_repository.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/cold_clients_state.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';

/// Who is going cold, at a threshold of days, and the one-tap reminder.
///
/// A reminder is a task due later linked to the client, which is exactly what
/// takes a client off the list on the server — so the row leaves at once
/// rather than waiting for a reload.
class ColdClientsBloc extends Bloc<ColdClientsEvent, ColdClientsState>
    with SingleFlight, CollectionBloc<ColdClientsEvent, ColdClientsState> {
  final ColdClientsRepository _repo;
  final TasksRepository _tasks;
  final int limit;

  ColdClientsBloc(
    this._repo,
    this._tasks, {
    this.limit = 20,
    int days = ColdClientsRepository.defaultDays,
  }) : super(ColdClientsInitial(days)) {
    on<ColdClientsLoadEvent>(_onLoad);
    on<ColdClientsRemindEvent>(_onRemind);
    on<ColdClientsUndoRemindEvent>(_onUndo);
  }

  List<ColdClient> get _current {
    final s = state;
    return s is ColdClientsLoaded ? s.clients : const [];
  }

  Future<void> _onLoad(ColdClientsLoadEvent e, Emitter<ColdClientsState> emit) {
    final days = e.days ?? state.days;
    final sameThreshold = days == state.days;
    return load(
      emit,
      keepVisible: sameThreshold && state is ColdClientsLoaded,
      skeleton: ColdClientsLoading(days),
      fetch: () => _repo.getColdClients(days: days, limit: limit),
      onData: (clients) => ColdClientsLoaded(clients, days),
      onFailure: (f) => ColdClientsError(f, days),
    );
  }

  Future<void> _onRemind(
          ColdClientsRemindEvent e, Emitter<ColdClientsState> emit) =>
      write(
        emit,
        key: 'remind-${e.client.id}',
        perform: () => _tasks.createTask({
          'title': e.title,
          'dueAt': e.dueAt.toIso8601String(),
          'clientId': e.client.id,
        }),
        onSuccess: (TaskResponse task) => ColdClientsReminderSet(
          task.id,
          e.dueAt,
          _current.where((c) => c.id != e.client.id).toList(),
          state.days,
        ),
        onFailure: (ApiFailure f) =>
            ColdClientsActionFailure(f, _current, state.days),
      );

  Future<void> _onUndo(
          ColdClientsUndoRemindEvent e, Emitter<ColdClientsState> emit) =>
      write(
        emit,
        key: 'undo-${e.taskId}',
        perform: () => _tasks.deleteTask(e.taskId),
        onSuccess: (_) => ColdClientsLoaded(_current, state.days),
        onFailure: (ApiFailure f) =>
            ColdClientsActionFailure(f, _current, state.days),
        reload: () => add(ColdClientsLoadEvent()),
      );
}
