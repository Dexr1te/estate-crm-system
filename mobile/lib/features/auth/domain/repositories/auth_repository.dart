import 'package:real_estate_crm/core/models/models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required Role role,
    String? phone,
  });

  Future<AuthResponse> verifyEmail(String email, String code);

  Future<void> resendVerification(String email);

  Future<AuthResponse> refreshMe();

  Future<AuthResponse> acceptInvite(String token, String newPassword);

  Future<AuthResponse> updateProfile(String fullName, String email);

  Future<void> requestPasswordReset(String email);

  Future<AuthResponse> resetPassword(String token, String newPassword);

  Future<void> logout();

  Future<void> deleteAccount({int? replacementId});

  Future<AuthResponse?> getSavedUser();

  bool get isLoggedIn;
}
