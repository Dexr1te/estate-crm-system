import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the ADMIN-only `/admin/*` endpoints.
class AdminRemoteDataSource {
  final ApiClient _client;
  AdminRemoteDataSource(this._client);

  Future<List<AgentResponse>> getUsers() async {
    final res = await _client.dio.get('/admin/users');
    return (res.data as List).map((e) => AgentResponse.fromJson(e)).toList();
  }

  Future<AgentResponse> inviteUser(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/admin/users', data: body);
    return AgentResponse.fromJson(res.data);
  }

  Future<AgentStatsResponse> getUserStats(int id) async {
    final res = await _client.dio.get('/admin/users/$id/stats');
    return AgentStatsResponse.fromJson(res.data);
  }

  Future<AgentResponse> deactivateUser(int id) async {
    final res = await _client.dio.patch('/admin/users/$id/deactivate');
    return AgentResponse.fromJson(res.data);
  }

  Future<AgentResponse> activateUser(int id) async {
    final res = await _client.dio.patch('/admin/users/$id/activate');
    return AgentResponse.fromJson(res.data);
  }

  Future<AgentResponse> changeRole(int id, Role role) async {
    final res = await _client.dio.put('/admin/users/$id/role',
        queryParameters: {'role': role.name});
    return AgentResponse.fromJson(res.data);
  }

  Future<AgentResponse> assignTeam(int id, int teamId) async {
    final res = await _client.dio
        .patch('/admin/users/$id/team', queryParameters: {'teamId': teamId});
    return AgentResponse.fromJson(res.data);
  }

  Future<AgentResponse> resendInvite(int id) async {
    final res = await _client.dio.post('/admin/users/$id/resend-invite');
    return AgentResponse.fromJson(res.data);
  }

  Future<List<AuditLogResponse>> getAuditLog({
    int? actorId,
    String? entityType,
    String? dateFrom,
    String? dateTo,
  }) async {
    final res = await _client.dio.get('/admin/audit-log', queryParameters: {
      if (actorId != null) 'actorId': actorId,
      if (entityType != null && entityType.isNotEmpty) 'entityType': entityType,
      if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
    });
    return (res.data as List).map((e) => AuditLogResponse.fromJson(e)).toList();
  }
}
