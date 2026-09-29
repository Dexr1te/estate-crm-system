import 'package:real_estate_crm/core/models/models.dart';

abstract class ColdClientsEvent {}

/// Loads at [days], or at the current threshold when it is null.
class ColdClientsLoadEvent extends ColdClientsEvent {
  final int? days;
  ColdClientsLoadEvent({this.days});
}

/// Creates a task to call [client], due at [dueAt], titled [title].
class ColdClientsRemindEvent extends ColdClientsEvent {
  final ColdClient client;
  final String title;
  final DateTime dueAt;
  ColdClientsRemindEvent(this.client,
      {required this.title, required this.dueAt});
}

/// Takes back the reminder [taskId]; the client comes back to the list.
class ColdClientsUndoRemindEvent extends ColdClientsEvent {
  final int taskId;
  ColdClientsUndoRemindEvent(this.taskId);
}
