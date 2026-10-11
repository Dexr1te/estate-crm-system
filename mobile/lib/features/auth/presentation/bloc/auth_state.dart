import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/auth/domain/email_verifier.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthResponse user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

/// The account waits for the link emailed to [email] to be opened. The states
/// below keep the screen where it is and only add what just happened.
class AuthVerificationRequired extends AuthState {
  final String email;
  AuthVerificationRequired(this.email);
}

/// Asking whether the link has been opened.
class AuthVerificationChecking extends AuthVerificationRequired {
  AuthVerificationChecking(super.email);
}

/// Asked, and the link has not been opened yet.
class AuthEmailNotConfirmed extends AuthVerificationRequired
    with ActionOutcome {
  AuthEmailNotConfirmed(super.email);

  @override
  String text(AppLocalizations l10n) => l10n.authVerifyEmailNotYet;

  @override
  bool get isFailure => false;
}

class AuthLinkResent extends AuthVerificationRequired with ActionOutcome {
  AuthLinkResent(super.email);

  @override
  String text(AppLocalizations l10n) => l10n.authLinkResent;

  @override
  bool get isFailure => false;
}

/// The link could not be sent, or whether it was opened could not be told.
class AuthLinkFailed extends AuthVerificationRequired with ActionOutcome {
  final EmailVerificationProblem problem;
  AuthLinkFailed(super.email, this.problem);

  @override
  String text(AppLocalizations l10n) {
    switch (problem) {
      case EmailVerificationProblem.tooManyRequests:
        return l10n.authVerifyTooManyRequests;
      case EmailVerificationProblem.offline:
        return l10n.coreErrorOffline;
      case EmailVerificationProblem.signedOut:
        return l10n.authVerifySignedOut;
      case EmailVerificationProblem.unknown:
        return l10n.authVerifyUnavailable;
    }
  }

  @override
  bool get isFailure => true;
}

/// The link was opened, but the server would not start the session.
class AuthVerificationFailed extends AuthVerificationRequired with ActionFailed {
  @override
  final ApiFailure failure;

  AuthVerificationFailed(super.email, this.failure);
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
