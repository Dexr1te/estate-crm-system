import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the `/users/agents` lookup endpoint.
class AgentsRemoteDataSource {
  final ApiClient _client;
  AgentsRemoteDataSource(this._client);

  Future<List<AgentOption>> getAgentOptions() async {
    final res = await _client.dio.get('/users/agents');
    return (res.data as List).map((e) => AgentOption.fromJson(e)).toList();
  }
}
