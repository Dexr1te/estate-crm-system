import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';

class LeasesRemoteDataSource {
  final ApiClient _client;
  LeasesRemoteDataSource(this._client);

  Future<List<LeaseEnding>> getLeasesEnding(
      {required int days, DateTime? from}) async {
    final res = await _client.dio.get('/deals/leases-ending', queryParameters: {
      'days': days,
      if (from != null) 'from': leaseDateParam(from),
    });
    return jsonArray(res).map(LeaseEnding.fromJson).toList();
  }

  Future<DealResponse> renew(int dealId, LeaseRenewal renewal) async {
    final res = await _client.dio
        .post('/deals/$dealId/renew-lease', data: renewal.toJson());
    return DealResponse.fromJson(jsonObject(res));
  }
}
