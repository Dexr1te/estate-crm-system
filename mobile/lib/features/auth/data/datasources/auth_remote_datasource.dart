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

  /// Accepts an invite by exchanging the one-time [token] for a password. The
  /// backend returns a full auth session, so the user is logged in immediately.
  Future<AuthResponse> acceptInvite(String token, String newPassword) async {
    final res = await _client.dio.post('/auth/accept-invite', data: {
      'token': token,
      'newPassword': newPassword,
    });
    return AuthResponse.fromJson(res.data);
  }
}
