import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_event.dart';
import 'package:real_estate_crm/features/clients/bloc/clients_state.dart';



class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final ApiService _api;
  ClientsBloc(this._api) : super(ClientsInitial()) {
    on<ClientsLoadEvent>(_onLoad);
    on<ClientsDeleteEvent>(_onDelete);
    on<ClientsCreateEvent>(_onCreate);
    on<ClientsUpdateEvent>(_onUpdate);
  }

  Future<void> _onLoad(ClientsLoadEvent e, Emitter<ClientsState> emit) async {
    emit(ClientsLoading());
    try {
      emit(ClientsLoaded(await _api.getClientsWithDetails()));
    } catch (err) {
      emit(ClientsError(err.toString()));
    }
  }

  Future<void> _onDelete(
      ClientsDeleteEvent e, Emitter<ClientsState> emit) async {
    try {
      await _api.deleteClient(e.id);
      emit(ClientsActionSuccess('Client deleted'));
      add(ClientsLoadEvent());
    } catch (err) {
      emit(ClientsError(err.toString()));
    }
  }

  Future<void> _onCreate(
      ClientsCreateEvent e, Emitter<ClientsState> emit) async {
    try {
      final created = await _api.createClient(e.data);
      emit(ClientCreated(created)); // emit the full object with id
    } catch (err) {
      emit(ClientsError(err.toString()));
    }
  }

  Future<void> _onUpdate(
      ClientsUpdateEvent e, Emitter<ClientsState> emit) async {
    try {
      await _api.updateClient(e.id, e.data);
      emit(ClientsActionSuccess('Client updated'));
    } catch (err) {
      emit(ClientsError(err.toString()));
    }
  }
}
