abstract class MyTeamEvent {}

class MyTeamLoadEvent extends MyTeamEvent {}

class MyTeamRenameEvent extends MyTeamEvent {
  final String name;
  MyTeamRenameEvent(this.name);
}

/// Adds an agent by address. What happens next depends on whether that address
/// already has an account, which the answer says.
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

  /// Who inherits their clients and deals. Null hands them to the manager.
  final int? replacementId;

  /// True when the member never used their invite, so nothing changes hands.
  final bool wasInvitePending;

  MyTeamRemoveMemberEvent(this.userId,
      {this.replacementId, this.wasInvitePending = false});
}

class MyTeamCancelRequestEvent extends MyTeamEvent {
  final int requestId;
  MyTeamCancelRequestEvent(this.requestId);
}
