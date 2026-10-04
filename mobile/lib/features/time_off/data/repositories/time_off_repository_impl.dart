import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/time_off/data/datasources/time_off_remote_datasource.dart';
import 'package:real_estate_crm/features/time_off/domain/repositories/time_off_repository.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';

class TimeOffRepositoryImpl implements TimeOffRepository {
  final TimeOffRemoteDataSource _remote;
  TimeOffRepositoryImpl(this._remote);

  @override
  Future<List<TimeOff>> getTimeOff(
          {required DateTime from, required DateTime to, int? userId}) =>
      _remote.getTimeOff(from: from, to: to, userId: userId);

  @override
  Future<TimeOff> getOne(int id) => _remote.getOne(id);

  @override
  Future<TimeOff> create(TimeOffDraft draft) => _remote.create(draft);

  @override
  Future<TimeOff> update(int id, TimeOffDraft draft) =>
      _remote.update(id, draft);

  @override
  Future<void> cancel(int id) => _remote.cancel(id);
}
