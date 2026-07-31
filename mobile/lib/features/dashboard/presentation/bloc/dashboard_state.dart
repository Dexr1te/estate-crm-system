import 'package:real_estate_crm/core/models/models.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;

  /// Not-yet-held meetings, soonest first. Full [MeetingResponse]s (not the
  /// slim upcoming DTO) so the hero can name the agent and open the linked
  /// deal.
  final List<MeetingResponse> upcoming;

  /// Every deal in scope, used to derive the team pipeline. Empty when the
  /// deals call failed — the pipeline card is then hidden rather than taking
  /// the whole dashboard down.
  final List<DealResponse> deals;

  DashboardLoaded(this.summary, this.upcoming, this.deals);

  MeetingResponse? get nextMeeting => upcoming.isEmpty ? null : upcoming.first;

  /// Everything after the hero.
  List<MeetingResponse> get laterMeetings =>
      upcoming.length < 2 ? const [] : upcoming.sublist(1);

  int meetingsToday(DateTime now) => upcoming.where((m) {
        final d = m.scheduledAt;
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).length;

  /// Meetings per day for the next [days] days, starting today. Index 0 is
  /// today. Days beyond the loaded window simply read zero.
  List<int> meetingLoad(DateTime now, {int days = 14}) {
    final start = DateTime(now.year, now.month, now.day);
    final buckets = List<int>.filled(days, 0);
    for (final m in upcoming) {
      final d = m.scheduledAt;
      final offset = DateTime(d.year, d.month, d.day).difference(start).inDays;
      if (offset >= 0 && offset < days) buckets[offset]++;
    }
    return buckets;
  }

  /// Agents ranked by the value they have closed, richest first.
  ///
  /// Only CLOSED_WON counts — an open deal is a hope, not a result. Deals with
  /// no agent name attached are skipped rather than bucketed under a blank.
  List<AgentTotal> topAgents({int limit = 4}) {
    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final d in deals) {
      if (d.status != DealStatus.CLOSED_WON) continue;
      if (d.agentName.trim().isEmpty) continue;
      totals[d.agentName] = (totals[d.agentName] ?? 0) + (d.dealPrice ?? d.budget ?? 0);
      counts[d.agentName] = (counts[d.agentName] ?? 0) + 1;
    }
    final ranked = totals.entries
        .map((e) => AgentTotal(e.key, e.value, counts[e.key] ?? 0))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(limit).toList();
  }
}

/// One row of the "top agents" card.
class AgentTotal {
  final String name;
  final double value;
  final int deals;
  const AgentTotal(this.name, this.value, this.deals);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

/// Per-stage counts and the total value behind the pipeline card.
class PipelineBreakdown {
  final int leads;
  final int negotiation;
  final int won;
  final int lost;
  final double totalValue;

  /// Money sitting in each stage, same order as the counts above. Taken from
  /// `dealPrice ?? budget`, so a deal with neither contributes nothing.
  final double leadValue;
  final double negotiationValue;
  final double wonValue;

  const PipelineBreakdown({
    required this.leads,
    required this.negotiation,
    required this.won,
    required this.lost,
    required this.totalValue,
    this.leadValue = 0,
    this.negotiationValue = 0,
    this.wonValue = 0,
  });

  static const empty =
      PipelineBreakdown(leads: 0, negotiation: 0, won: 0, lost: 0, totalValue: 0);

  bool get isEmpty => leads + negotiation + won + lost == 0;

  /// Deals that reached a conclusion, either way.
  int get decided => won + lost;

  /// Share of concluded deals that were won, 0–1. Null while nothing has been
  /// decided — a rate over zero deals is not 0%, it is unknown, and drawing it
  /// as 0% would libel the team.
  double? get winRate => decided == 0 ? null : won / decided;

  /// The largest single stage value, for scaling the bars.
  double get peakStageValue => [leadValue, negotiationValue, wonValue]
      .fold<double>(0, (a, b) => b > a ? b : a);

  factory PipelineBreakdown.from(List<DealResponse> deals) {
    var leads = 0, negotiation = 0, won = 0, lost = 0;
    var total = 0.0, leadValue = 0.0, negotiationValue = 0.0, wonValue = 0.0;
    for (final d in deals) {
      final value = d.dealPrice ?? d.budget ?? 0;
      switch (d.status) {
        case DealStatus.LEAD:
          leads++;
          leadValue += value;
          break;
        case DealStatus.NEGOTIATION:
          negotiation++;
          negotiationValue += value;
          break;
        case DealStatus.CLOSED_WON:
          won++;
          wonValue += value;
          break;
        case DealStatus.CLOSED_LOST:
          lost++;
          break;
      }
      total += value;
    }
    return PipelineBreakdown(
      leads: leads,
      negotiation: negotiation,
      won: won,
      lost: lost,
      totalValue: total,
      leadValue: leadValue,
      negotiationValue: negotiationValue,
      wonValue: wonValue,
    );
  }
}
