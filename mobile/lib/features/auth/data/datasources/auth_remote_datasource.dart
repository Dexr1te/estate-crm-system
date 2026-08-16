import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

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

  Future<AuthResponse> acceptInvite(String token, String newPassword) async {
    final res = await _client.dio.post('/auth/accept-invite', data: {
      'token': token,
      'newPassword': newPassword,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> updateProfile(String fullName, String email) async {
    final res = await _client.dio.put('/auth/me', data: {
      'fullName': fullName,
      'email': email,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<void> requestPasswordReset(String email) =>
      _client.dio.post('/auth/forgot-password', data: {'email': email});

  Future<AuthResponse> resetPassword(String token, String newPassword) async {
    final res = await _client.dio.post('/auth/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<void> deleteAccount({int? replacementId}) => _client.dio.delete(
        '/auth/me',
        queryParameters: {
          if (replacementId != null) 'replacementId': replacementId
        },
      );
}
