import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class AgentsRemoteDataSource {
  final ApiClient _client;
  AgentsRemoteDataSource(this._client);

  Future<List<AgentOption>> getAgentOptions() async {
    final res = await _client.dio.get('/users/agents');
    return jsonArray(res).map(AgentOption.fromJson).toList();
  }
}
