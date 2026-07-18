import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to `/teams` and the manager `/team/agents` endpoint.
class TeamsRemoteDataSource {
  final ApiClient _client;
  TeamsRemoteDataSource(this._client);

  Future<List<TeamResponse>> getTeams() async {
    final res = await _client.dio.get('/teams');
    return (res.data as List).map((e) => TeamResponse.fromJson(e)).toList();
  }

  Future<TeamResponse> createTeam(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/teams', data: body);
    return TeamResponse.fromJson(res.data);
  }

  Future<TeamResponse> updateTeam(int id, Map<String, dynamic> body) async {
    final res = await _client.dio.put('/teams/$id', data: body);
    return TeamResponse.fromJson(res.data);
  }

  Future<TeamStatsResponse> getTeamStats(int id) async {
    final res = await _client.dio.get('/teams/$id/stats');
    return TeamStatsResponse.fromJson(res.data);
  }

  Future<AgentResponse> inviteAgentToMyTeam(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/team/agents', data: body);
    return AgentResponse.fromJson(res.data);
  }
}
