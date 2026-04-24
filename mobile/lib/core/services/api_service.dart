import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseUrl = 'http://192.168.0.223:8080/api';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          try {
            final newAuth = await _doRefresh(_refreshToken!);
            await saveAuth(newAuth);
            // Retry original request
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $_accessToken';
            final response = await _dio.fetch(opts);
            handler.resolve(response);
            return;
          } catch (_) {
            await clearAuth();
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> saveAuth(AuthResponse auth) async {
    _accessToken = auth.accessToken;
    _refreshToken = auth.refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', auth.accessToken);
    await prefs.setString('refresh_token', auth.refreshToken);
    await prefs.setString('auth_user', _encodeAuthUser(auth));
  }

  Future<void> clearAuth() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('auth_user');
  }

  Future<AuthResponse?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('auth_user');
    if (data == null) return null;
    try {
      return AuthResponse.fromJson(_decodeAuthUser(data));
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn => _accessToken != null;

  String _encodeAuthUser(AuthResponse auth) {
    return '${auth.userId}|${auth.fullName}|${auth.email}|${auth.role.name}';
  }

  Map<String, dynamic> _decodeAuthUser(String data) {
    final parts = data.split('|');
    return {
      'accessToken': _accessToken ?? '',
      'refreshToken': _refreshToken ?? '',
      'tokenType': 'Bearer',
      'userId': int.tryParse(parts[0]) ?? 0,
      'fullName': parts.length > 1 ? parts[1] : '',
      'email': parts.length > 2 ? parts[2] : '',
      'role': parts.length > 3 ? parts[3] : 'AGENT',
    };
  }

  // ──────────────────────────────────────────
  // Auth
  // ──────────────────────────────────────────

  Future<AuthResponse> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    Role role = Role.AGENT,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
      'role': role.name,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> _doRefresh(String token) async {
    final res = await _dio.post('/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return AuthResponse.fromJson(res.data);
  }

  // ──────────────────────────────────────────
  // Dashboard
  // ──────────────────────────────────────────

  Future<DashboardSummary> getDashboardSummary() async {
    final res = await _dio.get('/dashboard/summary');
    return DashboardSummary.fromJson(res.data);
  }

  // ──────────────────────────────────────────
  // Clients
  // ──────────────────────────────────────────

  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) async {
    final res = await _dio.get('/clients', queryParameters: {
      if (type != null) 'type': type.name,
      if (agentId != null) 'agentId': agentId,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (res.data as List).map((e) => ClientResponse.fromJson(e)).toList();
  }

  Future<List<ClientListItem>> getClientsWithDetails() async {
    final res = await _dio.get('/clients/with-details');
    return (res.data as List).map((e) => ClientListItem.fromJson(e)).toList();
  }

  Future<ClientResponse> getClient(int id) async {
    final res = await _dio.get('/clients/$id');
    return ClientResponse.fromJson(res.data);
  }

  Future<ClientResponse> createClient(Map<String, dynamic> data) async {
    final res = await _dio.post('/clients', data: data);
    return ClientResponse.fromJson(res.data);
  }

  Future<ClientResponse> updateClient(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/clients/$id', data: data);
    return ClientResponse.fromJson(res.data);
  }

  Future<void> deleteClient(int id) async {
    await _dio.delete('/clients/$id');
  }

  // ──────────────────────────────────────────
  // Properties
  // ──────────────────────────────────────────

  Future<List<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    final res = await _dio.get('/properties', queryParameters: {
      if (status != null) 'status': status.name,
      if (type != null) 'type': type.name,
      if (city != null && city.isNotEmpty) 'city': city,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (res.data as List).map((e) => PropertyResponse.fromJson(e)).toList();
  }

  Future<PropertyResponse> getProperty(int id) async {
    final res = await _dio.get('/properties/$id');
    return PropertyResponse.fromJson(res.data);
  }

  Future<PropertyResponse> createProperty(Map<String, dynamic> data) async {
    final res = await _dio.post('/properties', data: data);
    return PropertyResponse.fromJson(res.data);
  }

  Future<PropertyResponse> updateProperty(
      int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/properties/$id', data: data);
    return PropertyResponse.fromJson(res.data);
  }

  Future<PropertyResponse> updatePropertyStatus(
      int id, PropertyStatus status) async {
    final res = await _dio.patch('/properties/$id/status',
        queryParameters: {'status': status.name});
    return PropertyResponse.fromJson(res.data);
  }

  Future<void> deleteProperty(int id) async {
    await _dio.delete('/properties/$id');
  }

  // ──────────────────────────────────────────
  // Deals
  // ──────────────────────────────────────────

  Future<List<DealResponse>> getDeals({
    int? agentId,
    DealStatus? status,
  }) async {
    final res = await _dio.get('/deals', queryParameters: {
      if (agentId != null) 'agentId': agentId,
      if (status != null) 'status': status.name,
    });
    return (res.data as List).map((e) => DealResponse.fromJson(e)).toList();
  }

  Future<DealResponse> getDeal(int id) async {
    final res = await _dio.get('/deals/$id');
    return DealResponse.fromJson(res.data);
  }

  Future<DealResponse> createDeal(Map<String, dynamic> data) async {
    final res = await _dio.post('/deals', data: data);
    return DealResponse.fromJson(res.data);
  }

  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/deals/$id', data: data);
    return DealResponse.fromJson(res.data);
  }

  Future<DealResponse> updateDealStatus(int id, DealStatus status) async {
    final res = await _dio
        .patch('/deals/$id/status', queryParameters: {'status': status.name});
    return DealResponse.fromJson(res.data);
  }

  Future<void> deleteDeal(int id) async {
    await _dio.delete('/deals/$id');
  }

  // ──────────────────────────────────────────
  // Meetings
  // ──────────────────────────────────────────

  Future<List<MeetingResponse>> getMeetings({int? agentId}) async {
    final res = await _dio.get('/meetings', queryParameters: {
      if (agentId != null) 'agentId': agentId,
    });
    return (res.data as List).map((e) => MeetingResponse.fromJson(e)).toList();
  }

  Future<List<UpcomingMeetingResponse>> getUpcomingMeetings() async {
    final res = await _dio.get('/meetings/upcoming');
    return (res.data as List)
        .map((e) => UpcomingMeetingResponse.fromJson(e))
        .toList();
  }

  Future<List<MeetingResponse>> getUpcomingMeetingsByAgent(int agentId) async {
    final res = await _dio.get('/meetings/upcoming/agent/$agentId');
    return (res.data as List).map((e) => MeetingResponse.fromJson(e)).toList();
  }

  Future<MeetingResponse> getMeeting(int id) async {
    final res = await _dio.get('/meetings/$id');
    return MeetingResponse.fromJson(res.data);
  }

  Future<MeetingResponse> createMeeting(Map<String, dynamic> data) async {
    final res = await _dio.post('/meetings', data: data);
    return MeetingResponse.fromJson(res.data);
  }

  Future<MeetingResponse> updateMeeting(
      int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/meetings/$id', data: data);
    return MeetingResponse.fromJson(res.data);
  }

  Future<MeetingResponse> completeMeeting(int id) async {
    final res = await _dio.patch('/meetings/$id/complete');
    return MeetingResponse.fromJson(res.data);
  }

  Future<void> deleteMeeting(int id) async {
    await _dio.delete('/meetings/$id');
  }
}
