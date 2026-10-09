import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class KeysRemoteDataSource {
  final ApiClient _client;
  KeysRemoteDataSource(this._client);

  Future<PropertyKeys> getForProperty(int propertyId) async {
    final res = await _client.dio.get('/properties/$propertyId/keys');
    return PropertyKeys.fromJson(jsonObject(res));
  }

  Future<PropertyKeys> handOver(int propertyId, KeyHandoverDraft draft) async {
    final res = await _client.dio
        .post('/properties/$propertyId/keys/handover', data: draft.toJson());
    return PropertyKeys.fromJson(jsonObject(res));
  }

  Future<PropertyKeys> returnKeys(int propertyId) async {
    final res = await _client.dio.post('/properties/$propertyId/keys/return');
    return PropertyKeys.fromJson(jsonObject(res));
  }

  Future<List<KeyHandover>> getKeysOut() async {
    final res = await _client.dio.get('/keys/out');
    return jsonArray(res).map(KeyHandover.fromJson).toList();
  }
}
