import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
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
  }

  List<ClientSummary> get _current {
    final s = state;
    return s is ClientsLoaded ? s.clients : const [];
  }

  ClientsState _failure(String message) => _current.isEmpty
      ? ClientsError(message)
      : ClientsActionFailure(message, _current);

  void _onReset(ClientsResetEvent e, Emitter<ClientsState> emit) {
    invalidate();
    emit(ClientsInitial());
  }

  Future<void> _onLoad(ClientsLoadEvent e, Emitter<ClientsState> emit) => load(
        emit,
        keepVisible: _current.isNotEmpty,
        skeleton: ClientsLoading(),
        // The rows and their deal counts come from two endpoints, and a row
        // without its counts would report a client as having no deals rather
        // than as unknown — so they arrive together or not at all.
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
        onSuccess: (_) => ClientsActionSuccess('Client deleted', _current),
        onFailure: _failure,
        reload: () => add(ClientsLoadEvent()),
      );

  Future<void> _onCreate(ClientsCreateEvent e, Emitter<ClientsState> emit) =>
      write(
        emit,
        // A new client has no id yet; the payload is what makes this submit
        // distinguishable from the next one.
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
        onSuccess: (_) => ClientsActionSuccess('Client updated', _current),
        onFailure: _failure,
        reload: () => add(ClientsLoadEvent()),
      );
}
