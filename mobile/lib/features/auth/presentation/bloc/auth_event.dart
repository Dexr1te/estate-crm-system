abstract class AuthEvent {}

class AuthCheckEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email, password;
  AuthLoginEvent(this.email, this.password);
}

class AuthLogoutEvent extends AuthEvent {}