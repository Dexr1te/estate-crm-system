import 'package:real_estate_crm/features/leaderboard/presentation/bloc/leaderboard_state.dart';

abstract class LeaderboardEvent {}

class LeaderboardLoadEvent extends LeaderboardEvent {}

/// A calendar period: this month, last month or the quarter.
class LeaderboardPeriodChanged extends LeaderboardEvent {
  final LeaderboardPeriod period;
  LeaderboardPeriodChanged(this.period);
}

/// Dates the manager picked, [first] to [last], both days included.
class LeaderboardCustomRange extends LeaderboardEvent {
  final DateTime first;
  final DateTime last;
  LeaderboardCustomRange(this.first, this.last);
}

/// Sort by [sort], largest first; the column already sorted by flips.
class LeaderboardSortChanged extends LeaderboardEvent {
  final LeaderboardSort sort;
  LeaderboardSortChanged(this.sort);
}
