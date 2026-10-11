import 'package:real_estate_crm/core/models/models.dart';

/// What signing up answers with: the account is either signed straight in,
/// when the server has email confirmation switched off, or waits for its
/// address to be confirmed.
sealed class RegisterResult {
  const RegisterResult();

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    final auth = json['auth'];
    if (json['verificationRequired'] != true && auth is Map<String, dynamic>) {
      return RegisterSignedIn(AuthResponse.fromJson(auth));
    }
    return VerificationTicket.fromJson(json);
  }
}

class RegisterSignedIn extends RegisterResult {
  final AuthResponse auth;
  const RegisterSignedIn(this.auth);
}

/// An account that holds no session until its email is confirmed, and what
/// it takes to have the link emailed.
class VerificationTicket extends RegisterResult {
  final String email;

  /// Firebase custom token for the account: signing in with it is what lets
  /// Firebase send the link.
  final String firebaseToken;

  const VerificationTicket({required this.email, required this.firebaseToken});

  factory VerificationTicket.fromJson(Map<String, dynamic> json) =>
      VerificationTicket(
        email: json['email'] as String,
        firebaseToken: json['firebaseToken'] as String,
      );
}
