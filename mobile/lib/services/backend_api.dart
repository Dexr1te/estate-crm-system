import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Backend API integration for the Estate CRM
// - Centralized HTTP client
// - Token storage and refresh handling
// - Methods for the key backend endpoints described in the architecture
// NOTE: Add proper error handling, models, and dependency injection as needed in your app.

class BackendApi {
  BackendApi({required this.baseUrl}) : _storage = const FlutterSecureStorage();

  final String baseUrl;
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // Basic HTTP helpers ---------------------------------------------------
  Future<Map<String, String>> _defaultHeaders({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> _send(String method, String path,
      {Map<String, dynamic>? body, Map<String, String>? extraHeaders, bool retry = true, bool withAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _defaultHeaders(withAuth: withAuth);
    if (extraHeaders != null) headers.addAll(extraHeaders);

    http.Response response;
    if (method == 'GET') {
      response = await http.get(url, headers: headers);
    } else if (method == 'POST') {
      response = await http.post(url, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'PUT') {
      response = await http.put(url, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'PATCH') {
      response = await http.patch(url, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'DELETE') {
      response = await http.delete(url, headers: headers);
    } else {
      throw UnsupportedError('Unsupported HTTP method: $method');
    }

    // If unauthorized, try refresh and retry once
    if (response.statusCode == 401 && retry && withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _send(method, path, body: body, extraHeaders: extraHeaders, retry: false, withAuth: withAuth);
      }
    }

    return response;
  }

  // Token management ----------------------------------------------------
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> _tryRefreshToken() async {
    final refresh = await _storage.read(key: _refreshTokenKey);
    if (refresh == null) return false;

    final resp = await http.post(Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'refreshToken': refresh}));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final access = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (access != null) {
        await saveTokens(accessToken: access, refreshToken: newRefresh);
        return true;
      }
    }
    // Refresh failed — clear tokens
    await clearTokens();
    return false;
  }

  // Auth / Invite flows -------------------------------------------------

  /// Accept invite: POST /auth/accept-invite { token, newPassword }
  Future<http.Response> acceptInvite(String token, String newPassword) async {
    return _send('POST', '/auth/accept-invite', body: {'token': token, 'newPassword': newPassword}, withAuth: false);
  }

  /// Login: POST /auth/login { email, password } -> { accessToken, refreshToken }
  Future<bool> login(String email, String password) async {
    final resp = await _send('POST', '/auth/login', body: {'email': email, 'password': password}, retry: false, withAuth: false);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      await saveTokens(accessToken: data['accessToken'], refreshToken: data['refreshToken']);
      return true;
    }
    return false;
  }

  /// Logout on server (if implemented) and clear client tokens
  Future<void> logout() async {
    try {
      await _send('POST', '/auth/logout', withAuth: true);
    } catch (_) {}
    await clearTokens();
  }

  /// Forgot password: POST /auth/forgot-password { email }
  Future<http.Response> forgotPassword(String email) async {
    return _send('POST', '/auth/forgot-password', body: {'email': email}, withAuth: false);
  }

  /// Reset password: POST /auth/reset-password { token, newPassword }
  Future<http.Response> resetPassword(String token, String newPassword) async {
    return _send('POST', '/auth/reset-password', body: {'token': token, 'newPassword': newPassword}, withAuth: false);
  }

  /// Get current user: GET /auth/me
  Future<http.Response> me() async {
    return _send('GET', '/auth/me');
  }

  /// Update current user: PUT /auth/me
  Future<http.Response> updateMe(Map<String, dynamic> payload) async {
    return _send('PUT', '/auth/me', body: payload);
  }

  // Users / Teams (Admin / Manager) ------------------------------------

  /// Admin: list users
  Future<http.Response> adminListUsers({int? page, int? size}) async {
    var path = '/admin/users';
    final params = <String, String>{};
    if (page != null) params['page'] = '$page';
    if (size != null) params['size'] = '$size';
    if (params.isNotEmpty) path += '?' + Uri(queryParameters: params).query;
    return _send('GET', path);
  }

  /// Admin create user (invite): POST /admin/users { email, fullName, role, dataScope?, teamId? }
  Future<http.Response> adminCreateUser(Map<String, dynamic> body) async {
    return _send('POST', '/admin/users', body: body);
  }

  /// Manager: create agent in own team: POST /team/agents
  Future<http.Response> managerCreateAgent(Map<String, dynamic> body) async {
    return _send('POST', '/team/agents', body: body);
  }

  /// Resend invite: POST /admin/users/{id}/resend-invite
  Future<http.Response> adminResendInvite(int userId) async {
    return _send('POST', '/admin/users/$userId/resend-invite');
  }

  /// Teams endpoints
  Future<http.Response> listTeams() async => _send('GET', '/teams');
  Future<http.Response> createTeam(Map<String, dynamic> body) async => _send('POST', '/teams', body: body);
  Future<http.Response> updateTeam(int id, Map<String, dynamic> body) async => _send('PUT', '/teams/$id', body: body);
  Future<http.Response> getTeamStats(int id) async => _send('GET', '/teams/$id/stats');

  // Audit (admin only)
  Future<http.Response> adminAuditLog({Map<String, String>? query}) async {
    var path = '/admin/audit-log';
    if (query != null && query.isNotEmpty) path += '?' + Uri(queryParameters: query).query;
    return _send('GET', path);
  }

  // Clients / Deals / Meetings / Properties -----------------------------

  // Clients
  Future<http.Response> listClients({int? page, int? size}) async {
    var path = '/clients';
    final params = <String, String>{};
    if (page != null) params['page'] = '$page';
    if (size != null) params['size'] = '$size';
    if (params.isNotEmpty) path += '?' + Uri(queryParameters: params).query;
    return _send('GET', path);
  }

  Future<http.Response> getClient(int id) async => _send('GET', '/clients/$id');
  Future<http.Response> createClient(Map<String, dynamic> body) async => _send('POST', '/clients', body: body);
  Future<http.Response> updateClient(int id, Map<String, dynamic> body) async => _send('PUT', '/clients/$id', body: body);
  Future<http.Response> deleteClient(int id) async => _send('DELETE', '/clients/$id');
  Future<http.Response> getClientDeals(int clientId) async => _send('GET', '/clients/$clientId/deals');

  // Deals
  Future<http.Response> listDeals({int? page, int? size, int? clientId}) async {
    var path = '/deals';
    final params = <String, String>{};
    if (page != null) params['page'] = '$page';
    if (size != null) params['size'] = '$size';
    if (clientId != null) params['clientId'] = '$clientId';
    if (params.isNotEmpty) path += '?' + Uri(queryParameters: params).query;
    return _send('GET', path);
  }

  Future<http.Response> getDeal(int id) async => _send('GET', '/deals/$id');
  Future<http.Response> createDeal(Map<String, dynamic> body) async => _send('POST', '/deals', body: body);
  Future<http.Response> updateDeal(int id, Map<String, dynamic> body) async => _send('PUT', '/deals/$id', body: body);
  Future<http.Response> deleteDeal(int id) async => _send('DELETE', '/deals/$id');
  Future<http.Response> updateDealStatus(int id, String status) async => _send('PATCH', '/deals/$id/status', body: {'status': status});

  // Meetings
  Future<http.Response> listMeetings({int? page, int? size}) async {
    var path = '/meetings';
    final params = <String, String>{};
    if (page != null) params['page'] = '$page';
    if (size != null) params['size'] = '$size';
    if (params.isNotEmpty) path += '?' + Uri(queryParameters: params).query;
    return _send('GET', path);
  }

  Future<http.Response> getMeeting(int id) async => _send('GET', '/meetings/$id');
  Future<http.Response> createMeeting(Map<String, dynamic> body) async => _send('POST', '/meetings', body: body);
  Future<http.Response> updateMeeting(int id, Map<String, dynamic> body) async => _send('PUT', '/meetings/$id', body: body);
  Future<http.Response> markMeetingCompleted(int id) async => _send('PATCH', '/meetings/$id/complete');
  Future<http.Response> deleteMeeting(int id) async => _send('DELETE', '/meetings/$id');
  Future<http.Response> upcomingMeetings({int? agentId}) async {
    var path = '/meetings/upcoming';
    final params = <String, String>{};
    if (agentId != null) params['agentId'] = '$agentId';
    if (params.isNotEmpty) path += '?' + Uri(queryParameters: params).query;
    return _send('GET', path);
  }

  // Properties
  Future<http.Response> listProperties({int? page, int? size, Map<String, String>? filters}) async {
    var path = '/properties';
    final params = <String, String>{};
    if (page != null) params['page'] = '$page';
    if (size != null) params['size'] = '$size';
    if (filters != null) params.addAll(filters);
    if (params.isNotEmpty) path += '?' + Uri(queryParameters: params).query;
    return _send('GET', path);
  }

  Future<http.Response> getProperty(int id) async => _send('GET', '/properties/$id');
  Future<http.Response> createProperty(Map<String, dynamic> body) async => _send('POST', '/properties', body: body);
  Future<http.Response> updateProperty(int id, Map<String, dynamic> body) async => _send('PUT', '/properties/$id', body: body);
  Future<http.Response> updatePropertyStatus(int id, String status) async => _send('PATCH', '/properties/$id/status', body: {'status': status});
  Future<http.Response> deleteProperty(int id) async => _send('DELETE', '/properties/$id');

  // Dashboard
  Future<http.Response> dashboardSummary({int? agentId, int? teamId}) async {
    var path = '/dashboard/summary';
    final params = <String, String>{};
    if (agentId != null) params['agentId'] = '$agentId';
    if (teamId != null) params['teamId'] = '$teamId';
    if (params.isNotEmpty) path += '?' + Uri(queryParameters: params).query;
    return _send('GET', path);
  }

  // Helpers for response parsing can be added as needed.
}
