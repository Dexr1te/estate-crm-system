import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the `/deals` endpoints.
class DealsRemoteDataSource {
  final ApiClient _client;
  DealsRemoteDataSource(this._client);

  Future<List<DealResponse>> getDeals({int? agentId, DealStatus? status}) async {
    final res = await _client.dio.get('/deals', queryParameters: {
      if (agentId != null) 'agentId': agentId,
      if (status != null) 'status': status.name,
    });
    return (res.data as List).map((e) => DealResponse.fromJson(e)).toList();
  }

  Future<DealResponse> getDeal(int id) async {
    final res = await _client.dio.get('/deals/$id');
    return DealResponse.fromJson(res.data);
  }

  Future<DealResponse> createDeal(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/deals', data: data);
    return DealResponse.fromJson(res.data);
  }

  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/deals/$id', data: data);
    return DealResponse.fromJson(res.data);
  }

  Future<DealResponse> updateDealStatus(int id, DealStatus status) async {
    final res = await _client.dio
        .patch('/deals/$id/status', queryParameters: {'status': status.name});
    return DealResponse.fromJson(res.data);
  }

  Future<void> deleteDeal(int id) async {
    await _client.dio.delete('/deals/$id');
  }
}
