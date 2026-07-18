import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:real_estate_crm/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remote;
  AdminRepositoryImpl(this._remote);

  @override
  Future<List<AgentResponse>> getUsers() => _remote.getUsers();

  @override
  Future<AgentResponse> inviteUser(Map<String, dynamic> body) =>
      _remote.inviteUser(body);

  @override
  Future<AgentStatsResponse> getUserStats(int id) => _remote.getUserStats(id);

  @override
  Future<AgentResponse> deactivateUser(int id) => _remote.deactivateUser(id);

  @override
  Future<AgentResponse> activateUser(int id) => _remote.activateUser(id);

  @override
  Future<AgentResponse> changeRole(int id, Role role) =>
      _remote.changeRole(id, role);

  @override
  Future<AgentResponse> assignTeam(int id, int teamId) =>
      _remote.assignTeam(id, teamId);

  @override
  Future<AgentResponse> resendInvite(int id) => _remote.resendInvite(id);

  @override
  Future<List<AuditLogResponse>> getAuditLog({
    int? actorId,
    String? entityType,
    String? dateFrom,
    String? dateTo,
  }) =>
      _remote.getAuditLog(
        actorId: actorId,
        entityType: entityType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
}
