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

  const PipelineBreakdown({
    required this.leads,
    required this.negotiation,
    required this.won,
    required this.lost,
    required this.totalValue,
  });

  static const empty =
      PipelineBreakdown(leads: 0, negotiation: 0, won: 0, lost: 0, totalValue: 0);

  bool get isEmpty => leads + negotiation + won + lost == 0;

  factory PipelineBreakdown.from(List<DealResponse> deals) {
    var leads = 0, negotiation = 0, won = 0, lost = 0;
    var total = 0.0;
    for (final d in deals) {
      switch (d.status) {
        case DealStatus.LEAD:
          leads++;
          break;
        case DealStatus.NEGOTIATION:
          negotiation++;
          break;
        case DealStatus.CLOSED_WON:
          won++;
          break;
        case DealStatus.CLOSED_LOST:
          lost++;
          break;
      }
      total += d.dealPrice ?? d.budget ?? 0;
    }
    return PipelineBreakdown(
      leads: leads,
      negotiation: negotiation,
      won: won,
      lost: lost,
      totalValue: total,
    );
  }
}
