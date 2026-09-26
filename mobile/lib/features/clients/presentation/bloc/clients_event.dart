abstract class ClientsEvent {}

class ClientsLoadEvent extends ClientsEvent {}

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

/// Folds [sourceId] into [targetId]; the source card is deleted.
class ClientsMergeEvent extends ClientsEvent {
  final int targetId;
  final int sourceId;
  ClientsMergeEvent({required this.targetId, required this.sourceId});
}
