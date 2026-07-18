import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:real_estate_crm/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remote;
  DashboardRepositoryImpl(this._remote);

  @override
  Future<DashboardSummary> getDashboardSummary() =>
      _remote.getDashboardSummary();
}
