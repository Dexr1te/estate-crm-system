import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class AdminUsersState {}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AgentResponse> users;
  AdminUsersLoaded(this.users);
}

/// The *load* failed and there is nothing to show — the screen renders a
/// full-page error. A failed write uses [AdminUsersActionFailure] instead.
class AdminUsersError extends AdminUsersState {
  final String message;
  AdminUsersError(this.message);
}

/// A write succeeded. Extends [AdminUsersLoaded] and carries the list forward
/// so the console keeps its content while the reload runs.
class AdminUsersActionSuccess extends AdminUsersLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  AdminUsersActionSuccess(this.message, super.users);
}

/// A write failed, but what is already loaded is still valid: show the message
/// and keep the list rather than replacing the console with an error page.
class AdminUsersActionFailure extends AdminUsersLoaded implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  AdminUsersActionFailure(this.message, super.users);
}

/// Emitted after a successful invite. Carries the created user so the UI can
/// surface the one-time [AgentResponse.inviteToken] for the admin to share.
class AdminInviteSuccess extends AdminUsersState {
  final AgentResponse user;
  AdminInviteSuccess(this.user);
}
