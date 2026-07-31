import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/load_generation.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> with LoadGeneration {
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

  ClientsState _failure(Object err) => _current.isEmpty
      ? ClientsError(apiErrorMessage(err))
      : ClientsActionFailure(apiErrorMessage(err), _current);

  void _onReset(ClientsResetEvent e, Emitter<ClientsState> emit) {
    startLoad();
    emit(ClientsInitial());
  }

  Future<void> _onLoad(ClientsLoadEvent e, Emitter<ClientsState> emit) async {
    final ticket = startLoad();
    if (_current.isEmpty) emit(ClientsLoading());
    try {
      final results = await Future.wait([
        _repo.getClients(),
        _repo.getClientsWithDetails(),
      ]);
      if (isStale(ticket)) return;
      emit(ClientsLoaded(ClientSummary.join(
        results[0] as List<ClientResponse>,
        results[1] as List<ClientListItem>,
      )));
    } catch (err) {
      if (isStale(ticket)) return;
      emit(ClientsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onDelete(
      ClientsDeleteEvent e, Emitter<ClientsState> emit) async {
    try {
      await _repo.deleteClient(e.id);
      emit(ClientsActionSuccess('Client deleted', _current));
      add(ClientsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onCreate(
      ClientsCreateEvent e, Emitter<ClientsState> emit) async {
    try {
      final created = await _repo.createClient(e.data);
      emit(ClientCreated(created, _current));
      add(ClientsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdate(
      ClientsUpdateEvent e, Emitter<ClientsState> emit) async {
    try {
      await _repo.updateClient(e.id, e.data);
      emit(ClientsActionSuccess('Client updated', _current));
      add(ClientsLoadEvent());
    } catch (err) {
      emit(_failure(err));
    }
  }
}
