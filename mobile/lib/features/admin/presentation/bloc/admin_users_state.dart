import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

abstract class AdminUsersState {}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AgentResponse> users;
  AdminUsersLoaded(this.users);
}

class AdminUsersError extends AdminUsersState {
  final ApiFailure failure;
  AdminUsersError(this.failure);
}

class AdminUsersActionSuccess extends AdminUsersLoaded with ActionSucceeded {
  @override
  final ActionMessage message;

  AdminUsersActionSuccess(this.message, super.users);
}

class AdminUsersActionFailure extends AdminUsersLoaded with ActionFailed {
  @override
  final ApiFailure failure;

  AdminUsersActionFailure(this.failure, super.users);
}

class AdminInviteSuccess extends AdminUsersLoaded {
  final AgentResponse user;
  AdminInviteSuccess(this.user, super.users);
}
