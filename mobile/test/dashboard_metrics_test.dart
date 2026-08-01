import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';

DealResponse _deal(DealStatus status, {double? price, String agent = 'A'}) =>
    DealResponse(
      id: 1,
      status: status,
      clientId: 1,
      agentId: 1,
      agentName: agent,
      dealPrice: price,
    );

MeetingResponse _meeting(DateTime at) =>
    MeetingResponse(id: 1, scheduledAt: at, agentId: 1, clientId: 1);

DashboardLoaded _loaded({
  List<MeetingResponse> meetings = const [],
  List<DealResponse> deals = const [],
}) =>
    DashboardLoaded(const DashboardSummary(), meetings, deals);

void main() {
  group('win rate', () {
    test('is unknown, not zero, before anything is decided', () {
      final p = PipelineBreakdown.from([
        _deal(DealStatus.LEAD, price: 100),
        _deal(DealStatus.NEGOTIATION, price: 200),
      ]);
      expect(p.winRate, isNull,
          reason:
              'drawing 0% here would report a failure the team has not had');
      expect(p.decided, 0);
    });

    test('ignores open deals', () {
      final p = PipelineBreakdown.from([
        _deal(DealStatus.CLOSED_WON, price: 1),
        _deal(DealStatus.CLOSED_LOST, price: 1),
        for (var i = 0; i < 10; i++) _deal(DealStatus.LEAD, price: 1),
      ]);
      expect(p.winRate, 0.5);
    });
  });

  group('value by stage', () {
    test('falls back to budget when there is no agreed price', () {
      final p = PipelineBreakdown.from([
        const DealResponse(
            id: 1,
            status: DealStatus.LEAD,
            clientId: 1,
            agentId: 1,
            budget: 500),
        _deal(DealStatus.LEAD, price: 250),
      ]);
      expect(p.leadValue, 750);
    });

    test('a deal with neither price nor budget contributes nothing', () {
      final p = PipelineBreakdown.from([_deal(DealStatus.LEAD)]);
      expect(p.leads, 1, reason: 'it still counts as a deal');
      expect(p.leadValue, 0);
      expect(p.peakStageValue, 0);
    });
  });

  group('meeting load', () {
    test('buckets by day, with today at index 0', () {
      final now = DateTime(2026, 7, 31, 14);
      final state = _loaded(meetings: [
        _meeting(DateTime(2026, 7, 31, 9)),
        _meeting(DateTime(2026, 7, 31, 18)),
        _meeting(DateTime(2026, 8, 2, 11)),
      ]);

      final load = state.meetingLoad(now);
      expect(load[0], 2);
      expect(load[1], 0);
      expect(load[2], 1);
      expect(load, hasLength(14));
    });

    test('drops meetings outside the window instead of clamping them', () {
      final now = DateTime(2026, 7, 31);
      final state = _loaded(meetings: [
        _meeting(DateTime(2026, 9, 30)),
        _meeting(DateTime(2026, 7, 1)),
      ]);
      expect(state.meetingLoad(now).every((c) => c == 0), isTrue,
          reason: 'a far-off meeting must not pile onto the last column');
    });
  });

  group('closed this month', () {
    test('counts only won deals closed inside the current month', () {
      final now = DateTime(2026, 8, 15);
      final state = _loaded(deals: [
        DealResponse(
            id: 1,
            status: DealStatus.CLOSED_WON,
            clientId: 1,
            agentId: 1,
            dealPrice: 100,
            closedAt: DateTime(2026, 8, 3)),
        DealResponse(
            id: 2,
            status: DealStatus.CLOSED_WON,
            clientId: 1,
            agentId: 1,
            dealPrice: 999,
            closedAt: DateTime(2026, 7, 31)),
        DealResponse(
            id: 3,
            status: DealStatus.CLOSED_LOST,
            clientId: 1,
            agentId: 1,
            dealPrice: 500,
            closedAt: DateTime(2026, 8, 4)),
      ]);
      expect(state.closedValueThisMonth(now), 100);
    });

    test('a won deal with no closing date is not counted', () {
      final state = _loaded(deals: [_deal(DealStatus.CLOSED_WON, price: 100)]);
      expect(state.closedValueThisMonth(DateTime(2026, 8, 15)), 0,
          reason: 'guessing which month it belongs to would invent a number');
    });
  });

  group('7-day series', () {
    test('buckets creations by day, ending today', () {
      final now = DateTime(2026, 8, 15, 18);
      final state = _loaded(deals: [
        DealResponse(
            id: 1,
            clientId: 1,
            agentId: 1,
            createdAt: DateTime(2026, 8, 15, 9)),
        DealResponse(
            id: 2, clientId: 1, agentId: 1, createdAt: DateTime(2026, 8, 9)),
        DealResponse(
            id: 3, clientId: 1, agentId: 1, createdAt: DateTime(2026, 8, 1)),
      ]);
      final series = state.dealsCreatedPerDay(now);
      expect(series, hasLength(7));
      expect(series.last, 1, reason: 'today is the last bar');
      expect(series.first, 1, reason: 'seven days ago is the first');
      expect(series.reduce((a, b) => a + b), 2,
          reason: 'the deal from two weeks back falls outside the window');
    });

    test('the closed series ignores deals that are still open', () {
      final now = DateTime(2026, 8, 15);
      final state = _loaded(deals: [
        DealResponse(
            id: 1,
            status: DealStatus.NEGOTIATION,
            clientId: 1,
            agentId: 1,
            closedAt: DateTime(2026, 8, 15)),
      ]);
      expect(state.dealsClosedPerDay(now).every((c) => c == 0), isTrue);
    });
  });

  group('needs attention', () {
    DealResponse idle(int id, DealStatus status, int days) => DealResponse(
        id: id,
        status: status,
        clientId: 1,
        agentId: 1,
        updatedAt: DateTime(2026, 8, 15).subtract(Duration(days: days)));

    final now = DateTime(2026, 8, 15);

    test('picks up open deals that have gone quiet, worst first', () {
      final state = _loaded(deals: [
        idle(1, DealStatus.LEAD, 20),
        idle(2, DealStatus.NEGOTIATION, 40),
        idle(3, DealStatus.LEAD, 2),
      ]);
      final flagged = state.needsAttention(now);
      expect(flagged.map((s) => s.deal.id), [2, 1]);
      expect(flagged.first.isSevere, isTrue);
      expect(flagged.last.isSevere, isFalse);
    });

    test('a closed deal is never stale, however old', () {
      final state = _loaded(deals: [idle(1, DealStatus.CLOSED_WON, 400)]);
      expect(state.needsAttention(now), isEmpty,
          reason: 'nothing is expected to happen to a deal that is done');
    });
  });

  group('top agents', () {
    test('ranks by closed value and ignores open deals', () {
      final state = _loaded(deals: [
        _deal(DealStatus.CLOSED_WON, price: 100, agent: 'Quiet closer'),
        _deal(DealStatus.CLOSED_WON, price: 900, agent: 'Big closer'),
        _deal(DealStatus.NEGOTIATION, price: 100000, agent: 'Optimist'),
      ]);

      final ranked = state.topAgents();
      expect(ranked.map((a) => a.name), ['Big closer', 'Quiet closer']);
      expect(ranked.first.value, 900);
      expect(ranked.first.deals, 1);
    });

    test('skips deals with no agent rather than bucketing them under a blank',
        () {
      final state = _loaded(deals: [
        _deal(DealStatus.CLOSED_WON, price: 10, agent: ''),
        _deal(DealStatus.CLOSED_WON, price: 10, agent: '   '),
      ]);
      expect(state.topAgents(), isEmpty);
    });

    test('sums several deals per agent', () {
      final state = _loaded(deals: [
        _deal(DealStatus.CLOSED_WON, price: 10, agent: 'A'),
        _deal(DealStatus.CLOSED_WON, price: 15, agent: 'A'),
      ]);
      final ranked = state.topAgents();
      expect(ranked.single.value, 25);
      expect(ranked.single.deals, 2);
    });
  });
}
