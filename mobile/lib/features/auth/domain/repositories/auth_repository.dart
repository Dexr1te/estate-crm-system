import 'package:real_estate_crm/core/models/models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  Future<AuthResponse> acceptInvite(String token, String newPassword);

  /// Asks the backend to email a reset link.
  ///
  /// Deliberately says nothing about whether the address exists: answering that
  /// would turn the sign-in screen into a way to enumerate staff.
  Future<void> requestPasswordReset(String email);

  /// Spends a reset token and signs in with the new password.
  Future<AuthResponse> resetPassword(String token, String newPassword);

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
