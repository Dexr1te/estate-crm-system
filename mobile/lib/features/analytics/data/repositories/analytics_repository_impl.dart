import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:real_estate_crm/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;
  AnalyticsRepositoryImpl(this._remote);

  @override
  Future<DealFunnel> getFunnel(
          {required DateTime from, required DateTime to, int? agentId}) =>
      _remote.getFunnel(from: from, to: to, agentId: agentId);
}
