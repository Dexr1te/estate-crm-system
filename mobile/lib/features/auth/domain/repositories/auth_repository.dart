import 'package:real_estate_crm/core/models/models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  Future<AuthResponse> acceptInvite(String token, String newPassword);

  Future<void> logout();

  /// Closes the signed-in account and ends the session.
  ///
  /// [replacementId] names the colleague who takes over the deals, meetings and
  /// documents the account is responsible for; the backend refuses without one
  /// when there is anything to hand over.
  Future<void> deleteAccount({int? replacementId});

  Future<AuthResponse?> getSavedUser();

  bool get isLoggedIn;
}
