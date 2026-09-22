import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class ClientsRemoteDataSource {
  final ApiClient _client;
  ClientsRemoteDataSource(this._client);

  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) async {
    final res = await _client.dio.get('/clients', queryParameters: {
      if (type != null) 'type': type.name,
      if (agentId != null) 'agentId': agentId,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return jsonArray(res).map(ClientResponse.fromJson).toList();
  }

  Future<List<ClientListItem>> getClientsWithDetails() async {
    final res = await _client.dio.get('/clients/with-details');
    return jsonArray(res).map(ClientListItem.fromJson).toList();
  }

  Future<ClientResponse> getClient(int id) async {
    final res = await _client.dio.get('/clients/$id');
    return ClientResponse.fromJson(jsonObject(res));
  }

  Future<ClientResponse> createClient(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/clients', data: data);
    return ClientResponse.fromJson(jsonObject(res));
  }

  Future<ClientResponse> updateClient(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/clients/$id', data: data);
    return ClientResponse.fromJson(jsonObject(res));
  }

  Future<void> deleteClient(int id) async {
    await _client.dio.delete('/clients/$id');
  }

  Future<List<PropertyMatch>> getMatches(int id) async {
    final res = await _client.dio.get('/clients/$id/matches');
    return jsonArray(res).map(PropertyMatch.fromJson).toList();
  }
}
