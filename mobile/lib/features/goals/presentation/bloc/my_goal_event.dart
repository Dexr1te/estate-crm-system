abstract class MyGoalEvent {}

class MyGoalLoadEvent extends MyGoalEvent {}

/// Sets the person's own target for this month.
class MyGoalSaveEvent extends MyGoalEvent {
  final double? commissionTarget;
  final int? dealsTarget;
  MyGoalSaveEvent({this.commissionTarget, this.dealsTarget});
}

/// Takes the person's own target off.
class MyGoalClearEvent extends MyGoalEvent {}
