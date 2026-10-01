import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/goals/domain/repositories/goals_repository.dart';

/// A month with no target, nothing won yet and twenty days to go.
const kEmptyGoal = GoalProgress(
  month: '2026-03',
  currency: 'USD',
  daysLeft: 20,
  personalEditable: true,
);

/// Monthly targets in memory. Writes are recorded in [calls] and answer the
/// way the server would for the figures sent; [readError] and [writeError]
/// make them fail.
class FakeGoalsRepository implements GoalsRepository {
  GoalProgress mine;
  TeamGoals team;
  Object? readError;
  Object? writeError;

  /// What a copy from last month reports it brought over.
  int copyCount;

  /// Every read and write, as "method agentId? month?".
  final List<String> calls = [];

  /// The last figures written, by whichever call.
  ({double? commission, int? deals})? lastWritten;

  FakeGoalsRepository({
    this.mine = kEmptyGoal,
    TeamGoals? team,
    this.copyCount = 0,
  }) : team = team ?? const TeamGoals(agency: kEmptyGoal);

  GoalProgress _set(GoalProgress g, String source, double? c, int? d) =>
      g.copyWith(
        source: source,
        commissionTarget: c,
        dealsTarget: d,
        commissionPercent:
            c == null ? null : (g.commissionAchieved * 100 / c).floor(),
        dealsPercent: d == null ? null : g.dealsWon * 100 ~/ d,
      );

  GoalProgress _cleared(GoalProgress g) => g.copyWith(
        source: null,
        commissionTarget: null,
        dealsTarget: null,
        commissionPercent: null,
        dealsPercent: null,
      );

  Future<void> _write(String call, double? c, int? d) async {
    calls.add(call);
    lastWritten = (commission: c, deals: d);
    if (writeError != null) throw writeError!;
  }

  @override
  Future<GoalProgress> getMyGoal({String? month}) async {
    calls.add('getMyGoal $month');
    if (readError != null) throw readError!;
    return mine;
  }

  @override
  Future<GoalProgress> setMyGoal(
      {String? month, double? commissionTarget, int? dealsTarget}) async {
    await _write('setMyGoal $month', commissionTarget, dealsTarget);
    return mine = _set(mine, 'PERSONAL', commissionTarget, dealsTarget);
  }

  @override
  Future<GoalProgress> clearMyGoal({String? month}) async {
    await _write('clearMyGoal $month', null, null);
    return mine = _cleared(mine);
  }

  @override
  Future<TeamGoals> getTeamGoals({String? month}) async {
    calls.add('getTeamGoals $month');
    if (readError != null) throw readError!;
    return team;
  }

  TeamGoals _member(int agentId, GoalProgress Function(GoalProgress) change) =>
      team = team.copyWith(agents: [
        for (final a in team.agents) a.agentId == agentId ? change(a) : a,
      ], copied: null);

  @override
  Future<TeamGoals> setMemberGoal(int agentId,
      {String? month, double? commissionTarget, int? dealsTarget}) async {
    await _write(
        'setMemberGoal $agentId $month', commissionTarget, dealsTarget);
    return _member(
        agentId, (a) => _set(a, 'MANAGER', commissionTarget, dealsTarget));
  }

  @override
  Future<TeamGoals> clearMemberGoal(int agentId, {String? month}) async {
    await _write('clearMemberGoal $agentId $month', null, null);
    return _member(agentId, _cleared);
  }

  @override
  Future<TeamGoals> setAgencyGoal(
      {String? month, double? commissionTarget, int? dealsTarget}) async {
    await _write('setAgencyGoal $month', commissionTarget, dealsTarget);
    return team = team.copyWith(
        agency: _set(team.agency, 'MANAGER', commissionTarget, dealsTarget),
        copied: null);
  }

  @override
  Future<TeamGoals> clearAgencyGoal({String? month}) async {
    await _write('clearAgencyGoal $month', null, null);
    return team = team.copyWith(agency: _cleared(team.agency), copied: null);
  }

  @override
  Future<TeamGoals> copyPreviousMonth({String? month}) async {
    await _write('copyPreviousMonth $month', null, null);
    return team = team.copyWith(copied: copyCount);
  }
}
