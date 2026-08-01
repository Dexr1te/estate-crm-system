import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GoalEvent {}

class GoalLoadEvent extends GoalEvent {}

class GoalChangedEvent extends GoalEvent {
  final double? target;
  GoalChangedEvent(this.target);
}

class GoalState {
  final double? target;
  const GoalState(this.target);

  bool get isSet => target != null && target! > 0;
}

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  static const _key = 'monthly_goal';

  GoalBloc() : super(const GoalState(null)) {
    on<GoalLoadEvent>(_onLoad);
    on<GoalChangedEvent>(_onChanged);
  }

  Future<void> _onLoad(GoalLoadEvent e, Emitter<GoalState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_key);
    emit(GoalState(stored != null && stored > 0 ? stored : null));
  }

  Future<void> _onChanged(GoalChangedEvent e, Emitter<GoalState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final target = e.target;
    if (target == null || target <= 0) {
      await prefs.remove(_key);
      emit(const GoalState(null));
      return;
    }
    await prefs.setDouble(_key, target);
    emit(GoalState(target));
  }
}
