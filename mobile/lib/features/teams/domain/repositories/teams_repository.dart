import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

abstract class TeamsRepository {
  Future<List<TeamResponse>> getTeams();

  Future<TeamResponse> createTeam(Map<String, dynamic> body);

  Future<TeamResponse> updateTeam(int id, Map<String, dynamic> body);

  Future<TeamStatsResponse> getTeamStats(int id);

  Future<AgentResponse> inviteAgentToMyTeam(Map<String, dynamic> body);
}
