import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';

abstract class TeamsRepository {
  Future<List<TeamResponse>> getTeams();

  Future<TeamResponse> createTeam(Map<String, dynamic> body);

  Future<TeamResponse> updateTeam(int id, Map<String, dynamic> body);

  Future<TeamStatsResponse> getTeamStats(int id);

  Future<TeamResponse> createMyTeam(String name);

  Future<TeamResponse> renameMyTeam(String name);

  /// Sets the currency the agency's prices are shown in (ISO 4217 code).
  /// Only the sign changes; no amount is converted.
  Future<TeamResponse> changeMyCurrency(String code);

  Future<TeamResponse> getMyTeam();

  Future<List<TeamMemberResponse>> getMembers();

  Future<AddMemberResult> addMember({
    required String email,
    required String fullName,
    String? phone,
  });

  Future<void> removeMember(int userId, {int? replacementId});

  Future<List<TeamJoinRequestResponse>> getOutgoingRequests();

  Future<void> cancelRequest(int requestId);

  Future<List<TeamJoinRequestResponse>> getMyRequests();

  Future<AuthResponse> acceptRequest(int requestId);

  Future<void> declineRequest(int requestId);

  Future<AuthResponse> leaveTeam();
}
