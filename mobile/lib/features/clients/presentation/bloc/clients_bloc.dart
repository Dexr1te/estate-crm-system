import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/clients/domain/repositories/clients_repository.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final ClientsRepository _repo;
  ClientsBloc(this._repo) : super(ClientsInitial()) {
    on<ClientsLoadEvent>(_onLoad);
    on<ClientsDeleteEvent>(_onDelete);
    on<ClientsCreateEvent>(_onCreate);
    on<ClientsUpdateEvent>(_onUpdate);
  }

  Future<void> _onLoad(ClientsLoadEvent e, Emitter<ClientsState> emit) async {
    emit(ClientsLoading());
    try {
      emit(ClientsLoaded(await _repo.getClientsWithDetails()));
    } catch (err) {
      emit(ClientsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onDelete(
      ClientsDeleteEvent e, Emitter<ClientsState> emit) async {
    try {
      await _repo.deleteClient(e.id);
      emit(ClientsActionSuccess('Client deleted'));
      add(ClientsLoadEvent());
    } catch (err) {
      emit(ClientsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onCreate(
      ClientsCreateEvent e, Emitter<ClientsState> emit) async {
    try {
      final created = await _repo.createClient(e.data);
      emit(ClientCreated(created)); // emit the full object with id
    } catch (err) {
      emit(ClientsError(apiErrorMessage(err)));
    }
  }

  Future<void> _onUpdate(
      ClientsUpdateEvent e, Emitter<ClientsState> emit) async {
    try {
      await _repo.updateClient(e.id, e.data);
      emit(ClientsActionSuccess('Client updated'));
    } catch (err) {
      emit(ClientsError(apiErrorMessage(err)));
    }
  }
}
