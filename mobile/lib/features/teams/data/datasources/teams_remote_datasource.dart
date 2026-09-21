import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class TeamsRemoteDataSource {
  final ApiClient _client;
  TeamsRemoteDataSource(this._client);

  Future<List<TeamResponse>> getTeams() async {
    final res = await _client.dio.get('/teams');
    return jsonArray(res).map(TeamResponse.fromJson).toList();
  }

  Future<TeamResponse> createTeam(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/teams', data: body);
    return TeamResponse.fromJson(jsonObject(res));
  }

  Future<TeamResponse> updateTeam(int id, Map<String, dynamic> body) async {
    final res = await _client.dio.put('/teams/$id', data: body);
    return TeamResponse.fromJson(jsonObject(res));
  }

  Future<TeamStatsResponse> getTeamStats(int id) async {
    final res = await _client.dio.get('/teams/$id/stats');
    return TeamStatsResponse.fromJson(jsonObject(res));
  }

  Future<TeamResponse> createMyTeam(String name) async {
    final res = await _client.dio.post('/team', data: {'name': name});
    return TeamResponse.fromJson(jsonObject(res));
  }

  Future<TeamResponse> renameMyTeam(String name) async {
    final res = await _client.dio.patch('/team', data: {'name': name});
    return TeamResponse.fromJson(jsonObject(res));
  }

  Future<TeamResponse> getMyTeam() async {
    final res = await _client.dio.get('/team');
    return TeamResponse.fromJson(jsonObject(res));
  }

  Future<List<TeamMemberResponse>> getMembers() async {
    final res = await _client.dio.get('/team/members');
    return jsonArray(res).map(TeamMemberResponse.fromJson).toList();
  }

  Future<AddMemberResult> addMember(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/team/members', data: body);
    return AddMemberResult.fromJson(jsonObject(res));
  }

  Future<void> removeMember(int userId, {int? replacementId}) =>
      _client.dio.delete('/team/members/$userId', queryParameters: {
        if (replacementId != null) 'replacementId': replacementId,
      });

  Future<List<TeamJoinRequestResponse>> getOutgoingRequests() async {
    final res = await _client.dio.get('/team/requests');
    return jsonArray(res).map(TeamJoinRequestResponse.fromJson).toList();
  }

  Future<void> cancelRequest(int requestId) =>
      _client.dio.delete('/team/requests/$requestId');

  Future<List<TeamJoinRequestResponse>> getMyRequests() async {
    final res = await _client.dio.get('/me/team-requests');
    return jsonArray(res).map(TeamJoinRequestResponse.fromJson).toList();
  }

  Future<AuthResponse> acceptRequest(int requestId) async {
    final res = await _client.dio.post('/me/team-requests/$requestId/accept');
    return AuthResponse.fromJson(jsonObject(res));
  }

  Future<void> declineRequest(int requestId) =>
      _client.dio.post('/me/team-requests/$requestId/decline');

  Future<AuthResponse> leaveTeam() async {
    final res = await _client.dio.delete('/me/team');
    return AuthResponse.fromJson(jsonObject(res));
  }
}
