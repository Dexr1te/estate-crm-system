import 'package:real_estate_crm/core/models/models.dart';

class TaskQuery {
  final bool done;
  final int? clientId;
  final int? dealId;
  final int? assigneeId;

  /// Open and done together, soonest due first; [done] is then ignored. The
  /// calendar shows finished tasks too, muted.
  final bool includeDone;

  /// Only tasks due in `[from, to)`; either bound may be left open.
  final DateTime? from;
  final DateTime? to;

  const TaskQuery({
    this.done = false,
    this.clientId,
    this.dealId,
    this.assigneeId,
    this.includeDone = false,
    this.from,
    this.to,
  });
}

abstract class TasksRepository {
  Stream<void> get changes;

  Future<List<TaskResponse>> getTasks([TaskQuery query = const TaskQuery()]);

  Future<TaskResponse> createTask(Map<String, dynamic> data);

  Future<TaskResponse> updateTask(int id, Map<String, dynamic> data);

  Future<TaskResponse> completeTask(int id);

  Future<TaskResponse> reopenTask(int id);

  Future<void> deleteTask(int id);
}
