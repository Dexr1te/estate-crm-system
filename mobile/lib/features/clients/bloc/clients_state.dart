
import 'package:real_estate_crm/core/models/models.dart';

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