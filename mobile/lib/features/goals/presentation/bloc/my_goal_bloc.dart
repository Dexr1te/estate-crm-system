import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/goals/domain/repositories/goals_repository.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_event.dart';
import 'package:real_estate_crm/features/goals/presentation/bloc/my_goal_state.dart';

/// The signed-in person's month on the dashboard. A reload keeps the card
/// that is already showing; a failed write leaves the target as it was.
class MyGoalBloc extends Bloc<MyGoalEvent, MyGoalState> {
  final GoalsRepository _repo;

  MyGoalBloc(this._repo) : super(const MyGoalState()) {
    on<MyGoalLoadEvent>(_onLoad);
    on<MyGoalSaveEvent>(_onSave);
    on<MyGoalClearEvent>(_onClear);
  }

  Future<void> _onLoad(MyGoalLoadEvent e, Emitter<MyGoalState> emit) async {
    if (state.goal == null) {
      emit(state.copyWith(status: MyGoalStatus.loading));
    }
    try {
      final goal = await _repo.getMyGoal();
      emit(state.copyWith(status: MyGoalStatus.loaded, goal: goal));
    } catch (_) {
      if (state.goal == null) {
        emit(state.copyWith(status: MyGoalStatus.error));
      }
    }
  }

  Future<void> _onSave(MyGoalSaveEvent e, Emitter<MyGoalState> emit) => _write(
        emit,
        () => _repo.setMyGoal(
            commissionTarget: e.commissionTarget, dealsTarget: e.dealsTarget),
        removed: false,
      );

  Future<void> _onClear(MyGoalClearEvent e, Emitter<MyGoalState> emit) =>
      _write(emit, _repo.clearMyGoal, removed: true);

  Future<void> _write(
    Emitter<MyGoalState> emit,
    Future<GoalProgress> Function() call, {
    required bool removed,
  }) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final goal = await call();
      emit(state.copyWith(
        status: MyGoalStatus.loaded,
        goal: goal,
        saving: false,
        outcome: GoalSaved(removed: removed),
      ));
    } catch (error) {
      emit(state.copyWith(
          saving: false, outcome: GoalWriteFailed(ApiFailure.from(error))));
    }
  }
}
