import 'package:real_estate_crm/core/models/models.dart';

class TaskQuery {
  final bool done;
  final int? clientId;
  final int? dealId;
  final int? assigneeId;

  const TaskQuery({
    this.done = false,
    this.clientId,
    this.dealId,
    this.assigneeId,
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
