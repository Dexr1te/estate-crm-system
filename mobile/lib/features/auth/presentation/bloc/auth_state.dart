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

/// Registered, but the address is not confirmed yet, so there is no session.
///
/// Also reached from the sign-in screen: an unconfirmed account that types the
/// right password lands here rather than on an error, because the next step is
/// the same screen either way.
class AuthVerificationRequired extends AuthState {
  final String email;
  AuthVerificationRequired(this.email);
}

/// Another code is on its way — or was declined because one just went out.
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

/// Still signed in, with something to say about the edit that just happened.
///
/// Both of these stay [AuthAuthenticated] on purpose: the router decides where
/// you are from that type, so reporting a rename through a state outside it
/// would bounce you to the sign-in screen for renaming yourself.
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
