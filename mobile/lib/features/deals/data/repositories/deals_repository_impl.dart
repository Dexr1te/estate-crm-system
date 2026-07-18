import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/deals/data/datasources/deals_remote_datasource.dart';
import 'package:real_estate_crm/features/deals/domain/repositories/deals_repository.dart';

class DealsRepositoryImpl implements DealsRepository {
  final DealsRemoteDataSource _remote;
  DealsRepositoryImpl(this._remote);

  @override
  Future<List<DealResponse>> getDeals({int? agentId, DealStatus? status}) =>
      _remote.getDeals(agentId: agentId, status: status);

  @override
  Future<DealResponse> getDeal(int id) => _remote.getDeal(id);

  @override
  Future<DealResponse> createDeal(Map<String, dynamic> data) =>
      _remote.createDeal(data);

  @override
  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) =>
      _remote.updateDeal(id, data);

  @override
  Future<DealResponse> updateDealStatus(int id, DealStatus status) =>
      _remote.updateDealStatus(id, status);

  @override
  Future<void> deleteDeal(int id) => _remote.deleteDeal(id);
}
