import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/goals/domain/repositories/goals_repository.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_state.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/team_goals_event.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/team_goals_state.dart';

/// The manager's month: every member's target and progress, the agency's,
/// and the writes that change them. Every write answers with the whole month,
/// so the screen always shows what the server holds.
class TeamGoalsBloc extends Bloc<TeamGoalsEvent, TeamGoalsState> {
  final GoalsRepository _repo;

  TeamGoalsBloc(this._repo)
      : super(TeamGoalsState(month: monthOf(AppClock.now()))) {
    on<TeamGoalsLoadEvent>(_onLoad);
    on<TeamGoalsMonthEvent>(_onMonth);
    on<TeamGoalsSaveEvent>(_onSave);
    on<TeamGoalsClearEvent>(_onClear);
    on<TeamGoalsCopyPreviousEvent>(_onCopy);
  }

  String get _month => monthParam(state.month);

  Future<void> _onLoad(TeamGoalsLoadEvent e, Emitter<TeamGoalsState> emit) =>
      _fetch(emit);

  Future<void> _onMonth(TeamGoalsMonthEvent e, Emitter<TeamGoalsState> emit) {
    final month = DateTime(state.month.year, state.month.month + e.delta);
    emit(state.copyWith(
        month: month, status: TeamGoalsStatus.loading, clearGoals: true));
    return _fetch(emit);
  }

  Future<void> _fetch(Emitter<TeamGoalsState> emit) async {
    final asked = state.month;
    if (state.goals == null) {
      emit(state.copyWith(status: TeamGoalsStatus.loading));
    }
    try {
      final goals = await _repo.getTeamGoals(month: monthParam(asked));
      if (state.month != asked) return;
      emit(state.copyWith(status: TeamGoalsStatus.loaded, goals: goals));
    } catch (error) {
      if (state.month != asked) return;
      emit(state.copyWith(
          status: TeamGoalsStatus.error, loadFailure: ApiFailure.from(error)));
    }
  }

  Future<void> _onSave(TeamGoalsSaveEvent e, Emitter<TeamGoalsState> emit) {
    final agentId = e.agentId;
    return _write(
      emit,
      () => agentId == null
          ? _repo.setAgencyGoal(
              month: _month,
              commissionTarget: e.commissionTarget,
              dealsTarget: e.dealsTarget)
          : _repo.setMemberGoal(agentId,
              month: _month,
              commissionTarget: e.commissionTarget,
              dealsTarget: e.dealsTarget),
      (_) => GoalSaved(),
    );
  }

  Future<void> _onClear(TeamGoalsClearEvent e, Emitter<TeamGoalsState> emit) {
    final agentId = e.agentId;
    return _write(
      emit,
      () => agentId == null
          ? _repo.clearAgencyGoal(month: _month)
          : _repo.clearMemberGoal(agentId, month: _month),
      (_) => GoalSaved(removed: true),
    );
  }

  Future<void> _onCopy(
          TeamGoalsCopyPreviousEvent e, Emitter<TeamGoalsState> emit) =>
      _write(
        emit,
        () => _repo.copyPreviousMonth(month: _month),
        (goals) => GoalsCopied(goals.copied ?? 0),
      );

  Future<void> _write(
    Emitter<TeamGoalsState> emit,
    Future<TeamGoals> Function() call,
    ActionOutcome Function(TeamGoals) outcome,
  ) async {
    if (state.saving || !state.editable) return;
    final asked = state.month;
    emit(state.copyWith(saving: true));
    try {
      final goals = await call();
      if (state.month != asked) {
        emit(state.copyWith(saving: false));
        return;
      }
      emit(state.copyWith(
        status: TeamGoalsStatus.loaded,
        goals: goals,
        saving: false,
        outcome: outcome(goals),
      ));
    } catch (error) {
      emit(state.copyWith(
          saving: false, outcome: GoalWriteFailed(ApiFailure.from(error))));
    }
  }
}
