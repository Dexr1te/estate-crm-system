import 'package:real_estate_crm/core/models/admin_models.dart';

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

class AdminUsersActionSuccess extends AdminUsersState {
  final String message;
  AdminUsersActionSuccess(this.message);
}
