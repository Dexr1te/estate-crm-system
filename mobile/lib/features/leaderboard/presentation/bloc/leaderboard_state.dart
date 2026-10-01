import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';

enum LeaderboardPeriod { thisMonth, lastMonth, quarter, custom }

enum LeaderboardSort { commission, dealsWon, viewings, newClients, winRate }

/// A period as the server takes it: [from] inclusive, [to] exclusive.
class LeaderboardRange {
  final DateTime from;
  final DateTime to;
  const LeaderboardRange(this.from, this.to);

  /// The calendar period around [now]; [LeaderboardPeriod.custom] has no
  /// rule of its own and falls back to this month.
  factory LeaderboardRange.of(LeaderboardPeriod period, DateTime now) {
    switch (period) {
      case LeaderboardPeriod.lastMonth:
        return LeaderboardRange(
            DateTime(now.year, now.month - 1), DateTime(now.year, now.month));
      case LeaderboardPeriod.quarter:
        final first = ((now.month - 1) ~/ 3) * 3 + 1;
        return LeaderboardRange(
            DateTime(now.year, first), DateTime(now.year, first + 3));
      case LeaderboardPeriod.thisMonth:
      case LeaderboardPeriod.custom:
        return LeaderboardRange(
            DateTime(now.year, now.month), DateTime(now.year, now.month + 1));
    }
  }

  /// The last day inside the period, for showing it.
  DateTime get lastDay => to.subtract(const Duration(days: 1));

  @override
  bool operator ==(Object other) =>
      other is LeaderboardRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// [rows] in the order [sort] asks for, each ranked by its new place. Ties
/// keep the server's order (commission, then deals won, then name); a win
/// rate with nothing closed always goes last.
List<LeaderboardRow> sortLeaderboard(
    List<LeaderboardRow> rows, LeaderboardSort sort, bool ascending) {
  final indexed = [for (var i = 0; i < rows.length; i++) (i, rows[i])];
  indexed.sort((a, b) {
    final x = _key(a.$2, sort);
    final y = _key(b.$2, sort);
    if (x == null || y == null) {
      if (x == null && y == null) return a.$1.compareTo(b.$1);
      return x == null ? 1 : -1;
    }
    final byKey = ascending ? x.compareTo(y) : y.compareTo(x);
    return byKey != 0 ? byKey : a.$1.compareTo(b.$1);
  });
  return [
    for (var i = 0; i < indexed.length; i++)
      indexed[i].$2.copyWith(rank: i + 1),
  ];
}

num? _key(LeaderboardRow row, LeaderboardSort sort) {
  switch (sort) {
    case LeaderboardSort.commission:
      return row.commission;
    case LeaderboardSort.dealsWon:
      return row.dealsWon;
    case LeaderboardSort.viewings:
      return row.viewingsHeld;
    case LeaderboardSort.newClients:
      return row.newClients;
    case LeaderboardSort.winRate:
      return row.winRate;
  }
}

abstract class LeaderboardState {
  final LeaderboardPeriod period;
  final LeaderboardRange range;
  final LeaderboardSort sort;
  final bool ascending;
  const LeaderboardState(this.period, this.range, this.sort, this.ascending);
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading(
      super.period, super.range, super.sort, super.ascending);
}

class LeaderboardLoaded extends LeaderboardState {
  final AgentLeaderboard board;
  const LeaderboardLoaded(
      this.board, super.period, super.range, super.sort, super.ascending);

  List<LeaderboardRow> get agents =>
      sortLeaderboard(board.agents, sort, ascending);

  List<LeaderboardRow> get inactive =>
      sortLeaderboard(board.inactive, sort, ascending);
}

class LeaderboardError extends LeaderboardState {
  final ApiFailure failure;
  const LeaderboardError(
      this.failure, super.period, super.range, super.sort, super.ascending);
}
