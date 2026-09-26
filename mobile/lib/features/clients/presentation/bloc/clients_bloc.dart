import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState>
    with SingleFlight, CollectionBloc<ClientsEvent, ClientsState> {
  final ClientsRepository _repo;

  ClientsBloc(this._repo) : super(ClientsInitial()) {
    on<ClientsLoadEvent>(_onLoad);
    on<ClientsResetEvent>(_onReset);
    on<ClientsDeleteEvent>(_onDelete);
    on<ClientsCreateEvent>(_onCreate);
    on<ClientsUpdateEvent>(_onUpdate);
    on<ClientsMergeEvent>(_onMerge);
  }

  List<ClientSummary> get _current {
    final s = state;
    return s is ClientsLoaded ? s.clients : const [];
  }

  ClientsState _failure(ApiFailure failure) => _current.isEmpty
      ? ClientsError(failure)
      : ClientsActionFailure(failure, _current);

  void _onReset(ClientsResetEvent e, Emitter<ClientsState> emit) {
    invalidate();
    emit(ClientsInitial());
  }

  Future<void> _onLoad(ClientsLoadEvent e, Emitter<ClientsState> emit) => load(
        emit,
        keepVisible: _current.isNotEmpty,
        skeleton: ClientsLoading(),
        fetch: () => Future.wait([
          _repo.getClients(),
          _repo.getClientsWithDetails(),
        ]),
        onData: (results) => ClientsLoaded(ClientSummary.join(
          results[0] as List<ClientResponse>,
          results[1] as List<ClientListItem>,
        )),
        onFailure: ClientsError.new,
      );

  Future<void> _onDelete(ClientsDeleteEvent e, Emitter<ClientsState> emit) =>
      write(
        emit,
        key: 'delete-${e.id}',
        perform: () => _repo.deleteClient(e.id),
        onSuccess: (_) =>
            ClientsActionSuccess(ActionMessage.clientDeleted, _current),
        onFailure: _failure,
        reload: () => add(ClientsLoadEvent()),
      );

  Future<void> _onCreate(ClientsCreateEvent e, Emitter<ClientsState> emit) =>
      write(
        emit,
        key: 'create-${e.data['fullName']}-${e.data['phone']}',
        perform: () => _repo.createClient(e.data),
        onSuccess: (created) => ClientCreated(created, _current),
        onFailure: _failure,
        reload: () => add(ClientsLoadEvent()),
      );

  Future<void> _onUpdate(ClientsUpdateEvent e, Emitter<ClientsState> emit) =>
      write(
        emit,
        key: 'update-${e.id}',
        perform: () => _repo.updateClient(e.id, e.data),
        onSuccess: (_) =>
            ClientsActionSuccess(ActionMessage.clientUpdated, _current),
        onFailure: _failure,
        reload: () => add(ClientsLoadEvent()),
      );

  Future<void> _onMerge(ClientsMergeEvent e, Emitter<ClientsState> emit) =>
      write(
        emit,
        key: 'merge-${e.targetId}-${e.sourceId}',
        perform: () => _repo.mergeClients(e.targetId, e.sourceId),
        onSuccess: (merged) => ClientsMerged(merged, _current),
        onFailure: _failure,
        reload: () => add(ClientsLoadEvent()),
      );
}
