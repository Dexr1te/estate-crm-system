import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class GoalsRemoteDataSource {
  final ApiClient _client;
  GoalsRemoteDataSource(this._client);

  static const _me = '/goals/me';
  static const _team = '/goals/team';

  Map<String, dynamic>? _query(String? month) =>
      month == null ? null : {'month': month};

  Map<String, dynamic> _body(double? commissionTarget, int? dealsTarget) =>
      {'commissionTarget': commissionTarget, 'dealsTarget': dealsTarget};

  Future<GoalProgress> getMyGoal({String? month}) async {
    final res = await _client.dio.get(_me, queryParameters: _query(month));
    return GoalProgress.fromJson(jsonObject(res));
  }

  Future<GoalProgress> setMyGoal(
      {String? month, double? commissionTarget, int? dealsTarget}) async {
    final res = await _client.dio.put(_me,
        queryParameters: _query(month),
        data: _body(commissionTarget, dealsTarget));
    return GoalProgress.fromJson(jsonObject(res));
  }

  Future<GoalProgress> clearMyGoal({String? month}) async {
    final res = await _client.dio.delete(_me, queryParameters: _query(month));
    return GoalProgress.fromJson(jsonObject(res));
  }

  Future<TeamGoals> getTeamGoals({String? month}) async {
    final res = await _client.dio.get(_team, queryParameters: _query(month));
    return TeamGoals.fromJson(jsonObject(res));
  }

  Future<TeamGoals> setMemberGoal(int agentId,
      {String? month, double? commissionTarget, int? dealsTarget}) async {
    final res = await _client.dio.put('$_team/agents/$agentId',
        queryParameters: _query(month),
        data: _body(commissionTarget, dealsTarget));
    return TeamGoals.fromJson(jsonObject(res));
  }

  Future<TeamGoals> clearMemberGoal(int agentId, {String? month}) async {
    final res = await _client.dio
        .delete('$_team/agents/$agentId', queryParameters: _query(month));
    return TeamGoals.fromJson(jsonObject(res));
  }

  Future<TeamGoals> setAgencyGoal(
      {String? month, double? commissionTarget, int? dealsTarget}) async {
    final res = await _client.dio.put('$_team/agency',
        queryParameters: _query(month),
        data: _body(commissionTarget, dealsTarget));
    return TeamGoals.fromJson(jsonObject(res));
  }

  Future<TeamGoals> clearAgencyGoal({String? month}) async {
    final res = await _client.dio
        .delete('$_team/agency', queryParameters: _query(month));
    return TeamGoals.fromJson(jsonObject(res));
  }

  Future<TeamGoals> copyPreviousMonth({String? month}) async {
    final res = await _client.dio
        .post('$_team/copy-previous', queryParameters: _query(month));
    return TeamGoals.fromJson(jsonObject(res));
  }
}
