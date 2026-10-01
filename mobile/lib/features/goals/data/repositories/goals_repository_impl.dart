import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/goals/data/datasources/goals_remote_datasource.dart';
import 'package:real_estate_crm/features/goals/domain/repositories/goals_repository.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  final GoalsRemoteDataSource _remote;
  GoalsRepositoryImpl(this._remote);

  @override
  Future<GoalProgress> getMyGoal({String? month}) =>
      _remote.getMyGoal(month: month);

  @override
  Future<GoalProgress> setMyGoal(
          {String? month, double? commissionTarget, int? dealsTarget}) =>
      _remote.setMyGoal(
          month: month,
          commissionTarget: commissionTarget,
          dealsTarget: dealsTarget);

  @override
  Future<GoalProgress> clearMyGoal({String? month}) =>
      _remote.clearMyGoal(month: month);

  @override
  Future<TeamGoals> getTeamGoals({String? month}) =>
      _remote.getTeamGoals(month: month);

  @override
  Future<TeamGoals> setMemberGoal(int agentId,
          {String? month, double? commissionTarget, int? dealsTarget}) =>
      _remote.setMemberGoal(agentId,
          month: month,
          commissionTarget: commissionTarget,
          dealsTarget: dealsTarget);

  @override
  Future<TeamGoals> clearMemberGoal(int agentId, {String? month}) =>
      _remote.clearMemberGoal(agentId, month: month);

  @override
  Future<TeamGoals> setAgencyGoal(
          {String? month, double? commissionTarget, int? dealsTarget}) =>
      _remote.setAgencyGoal(
          month: month,
          commissionTarget: commissionTarget,
          dealsTarget: dealsTarget);

  @override
  Future<TeamGoals> clearAgencyGoal({String? month}) =>
      _remote.clearAgencyGoal(month: month);

  @override
  Future<TeamGoals> copyPreviousMonth({String? month}) =>
      _remote.copyPreviousMonth(month: month);
}
