import 'package:real_estate_crm/core/models/models.dart';

/// Contract for authentication and session state. Wraps both the auth
/// endpoints and the persisted session.
abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    Role role,
  });

  Future<void> logout();

  Future<AuthResponse?> getSavedUser();

  bool get isLoggedIn;
}
