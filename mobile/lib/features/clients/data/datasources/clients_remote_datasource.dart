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

  Future<List<ClientActivity>> getActivities(int clientId) async {
    final res = await _client.dio.get('/clients/$clientId/activities');
    return jsonArray(res).map(ClientActivity.fromJson).toList();
  }

  Future<ClientActivity> logActivity(
    int clientId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
    List<int> propertyIds = const [],
  }) async {
    final res = await _client.dio.post('/clients/$clientId/activities', data: {
      'type': type.name,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (occurredAt != null) 'occurredAt': occurredAt.toIso8601String(),
      if (propertyIds.isNotEmpty) 'propertyIds': propertyIds,
    });
    return ClientActivity.fromJson(jsonObject(res));
  }

  Future<ClientActivity> updateActivity(
    int clientId,
    int activityId, {
    required ActivityType type,
    String? note,
    DateTime? occurredAt,
  }) async {
    final res = await _client.dio
        .put('/clients/$clientId/activities/$activityId', data: {
      'type': type.name,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (occurredAt != null) 'occurredAt': occurredAt.toIso8601String(),
    });
    return ClientActivity.fromJson(jsonObject(res));
  }

  Future<void> deleteActivity(int clientId, int activityId) async {
    await _client.dio.delete('/clients/$clientId/activities/$activityId');
  }

  Future<List<ClientDuplicate>> findDuplicates({
    String? phone,
    String? email,
    int? excludeId,
  }) async {
    final res = await _client.dio.get('/clients/duplicates', queryParameters: {
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (excludeId != null) 'excludeId': excludeId,
    });
    return jsonArray(res).map(ClientDuplicate.fromJson).toList();
  }

  Future<ClientResponse> mergeClients(int targetId, int sourceId) async {
    final res = await _client.dio
        .post('/clients/$targetId/merge', data: {'sourceId': sourceId});
    return ClientResponse.fromJson(jsonObject(res));
  }
}
