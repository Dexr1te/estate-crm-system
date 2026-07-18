import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the `/clients` endpoints.
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
    return (res.data as List).map((e) => ClientResponse.fromJson(e)).toList();
  }

  Future<List<ClientListItem>> getClientsWithDetails() async {
    final res = await _client.dio.get('/clients/with-details');
    return (res.data as List).map((e) => ClientListItem.fromJson(e)).toList();
  }

  Future<ClientResponse> getClient(int id) async {
    final res = await _client.dio.get('/clients/$id');
    return ClientResponse.fromJson(res.data);
  }

  Future<ClientResponse> createClient(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/clients', data: data);
    return ClientResponse.fromJson(res.data);
  }

  Future<ClientResponse> updateClient(int id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/clients/$id', data: data);
    return ClientResponse.fromJson(res.data);
  }

  Future<void> deleteClient(int id) async {
    await _client.dio.delete('/clients/$id');
  }
}
