abstract class TeamGoalsEvent {}

/// Loads the month on screen again.
class TeamGoalsLoadEvent extends TeamGoalsEvent {}

/// Moves a month back ([delta] -1) or forward (+1).
class TeamGoalsMonthEvent extends TeamGoalsEvent {
  final int delta;
  TeamGoalsMonthEvent(this.delta);
}

/// Sets the manager's target for a member, or for the agency when [agentId]
/// is null.
class TeamGoalsSaveEvent extends TeamGoalsEvent {
  final int? agentId;
  final double? commissionTarget;
  final int? dealsTarget;
  TeamGoalsSaveEvent({this.agentId, this.commissionTarget, this.dealsTarget});
}

/// Takes the manager's target off a member, or off the agency.
class TeamGoalsClearEvent extends TeamGoalsEvent {
  final int? agentId;
  TeamGoalsClearEvent({this.agentId});
}

class TeamGoalsCopyPreviousEvent extends TeamGoalsEvent {}
