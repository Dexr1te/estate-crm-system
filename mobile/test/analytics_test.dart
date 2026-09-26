import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:real_estate_crm/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/pipeline_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The analytics screen with a funnel whose figures are known: what it shows,
/// what it asks the server for as the period and agent change, how it waits,
/// and that it fits every acceptance size in every language.

final _now = DateTime(2026, 9, 25, 15, 30);

const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);
const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);

final _funnel = DealFunnel(
  created: 7,
  reachedNegotiation: 4,
  won: 2,
  lost: 3,
  leadToNegotiationRate: 4 / 7,
  negotiationToWonRate: 0.5,
  leadToWonRate: 2 / 7,
  wonValue: 30000000,
  avgDaysToWin: 7,
  lostReasons: const [
    FunnelLostReason(reason: 'PRICE', count: 2, share: 2 / 3),
    FunnelLostReason(reason: 'UNSPECIFIED', count: 1, share: 1 / 3),
  ],
  monthly: [
    for (var i = 0; i < 6; i++)
      FunnelMonth(
        month: DateTime(2026, 4 + i),
        created: i == 5 ? 7 : i,
        won: i == 5 ? 2 : i ~/ 2,
        lost: i == 5 ? 3 : 0,
      ),
  ],
);

late FakeAnalyticsRepository _repo;

Future<AuthBloc> _signedIn(AuthResponse user) async {
  final auth = AuthBloc(FakeAuthRepository(user: user))..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  return auth;
}

Future<void> _show(WidgetTester tester, AuthBloc auth,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(
    tester,
    BlocProvider.value(
        value: auth, child: AnalyticsScreen(key: ValueKey(locale))),
    size: size,
    brightness: brightness,
    textScale: scale,
    locale: locale,
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = FakeAnalyticsRepository(_funnel);
    Injector.analyticsRepository = _repo;
    Injector.agentsRepository = const FakeAgentsRepository([
      AgentOption(id: 5, fullName: 'Maria Kim'),
      AgentOption(id: 6, fullName: 'Daniyar Seitkali'),
    ]);
  });
  tearDown(AppClock.reset);

  testWidgets('shows the funnel, the money, the days and why deals are lost',
      (tester) async {
    await _show(tester, await _signedIn(_manager));

    expect(find.text(r'$30.0M'), findsOneWidget);
    expect(find.text('7 d'), findsOneWidget);

    expect(find.text('FUNNEL'), findsOneWidget);
    expect(find.text('57% of the previous stage'), findsOneWidget);
    expect(find.text('50% of the previous stage'), findsOneWidget);
    expect(find.text('2 won · 3 lost'), findsOneWidget);
    expect(find.text('Lead to won 29%'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('WHY DEALS ARE LOST'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('2 · 67%'), findsOneWidget);
    expect(find.text('Not specified'), findsOneWidget);
    expect(find.text('UNSPECIFIED'), findsNothing);

    await tester.scrollUntilVisible(find.text('Sep'), 200,
        scrollable: find.byType(Scrollable).first);
    for (final m in ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep']) {
      expect(find.text(m), findsOneWidget);
    }
  });

  testWidgets('the period tabs ask for this month, the quarter and the year',
      (tester) async {
    await _show(tester, await _signedIn(_agent));
    expect(_repo.requests.last.from, DateTime(2026, 9));
    expect(_repo.requests.last.to, DateTime(2026, 10));

    await tester.tap(find.text('Quarter'));
    await tester.pumpAndSettle();
    expect(_repo.requests.last.from, DateTime(2026, 7));
    expect(_repo.requests.last.to, DateTime(2026, 10));

    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();
    expect(_repo.requests.last.from, DateTime(2026));
    expect(_repo.requests.last.to, DateTime(2027));
    expect(_repo.requests.every((r) => r.agentId == null), isTrue);
  });

  test('a quarter starts on the first month of its three', () {
    final q =
        AnalyticsRange.of(AnalyticsPeriod.quarter, DateTime(2026, 12, 31));
    expect(q.from, DateTime(2026, 10));
    expect(q.to, DateTime(2027));
  });

  testWidgets('a manager narrows to one agent; an agent has no such filter',
      (tester) async {
    await _show(tester, await _signedIn(_manager));
    expect(find.text('Agent: All agents'), findsOneWidget);

    await tester.tap(find.text('Agent: All agents'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maria Kim'));
    await tester.pumpAndSettle();

    expect(_repo.requests.last.agentId, 5);
    expect(find.text('Agent: Maria Kim'), findsOneWidget);

    await _show(tester, await _signedIn(_agent), locale: const Locale('ru'));
    expect(find.byKey(const ValueKey('analytics-agent')), findsNothing);
  });

  testWidgets('waits with a skeleton, not a spinner', (tester) async {
    final gate = Completer<DealFunnel>();
    Injector.analyticsRepository = _GatedAnalytics(gate.future);
    await _show(tester, await _signedIn(_agent));

    expect(find.byType(ShimmerGroup), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    gate.complete(_funnel);
    await tester.pumpAndSettle();
    expect(find.byType(ShimmerGroup), findsNothing);
    expect(find.text('FUNNEL'), findsOneWidget);
  });

  testWidgets('no deals in the period reads as empty, not as zeros',
      (tester) async {
    _repo.funnel = const DealFunnel();
    await _show(tester, await _signedIn(_agent));

    expect(find.text('No deals in this period'), findsOneWidget);
    expect(find.text('FUNNEL'), findsNothing);
  });

  testWidgets('a failed load says so and offers a retry', (tester) async {
    _repo.error = Exception('network down');
    await _show(tester, await _signedIn(_agent));
    expect(find.text('Could not load analytics'), findsOneWidget);

    _repo.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('FUNNEL'), findsOneWidget);
  });

  testWidgets('the pipeline card links to analytics', (tester) async {
    var opened = 0;
    await expectNoOverflow(
      tester,
      Scaffold(
        body: PipelineCard(
          pipeline: const PipelineBreakdown(
              leads: 3, negotiation: 2, won: 1, lost: 1, totalValue: 1000000),
          onStageTap: (_) {},
          onOpenAnalytics: () => opened++,
        ),
      ),
      size: const Size(320, 568),
      brightness: Brightness.light,
      textScale: 1.5,
      locale: const Locale('kk'),
    );
    await tester.tap(find.byKey(const ValueKey('pipeline-analytics')));
    expect(opened, 1);
  });

  forEachAcceptanceCase('analytics', (tester, size, brightness, scale) async {
    final auth = await _signedIn(_manager);
    for (final locale in kAcceptanceLocales) {
      _repo.funnel = _funnel;
      await _show(tester, auth,
          size: size, brightness: brightness, scale: scale, locale: locale);
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} loaded');
      _repo.funnel = const DealFunnel();
      await _show(tester, auth,
          size: size,
          brightness: brightness,
          scale: scale,
          locale: Locale(locale.languageCode, 'X'));
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} empty');
    }
  });
}

class _GatedAnalytics extends FakeAnalyticsRepository {
  final Future<DealFunnel> gate;
  _GatedAnalytics(this.gate) : super(const DealFunnel());

  @override
  Future<DealFunnel> getFunnel(
          {required DateTime from, required DateTime to, int? agentId}) =>
      gate;
}
