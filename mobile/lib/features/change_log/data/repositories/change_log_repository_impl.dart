import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/change_log/data/datasources/change_log_remote_datasource.dart';
import 'package:real_estate_crm/features/change_log/domain/repositories/change_log_repository.dart';

class ChangeLogRepositoryImpl implements ChangeLogRepository {
  final ChangeLogRemoteDataSource _remote;
  ChangeLogRepositoryImpl(this._remote);

  @override
  Future<PagedResponse<RecordChange>> history(
    ChangeEntityType type,
    int id, {
    int page = 0,
    int size = 30,
  }) =>
      _remote.history(type, id, page, size);

  @override
  Future<PagedResponse<RecordChange>> feed(
    ChangeLogFilter filter, {
    int page = 0,
    int size = 30,
  }) =>
      _remote.feed(filter, page, size);
}
