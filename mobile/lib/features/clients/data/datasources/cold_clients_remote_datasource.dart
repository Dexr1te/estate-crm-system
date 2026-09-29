import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class ColdClientsRemoteDataSource {
  final ApiClient _client;
  ColdClientsRemoteDataSource(this._client);

  Future<List<ColdClient>> getColdClients({
    required int days,
    required int limit,
  }) async {
    final res = await _client.dio
        .get('/clients/cold', queryParameters: {'days': days, 'limit': limit});
    return jsonArray(res).map(ColdClient.fromJson).toList();
  }
}
