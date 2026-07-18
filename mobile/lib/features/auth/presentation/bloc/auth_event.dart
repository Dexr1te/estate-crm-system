import 'package:real_estate_crm/core/models/models.dart';

abstract class AuthEvent {}

class AuthCheckEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email, password;
  AuthLoginEvent(this.email, this.password);
}

class AuthRegisterEvent extends AuthEvent {
  final String fullName, email, password;
  final String? phone;
  final Role role;
  AuthRegisterEvent(
      {required this.fullName,
      required this.email,
      required this.password,
      this.phone,
      this.role = Role.AGENT});
}

class AuthLogoutEvent extends AuthEvent {}