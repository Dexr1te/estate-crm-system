import 'package:real_estate_crm/core/models/payout_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class PayoutsRemoteDataSource {
  final ApiClient _client;
  PayoutsRemoteDataSource(this._client);

  Future<PayoutList> getPayouts(
      {required PayoutStatus status, int? agentId}) async {
    final res = await _client.dio.get('/payouts', queryParameters: {
      'status': status.wire,
      if (agentId != null) 'agentId': agentId,
    });
    return PayoutList.fromJson(jsonObject(res));
  }
}
