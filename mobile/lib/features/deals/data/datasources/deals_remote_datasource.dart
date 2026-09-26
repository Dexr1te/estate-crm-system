import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class DealsRemoteDataSource {
  final ApiClient _client;
  DealsRemoteDataSource(this._client);

  Future<List<DealResponse>> getDeals(
      {int? agentId, DealStatus? status}) async {
    final res = await _client.dio.get('/deals', queryParameters: {
      if (agentId != null) 'agentId': agentId,
      if (status != null) 'status': status.name,
    });
    return jsonArray(res).map(DealResponse.fromJson).toList();
  }

  Future<DealResponse> getDeal(int id) async {
    final res = await _client.dio.get('/deals/$id');
    return DealResponse.fromJson(jsonObject(res));
  }

  Future<DealResponse> createDeal(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/deals', data: data);
    return DealResponse.fromJson(jsonObject(res));
  }

  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/deals/$id', data: data);
    return DealResponse.fromJson(jsonObject(res));
  }

  Future<DealResponse> updateDealStatus(int id, DealStatus status,
      {DealLostReason? lostReason, String? lostNote}) async {
    final res = await _client.dio.patch('/deals/$id/status', queryParameters: {
      'status': status.name,
      if (lostReason != null) 'lostReason': lostReason.name,
      if (lostNote != null && lostNote.isNotEmpty) 'lostNote': lostNote,
    });
    return DealResponse.fromJson(jsonObject(res));
  }

  Future<void> deleteDeal(int id) async {
    await _client.dio.delete('/deals/$id');
  }
}
