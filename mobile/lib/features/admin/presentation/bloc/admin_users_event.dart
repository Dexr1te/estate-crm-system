import 'package:real_estate_crm/core/models/models.dart';

abstract class AdminUsersEvent {}

class AdminUsersLoadEvent extends AdminUsersEvent {}

class AdminInviteUserEvent extends AdminUsersEvent {
  final Map<String, dynamic> body;
  AdminInviteUserEvent(this.body);
}

class AdminActivateUserEvent extends AdminUsersEvent {
  final int id;
  AdminActivateUserEvent(this.id);
}

class AdminDeactivateUserEvent extends AdminUsersEvent {
  final int id;
  AdminDeactivateUserEvent(this.id);
}

class AdminChangeRoleEvent extends AdminUsersEvent {
  final int id;
  final Role role;
  AdminChangeRoleEvent(this.id, this.role);
}

class AdminAssignTeamEvent extends AdminUsersEvent {
  final int id;
  final int teamId;
  AdminAssignTeamEvent(this.id, this.teamId);
}

class AdminResendInviteEvent extends AdminUsersEvent {
  final int id;
  AdminResendInviteEvent(this.id);
}
