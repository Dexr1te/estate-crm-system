import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';

abstract class AdminUsersState {}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AgentResponse> users;
  AdminUsersLoaded(this.users);
}

class AdminUsersError extends AdminUsersState {
  final String message;
  AdminUsersError(this.message);
}

class AdminUsersActionSuccess extends AdminUsersLoaded
    implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => false;

  AdminUsersActionSuccess(this.message, super.users);
}

class AdminUsersActionFailure extends AdminUsersLoaded
    implements ActionOutcome {
  @override
  final String message;
  @override
  bool get isFailure => true;

  AdminUsersActionFailure(this.message, super.users);
}

class AdminInviteSuccess extends AdminUsersLoaded {
  final AgentResponse user;
  AdminInviteSuccess(this.user, super.users);
}
