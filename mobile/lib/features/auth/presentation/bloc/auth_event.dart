import 'package:real_estate_crm/core/models/models.dart';

abstract class AuthEvent {}

class AuthCheckEvent extends AuthEvent {}

class AuthRegisterEvent extends AuthEvent {
  final String fullName, email, password;
  final Role role;
  final String? phone;
  AuthRegisterEvent({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
  });
}

class AuthVerifyEmailEvent extends AuthEvent {
  final String email, code;
  AuthVerifyEmailEvent(this.email, this.code);
}

class AuthResendCodeEvent extends AuthEvent {
  final String email;
  AuthResendCodeEvent(this.email);
}

/// Re-reads the account behind the session — after joining a team, leaving one,
/// or coming back to a waiting screen that may no longer be waiting.
class AuthRefreshMeEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email, password;
  AuthLoginEvent(this.email, this.password);
}

class AuthAcceptInviteEvent extends AuthEvent {
  final String token, newPassword;
  AuthAcceptInviteEvent(this.token, this.newPassword);
}

class AuthResetPasswordEvent extends AuthEvent {
  final String token, newPassword;
  AuthResetPasswordEvent(this.token, this.newPassword);
}

class AuthUpdateProfileEvent extends AuthEvent {
  final String fullName, email;
  AuthUpdateProfileEvent(this.fullName, this.email);
}

class AuthLogoutEvent extends AuthEvent {}
