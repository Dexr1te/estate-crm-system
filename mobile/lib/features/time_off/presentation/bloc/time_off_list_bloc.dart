import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/time_off/domain/repositories/time_off_repository.dart';
import 'package:real_estate_crm/features/time_off/domain/time_off.dart';

abstract class TimeOffListEvent {}

class TimeOffListLoadEvent extends TimeOffListEvent {}

abstract class TimeOffListState {
  const TimeOffListState();
}

class TimeOffListInitial extends TimeOffListState {
  const TimeOffListInitial();
}

class TimeOffListLoading extends TimeOffListState {
  const TimeOffListLoading();
}

/// Soonest first, as the server sends them.
class TimeOffListLoaded extends TimeOffListState {
  final List<TimeOff> items;
  const TimeOffListLoaded(this.items);
}

class TimeOffListError extends TimeOffListState {
  final ApiFailure failure;
  const TimeOffListError(this.failure);
}

/// The agency's time off over a window counted in days from the phone's
/// today: [daysBack] before it to [daysAhead] after, one person's with
/// [userId].
class TimeOffListBloc extends Bloc<TimeOffListEvent, TimeOffListState>
    with SingleFlight, CollectionBloc<TimeOffListEvent, TimeOffListState> {
  final TimeOffRepository _repo;
  final int daysBack;
  final int daysAhead;
  final int? userId;

  TimeOffListBloc(
    this._repo, {
    this.daysBack = 0,
    this.daysAhead = kTimeOffTeamWindowDays,
    this.userId,
  }) : super(const TimeOffListInitial()) {
    on<TimeOffListLoadEvent>((e, emit) {
      final today = timeOffDay(AppClock.now());
      return load(
        emit,
        keepVisible: state is TimeOffListLoaded,
        skeleton: const TimeOffListLoading(),
        fetch: () => _repo.getTimeOff(
          from: today.subtract(Duration(days: daysBack)),
          to: today.add(Duration(days: daysAhead)),
          userId: userId,
        ),
        onData: TimeOffListLoaded.new,
        onFailure: TimeOffListError.new,
      );
    });
  }

  /// The team's list from today on: who is out, this week, and later.
  factory TimeOffListBloc.team(TimeOffRepository repo) => TimeOffListBloc(repo);

  /// Who is out on the phone's today, for the dashboard.
  factory TimeOffListBloc.today(TimeOffRepository repo) =>
      TimeOffListBloc(repo, daysAhead: 0);

  /// One person's own, a while back and a year ahead.
  factory TimeOffListBloc.mine(TimeOffRepository repo, int userId) =>
      TimeOffListBloc(repo,
          daysBack: kTimeOffPastDays,
          daysAhead: kTimeOffAheadDays,
          userId: userId);
}
