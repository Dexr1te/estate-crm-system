import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class AdminRemoteDataSource {
  final ApiClient _client;
  AdminRemoteDataSource(this._client);

  Future<List<AgentResponse>> getUsers() async {
    final res = await _client.dio.get('/admin/users');
    return jsonArray(res).map(AgentResponse.fromJson).toList();
  }

  Future<AgentResponse> inviteUser(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/admin/users', data: body);
    return AgentResponse.fromJson(jsonObject(res));
  }

  Future<AgentStatsResponse> getUserStats(int id) async {
    final res = await _client.dio.get('/admin/users/$id/stats');
    return AgentStatsResponse.fromJson(jsonObject(res));
  }

  Future<AgentResponse> deactivateUser(int id) async {
    final res = await _client.dio.patch('/admin/users/$id/deactivate');
    return AgentResponse.fromJson(jsonObject(res));
  }

  Future<AgentResponse> activateUser(int id) async {
    final res = await _client.dio.patch('/admin/users/$id/activate');
    return AgentResponse.fromJson(jsonObject(res));
  }

  Future<AgentResponse> changeRole(int id, Role role) async {
    final res = await _client.dio
        .put('/admin/users/$id/role', queryParameters: {'role': role.name});
    return AgentResponse.fromJson(jsonObject(res));
  }

  Future<AgentResponse> assignTeam(int id, int teamId) async {
    final res = await _client.dio
        .patch('/admin/users/$id/team', queryParameters: {'teamId': teamId});
    return AgentResponse.fromJson(jsonObject(res));
  }

  Future<AgentResponse> resendInvite(int id) async {
    final res = await _client.dio.post('/admin/users/$id/resend-invite');
    return AgentResponse.fromJson(jsonObject(res));
  }

  Future<void> deleteUser(int id, {int? replacementId}) async {
    await _client.dio.delete(
      '/admin/users/$id',
      queryParameters: {
        if (replacementId != null) 'replacementId': replacementId
      },
    );
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
    return jsonArray(res).map(AuditLogResponse.fromJson).toList();
  }
}
