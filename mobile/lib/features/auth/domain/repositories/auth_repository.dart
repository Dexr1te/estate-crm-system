import 'package:real_estate_crm/core/models/auth_models.dart';
import 'package:real_estate_crm/core/models/models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);

  /// Creates the account. It is signed in at once only when the server does
  /// not ask for the email to be confirmed; otherwise it comes back as a
  /// [VerificationTicket] and holds no session yet.
  Future<RegisterResult> register({
    required String fullName,
    required String email,
    required String password,
    required Role role,
    String? phone,
  });

  /// A new ticket for an account still waiting on its email, proven by the
  /// password it was created with.
  Future<VerificationTicket> startVerification(String email, String password);

  /// Trades proof that the link was opened for a session.
  Future<AuthResponse> verifyEmail(String idToken);

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
