import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRemoteDataSource {
  final ApiClient _client;
  TasksRemoteDataSource(this._client);

  Future<List<TaskResponse>> getTasks(TaskQuery query) async {
    final res = await _client.dio.get('/tasks', queryParameters: {
      'status': query.done ? 'done' : 'open',
      if (query.clientId != null) 'clientId': query.clientId,
      if (query.dealId != null) 'dealId': query.dealId,
      if (query.assigneeId != null) 'assigneeId': query.assigneeId,
    });
    return jsonArray(res).map(TaskResponse.fromJson).toList();
  }

  Future<TaskResponse> createTask(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/tasks', data: data);
    return TaskResponse.fromJson(jsonObject(res));
  }

  Future<TaskResponse> updateTask(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/tasks/$id', data: data);
    return TaskResponse.fromJson(jsonObject(res));
  }

  Future<TaskResponse> completeTask(int id) async {
    final res = await _client.dio.post('/tasks/$id/complete');
    return TaskResponse.fromJson(jsonObject(res));
  }

  Future<TaskResponse> reopenTask(int id) async {
    final res = await _client.dio.post('/tasks/$id/reopen');
    return TaskResponse.fromJson(jsonObject(res));
  }

  Future<void> deleteTask(int id) async {
    await _client.dio.delete('/tasks/$id');
  }
}
