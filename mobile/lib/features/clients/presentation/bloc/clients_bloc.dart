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

  /// Whatever is currently on screen, so a write's outcome can carry it
  /// forward instead of blanking the list.
  List<ClientSummary> get _current {
    final s = state;
    return s is ClientsLoaded ? s.clients : const [];
  }

  /// A write failed. Keep whatever is on screen; only a failed *load* leaves
  /// the user with nothing to look at.
  ClientsState _failure(Object err) => _current.isEmpty
      ? ClientsError(apiErrorMessage(err))
      : ClientsActionFailure(apiErrorMessage(err), _current);

  void _onReset(ClientsResetEvent e, Emitter<ClientsState> emit) {
    // Invalidate any load still in flight, so a response fetched with the old
    // session's token can't repopulate the list after the reset.
    startLoad();
    emit(ClientsInitial());
  }

  Future<void> _onLoad(ClientsLoadEvent e, Emitter<ClientsState> emit) async {
    final ticket = startLoad();
    emit(ClientsLoading());
    try {
      // Two calls: `/clients` is the authoritative record (type, agent),
      // `/clients/with-details` carries the per-deal figures. See
      // [ClientSummary.join].
      final results = await Future.wait([
        _repo.getClients(),
        _repo.getClientsWithDetails(),
      ]);
      // A newer load started while this one was in flight — its result wins.
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
      emit(ClientCreated(created)); // emit the full object with id
    } catch (err) {
      emit(_failure(err));
    }
  }

  Future<void> _onUpdate(
      ClientsUpdateEvent e, Emitter<ClientsState> emit) async {
    try {
      await _repo.updateClient(e.id, e.data);
      emit(ClientsActionSuccess('Client updated', _current));
    } catch (err) {
      emit(_failure(err));
    }
  }
}
