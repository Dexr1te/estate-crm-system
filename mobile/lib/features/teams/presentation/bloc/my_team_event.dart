abstract class MyTeamEvent {}

class MyTeamLoadEvent extends MyTeamEvent {}

class MyTeamRenameEvent extends MyTeamEvent {
  final String name;
  MyTeamRenameEvent(this.name);
}

class MyTeamAddMemberEvent extends MyTeamEvent {
  final String email, fullName;
  final String? phone;
  MyTeamAddMemberEvent({
    required this.email,
    required this.fullName,
    this.phone,
  });
}

class MyTeamRemoveMemberEvent extends MyTeamEvent {
  final int userId;

  final int? replacementId;

  final bool wasInvitePending;

  MyTeamRemoveMemberEvent(this.userId,
      {this.replacementId, this.wasInvitePending = false});
}

class MyTeamCancelRequestEvent extends MyTeamEvent {
  final int requestId;
  MyTeamCancelRequestEvent(this.requestId);
}
