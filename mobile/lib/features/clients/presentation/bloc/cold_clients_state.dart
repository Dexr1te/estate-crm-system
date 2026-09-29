import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

abstract class ColdClientsState {
  final int days;
  const ColdClientsState(this.days);
}

class ColdClientsInitial extends ColdClientsState {
  const ColdClientsInitial(super.days);
}

class ColdClientsLoading extends ColdClientsState {
  const ColdClientsLoading(super.days);
}

class ColdClientsLoaded extends ColdClientsState {
  final List<ColdClient> clients;
  const ColdClientsLoaded(this.clients, super.days);
}

class ColdClientsError extends ColdClientsState {
  final ApiFailure failure;
  const ColdClientsError(this.failure, super.days);
}

/// A reminder task was created and the client left the list. The screen words
/// it and offers to undo, which deletes [taskId].
class ColdClientsReminderSet extends ColdClientsLoaded {
  final int taskId;
  final DateTime dueAt;
  const ColdClientsReminderSet(
      this.taskId, this.dueAt, super.clients, super.days);
}

class ColdClientsActionFailure extends ColdClientsLoaded with ActionFailed {
  @override
  final ApiFailure failure;
  const ColdClientsActionFailure(this.failure, super.clients, super.days);
}
