import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthResponse user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthVerificationRequired extends AuthState {
  final String email;
  AuthVerificationRequired(this.email);
}

class AuthCodeResent extends AuthVerificationRequired with ActionSucceeded {
  @override
  final ActionMessage message;

  AuthCodeResent(super.email, this.message);
}

class AuthCodeResendFailed extends AuthVerificationRequired with ActionFailed {
  @override
  final ApiFailure failure;

  AuthCodeResendFailed(super.email, this.failure);
}

class AuthProfileUpdated extends AuthAuthenticated with ActionSucceeded {
  @override
  final ActionMessage message;

  AuthProfileUpdated(super.user, this.message);
}

class AuthProfileUpdateFailed extends AuthAuthenticated with ActionFailed {
  @override
  final ApiFailure failure;

  AuthProfileUpdateFailed(super.user, this.failure);
}

class AuthError extends AuthState {
  final ApiFailure failure;
  AuthError(this.failure);
}
