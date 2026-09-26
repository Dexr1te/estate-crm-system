import 'dart:async';

import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:real_estate_crm/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource _remote;
  final _changes = StreamController<void>.broadcast();

  TasksRepositoryImpl(this._remote);

  @override
  Stream<void> get changes => _changes.stream;

  Future<T> _write<T>(Future<T> write) async {
    final result = await write;
    _changes.add(null);
    return result;
  }

  @override
  Future<List<TaskResponse>> getTasks([TaskQuery query = const TaskQuery()]) =>
      _remote.getTasks(query);

  @override
  Future<TaskResponse> createTask(Map<String, dynamic> data) =>
      _write(_remote.createTask(data));

  @override
  Future<TaskResponse> updateTask(int id, Map<String, dynamic> data) =>
      _write(_remote.updateTask(id, data));

  @override
  Future<TaskResponse> completeTask(int id) => _write(_remote.completeTask(id));

  @override
  Future<TaskResponse> reopenTask(int id) => _write(_remote.reopenTask(id));

  @override
  Future<void> deleteTask(int id) => _write(_remote.deleteTask(id));
}
