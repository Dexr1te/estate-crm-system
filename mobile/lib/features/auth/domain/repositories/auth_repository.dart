import 'package:real_estate_crm/core/models/models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  Future<AuthResponse> acceptInvite(String token, String newPassword);

  Future<void> logout();

  Future<AuthResponse?> getSavedUser();

  bool get isLoggedIn;
}
