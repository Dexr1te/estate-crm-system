import 'package:real_estate_crm/core/models/models.dart';

/// Monthly targets. [month] is "2026-10" and means this month when left out.
abstract class GoalsRepository {
  /// The signed-in person's month: the target that counts (the manager's
  /// wins over their own) and how far the deals won have got.
  Future<GoalProgress> getMyGoal({String? month});

  /// The person's own target. Refused while the manager's counts.
  Future<GoalProgress> setMyGoal(
      {String? month, double? commissionTarget, int? dealsTarget});

  Future<GoalProgress> clearMyGoal({String? month});

  /// The manager's view, like everything below: every member and the agency.
  Future<TeamGoals> getTeamGoals({String? month});

  Future<TeamGoals> setMemberGoal(int agentId,
      {String? month, double? commissionTarget, int? dealsTarget});

  Future<TeamGoals> clearMemberGoal(int agentId, {String? month});

  Future<TeamGoals> setAgencyGoal(
      {String? month, double? commissionTarget, int? dealsTarget});

  Future<TeamGoals> clearAgencyGoal({String? month});

  /// Brings last month's targets into [month], leaving any already set.
  Future<TeamGoals> copyPreviousMonth({String? month});
}
