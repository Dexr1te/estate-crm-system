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

class AuthLogoutEvent extends AuthEvent {}