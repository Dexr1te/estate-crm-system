import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

/// Contract for `/teams` (ADMIN + MANAGER) and the manager team-invite
/// endpoint `/team/agents` (MANAGER).
abstract class TeamsRepository {
  Future<List<TeamResponse>> getTeams();

  /// [body] is a TeamRequest (name, managerId?). ADMIN only server-side.
  Future<TeamResponse> createTeam(Map<String, dynamic> body);

  Future<TeamResponse> updateTeam(int id, Map<String, dynamic> body);

  Future<TeamStatsResponse> getTeamStats(int id);

  /// Manager invites an agent into their own team (`POST /team/agents`).
  /// [body] is a CreateAgentRequest.
  Future<AgentResponse> inviteAgentToMyTeam(Map<String, dynamic> body);
}
