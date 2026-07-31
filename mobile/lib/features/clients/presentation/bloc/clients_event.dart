
abstract class ClientsEvent {}

class ClientsLoadEvent extends ClientsEvent {}

/// Drops the cached list on sign-out. The bloc outlives the session, so
/// without this the next account renders the previous one's clients on its
/// first frame — before the reload it queues in `initState` has landed.
class ClientsResetEvent extends ClientsEvent {}

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