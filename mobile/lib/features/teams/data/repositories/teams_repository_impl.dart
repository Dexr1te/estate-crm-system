import 'package:real_estate_crm/core/models/models.dart';
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
  Future<TeamResponse> createMyTeam(String name) => _remote.createMyTeam(name);

  @override
  Future<TeamResponse> renameMyTeam(String name) => _remote.renameMyTeam(name);

  @override
  Future<TeamResponse> getMyTeam() => _remote.getMyTeam();

  @override
  Future<List<TeamMemberResponse>> getMembers() => _remote.getMembers();

  @override
  Future<AddMemberResult> addMember({
    required String email,
    required String fullName,
    String? phone,
  }) =>
      _remote.addMember({
        'email': email,
        'fullName': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

  @override
  Future<void> removeMember(int userId, {int? replacementId}) =>
      _remote.removeMember(userId, replacementId: replacementId);

  @override
  Future<List<TeamJoinRequestResponse>> getOutgoingRequests() =>
      _remote.getOutgoingRequests();

  @override
  Future<void> cancelRequest(int requestId) => _remote.cancelRequest(requestId);

  @override
  Future<List<TeamJoinRequestResponse>> getMyRequests() =>
      _remote.getMyRequests();

  @override
  Future<AuthResponse> acceptRequest(int requestId) =>
      _remote.acceptRequest(requestId);

  @override
  Future<void> declineRequest(int requestId) =>
      _remote.declineRequest(requestId);

  @override
  Future<AuthResponse> leaveTeam() => _remote.leaveTeam();
}
