import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/features/teams/data/datasources/teams_remote_datasource.dart';
import 'package:real_estate_crm/features/teams/domain/repositories/teams_repository.dart';

class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource _remote;
  TeamsRepositoryImpl(this._remote);

  @override
  Future<List<TeamResponse>> getTeams() => _remote.getTeams();

  @override
  Future<TeamResponse> createTeam(Map<String, dynamic> body) =>
      _remote.createTeam(body);

  @override
  Future<TeamResponse> updateTeam(int id, Map<String, dynamic> body) =>
      _remote.updateTeam(id, body);

  @override
  Future<TeamStatsResponse> getTeamStats(int id) => _remote.getTeamStats(id);

  @override
  Future<AgentResponse> inviteAgentToMyTeam(Map<String, dynamic> body) =>
      _remote.inviteAgentToMyTeam(body);
}
