import 'package:real_estate_crm/core/models/models.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;

  final List<MeetingResponse> upcoming;

  final List<DealResponse> deals;

  DashboardLoaded(this.summary, this.upcoming, this.deals);

  MeetingResponse? get nextMeeting => upcoming.isEmpty ? null : upcoming.first;

  List<MeetingResponse> get laterMeetings =>
      upcoming.length < 2 ? const [] : upcoming.sublist(1);

  int meetingsToday(DateTime now) => upcoming.where((m) {
        final d = m.scheduledAt;
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).length;

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

  List<MeetingResponse> meetingsOn(DateTime now) => upcoming
      .where((m) =>
          m.scheduledAt.year == now.year &&
          m.scheduledAt.month == now.month &&
          m.scheduledAt.day == now.day)
      .toList();

  double closedValueThisMonth(DateTime now) {
    var total = 0.0;
    for (final d in deals) {
      if (d.status != DealStatus.CLOSED_WON) continue;
      final at = d.closedAt ?? d.updatedAt;
      if (at == null) continue;
      if (at.year == now.year && at.month == now.month) {
        total += d.dealPrice ?? d.budget ?? 0;
      }
    }
    return total;
  }

  List<int> dealsCreatedPerDay(DateTime now, {int days = 7}) =>
      _perDay(now, days, (d) => d.createdAt);

  List<int> dealsClosedPerDay(DateTime now, {int days = 7}) => _perDay(
        now,
        days,
        (d) => d.status == DealStatus.CLOSED_WON
            ? (d.closedAt ?? d.updatedAt)
            : null,
      );

  List<int> _perDay(
      DateTime now, int days, DateTime? Function(DealResponse) at) {
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: days - 1));
    final buckets = List<int>.filled(days, 0);
    for (final d in deals) {
      final when = at(d);
      if (when == null) continue;
      final offset =
          DateTime(when.year, when.month, when.day).difference(start).inDays;
      if (offset >= 0 && offset < days) buckets[offset]++;
    }
    return buckets;
  }

  List<StaleDeal> needsAttention(DateTime now, {int limit = 3}) {
    final out = <StaleDeal>[];
    for (final d in deals) {
      if (d.status != DealStatus.LEAD && d.status != DealStatus.NEGOTIATION) {
        continue;
      }
      final touched = d.updatedAt ?? d.createdAt;
      if (touched == null) continue;
      final idle = now.difference(touched).inDays;
      if (idle >= 14) out.add(StaleDeal(d, idle));
    }
    out.sort((a, b) => b.idleDays.compareTo(a.idleDays));
    return out.take(limit).toList();
  }

  List<AgentTotal> topAgents({int limit = 4}) {
    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final d in deals) {
      if (d.status != DealStatus.CLOSED_WON) continue;
      if (d.agentName.trim().isEmpty) continue;
      totals[d.agentName] =
          (totals[d.agentName] ?? 0) + (d.dealPrice ?? d.budget ?? 0);
      counts[d.agentName] = (counts[d.agentName] ?? 0) + 1;
    }
    final ranked = totals.entries
        .map((e) => AgentTotal(e.key, e.value, counts[e.key] ?? 0))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(limit).toList();
  }
}

class AgentTotal {
  final String name;
  final double value;
  final int deals;
  const AgentTotal(this.name, this.value, this.deals);
}

class StaleDeal {
  final DealResponse deal;
  final int idleDays;
  const StaleDeal(this.deal, this.idleDays);

  bool get isSevere => idleDays >= 30;
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class PipelineBreakdown {
  final int leads;
  final int negotiation;
  final int won;
  final int lost;
  final double totalValue;

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

  static const empty = PipelineBreakdown(
      leads: 0, negotiation: 0, won: 0, lost: 0, totalValue: 0);

  bool get isEmpty => leads + negotiation + won + lost == 0;

  int get decided => won + lost;

  double? get winRate => decided == 0 ? null : won / decided;

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
