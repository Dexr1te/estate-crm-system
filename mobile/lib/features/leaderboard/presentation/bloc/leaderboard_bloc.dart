import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository _repo;
  int _request = 0;

  LeaderboardBloc(this._repo)
      : super(LeaderboardLoading(
          LeaderboardPeriod.thisMonth,
          LeaderboardRange.of(LeaderboardPeriod.thisMonth, AppClock.now()),
          LeaderboardSort.commission,
          false,
        )) {
    on<LeaderboardLoadEvent>((e, emit) => _load(emit, state.period,
        state.period == LeaderboardPeriod.custom ? state.range : null));
    on<LeaderboardPeriodChanged>((e, emit) => _load(emit, e.period, null));
    on<LeaderboardCustomRange>((e, emit) {
      final first = DateTime(e.first.year, e.first.month, e.first.day);
      final last = DateTime(e.last.year, e.last.month, e.last.day);
      return _load(
          emit,
          LeaderboardPeriod.custom,
          LeaderboardRange(
              first, DateTime(last.year, last.month, last.day + 1)));
    });
    on<LeaderboardSortChanged>((e, emit) {
      final ascending = e.sort == state.sort && !state.ascending;
      final s = state;
      if (s is LeaderboardLoaded) {
        emit(LeaderboardLoaded(s.board, s.period, s.range, e.sort, ascending));
      } else if (s is LeaderboardError) {
        emit(LeaderboardError(s.failure, s.period, s.range, e.sort, ascending));
      } else {
        emit(LeaderboardLoading(s.period, s.range, e.sort, ascending));
      }
    });
  }

  Future<void> _load(Emitter<LeaderboardState> emit, LeaderboardPeriod period,
      LeaderboardRange? custom) async {
    final request = ++_request;
    final range = custom ?? LeaderboardRange.of(period, AppClock.now());
    final sort = state.sort;
    final ascending = state.ascending;
    emit(LeaderboardLoading(period, range, sort, ascending));
    try {
      final board = await _repo.getLeaderboard(from: range.from, to: range.to);
      if (request != _request) return;
      emit(
          LeaderboardLoaded(board, period, range, state.sort, state.ascending));
    } catch (e) {
      if (request != _request) return;
      emit(LeaderboardError(
          ApiFailure.from(e), period, range, state.sort, state.ascending));
    }
  }
}
