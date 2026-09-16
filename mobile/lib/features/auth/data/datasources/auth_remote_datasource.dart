import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class AuthRemoteDataSource {
  final ApiClient _client;
  AuthRemoteDataSource(this._client);

  Future<AuthResponse> login(String email, String password) async {
    final res = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(jsonObject(res));
  }

  /// Opens an account. Deliberately returns no session: the address has to be
  /// confirmed with [verifyEmail] first.
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required Role role,
    String? phone,
  }) =>
      _client.dio.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role.name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

  Future<AuthResponse> verifyEmail(String email, String code) async {
    final res = await _client.dio.post('/auth/verify-email', data: {
      'email': email,
      'code': code,
    });
    return AuthResponse.fromJson(jsonObject(res));
  }

  Future<void> resendVerification(String email) =>
      _client.dio.post('/auth/resend-verification', data: {'email': email});

  Future<AuthResponse> me() async {
    final res = await _client.dio.get('/auth/me');
    return AuthResponse.fromJson(jsonObject(res));
  }

  Future<AuthResponse> acceptInvite(String token, String newPassword) async {
    final res = await _client.dio.post('/auth/accept-invite', data: {
      'token': token,
      'newPassword': newPassword,
    });
    return AuthResponse.fromJson(jsonObject(res));
  }

  Future<AuthResponse> updateProfile(String fullName, String email) async {
    final res = await _client.dio.put('/auth/me', data: {
      'fullName': fullName,
      'email': email,
    });
    return AuthResponse.fromJson(jsonObject(res));
  }

  Future<void> requestPasswordReset(String email) =>
      _client.dio.post('/auth/forgot-password', data: {'email': email});

  Future<AuthResponse> resetPassword(String token, String newPassword) async {
    final res = await _client.dio.post('/auth/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });
    return AuthResponse.fromJson(jsonObject(res));
  }

  Future<void> deleteAccount({int? replacementId}) => _client.dio.delete(
        '/auth/me',
        queryParameters: {
          if (replacementId != null) 'replacementId': replacementId
        },
      );
}
