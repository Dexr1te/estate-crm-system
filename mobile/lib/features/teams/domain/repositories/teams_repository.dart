import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

abstract class TeamsRepository {
  Future<List<TeamResponse>> getTeams();

  Future<TeamResponse> createTeam(Map<String, dynamic> body);

  Future<TeamResponse> updateTeam(int id, Map<String, dynamic> body);

  Future<TeamStatsResponse> getTeamStats(int id);

  // The manager's own team ----------------------------------------------------

  /// Opens the agency this manager will run. Refused if they already have one.
  Future<TeamResponse> createMyTeam(String name);

  Future<TeamResponse> renameMyTeam(String name);

  Future<TeamResponse> getMyTeam();

  Future<List<TeamMemberResponse>> getMembers();

  /// Adds an agent by address: a request they must accept if they already have
  /// an account, an emailed invite if they do not.
  Future<AddMemberResult> addMember({
    required String email,
    required String fullName,
    String? phone,
  });

  /// Takes an agent off the team. Their records stay in it and go to
  /// [replacementId], or to the manager when that is null.
  Future<void> removeMember(int userId, {int? replacementId});

  Future<List<TeamJoinRequestResponse>> getOutgoingRequests();

  Future<void> cancelRequest(int requestId);

  // The agent's own membership ------------------------------------------------

  Future<List<TeamJoinRequestResponse>> getMyRequests();

  /// Joins the team that asked, and answers with the account as it now stands.
  Future<AuthResponse> acceptRequest(int requestId);

  Future<void> declineRequest(int requestId);

  /// Leaves the current team, handing its records back to the manager.
  Future<AuthResponse> leaveTeam();
}
