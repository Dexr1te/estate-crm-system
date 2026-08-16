abstract class AuthEvent {}

class AuthCheckEvent extends AuthEvent {}

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
