import 'package:real_estate_crm/core/models/models.dart';

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

class VerificationTicket extends RegisterResult {
  final String email;

  final String firebaseToken;

  const VerificationTicket({required this.email, required this.firebaseToken});

  factory VerificationTicket.fromJson(Map<String, dynamic> json) =>
      VerificationTicket(
        email: json['email'] as String,
        firebaseToken: json['firebaseToken'] as String,
      );
}
