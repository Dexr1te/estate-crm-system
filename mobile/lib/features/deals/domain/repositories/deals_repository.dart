import 'package:real_estate_crm/core/models/models.dart';

/// Contract for deal data access.
abstract class DealsRepository {
  Future<List<DealResponse>> getDeals({int? agentId, DealStatus? status});

  Future<DealResponse> getDeal(int id);

  Future<DealResponse> createDeal(Map<String, dynamic> data);

  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data);

  Future<DealResponse> updateDealStatus(int id, DealStatus status);

  Future<void> deleteDeal(int id);
}
