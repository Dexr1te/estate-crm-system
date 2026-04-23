import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/services/api_service.dart';

abstract class ClientsEvent {}

class ClientsLoadEvent extends ClientsEvent {}

class ClientsDeleteEvent extends ClientsEvent {
  final int id;
  ClientsDeleteEvent(this.id);
}

class ClientsCreateEvent extends ClientsEvent {
  final Map<String, dynamic> data;
  ClientsCreateEvent(this.data);
}

class ClientsUpdateEvent extends ClientsEvent {
  final int id;
  final Map<String, dynamic> data;
  ClientsUpdateEvent(this.id, this.data);
}

abstract class ClientsState {}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<ClientListItem> clients;
  ClientsLoaded(this.clients);
}

class ClientsError extends ClientsState {
  final String message;
  ClientsError(this.message);
}

class ClientsActionSuccess extends ClientsState {
  final String message;
  ClientsActionSuccess(this.message);
}

// NEW: emitted after a successful create, carries the new client's id
class ClientCreated extends ClientsState {
  final ClientResponse client;
  ClientCreated(this.client);
}

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
