import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';

/// Contract for the ADMIN-only `/admin/*` endpoints: user management and audit.
abstract class AdminRepository {
  Future<List<AgentResponse>> getUsers();

  /// Invite a new user. [body] is a CreateAgentRequest
  /// (fullName, email, phone?, role, dataScope, teamId?).
  Future<AgentResponse> inviteUser(Map<String, dynamic> body);

  Future<AgentStatsResponse> getUserStats(int id);

  Future<AgentResponse> deactivateUser(int id);

  Future<AgentResponse> activateUser(int id);

  Future<AgentResponse> changeRole(int id, Role role);

  Future<AgentResponse> assignTeam(int id, int teamId);

  Future<AgentResponse> resendInvite(int id);

  Future<List<AuditLogResponse>> getAuditLog({
    int? actorId,
    String? entityType,
    String? dateFrom,
    String? dateTo,
  });
}
