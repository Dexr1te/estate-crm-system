import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

/// Raw HTTP access to the `/auth` endpoints. Token refresh lives in
/// [ApiClient] since it is driven by the response interceptor.
class AuthRemoteDataSource {
  final ApiClient _client;
  AuthRemoteDataSource(this._client);

  Future<AuthResponse> login(String email, String password) async {
    final res = await _client.dio.post('/auth/login', data: {
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
    final res = await _client.dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'role': role.name,
    });
    return AuthResponse.fromJson(res.data);
  }
}
