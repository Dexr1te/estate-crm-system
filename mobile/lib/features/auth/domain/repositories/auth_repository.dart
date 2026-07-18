import 'package:real_estate_crm/core/models/models.dart';

/// Contract for authentication and session state. Wraps both the auth
/// endpoints and the persisted session.
abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  /// Accepts an invite (token + chosen password) and persists the resulting
  /// session, logging the user in.
  Future<AuthResponse> acceptInvite(String token, String newPassword);

  Future<void> logout();

  Future<AuthResponse?> getSavedUser();

  bool get isLoggedIn;
}
