
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