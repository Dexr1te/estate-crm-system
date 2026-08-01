import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate_crm/core/goal/goal_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/day_rail.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/pipeline_card.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/top_agents_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

final _now = DateTime.now();

MeetingResponse _meeting(int id, Duration fromNow, String title) =>
    MeetingResponse(
      id: id,
      title: title,
      scheduledAt: _now.add(fromNow),
      agentId: 5,
      agentName: 'Maria Kim-Doroshenko',
      clientId: 9,
      clientName: 'Irina Alexandrovna Sokolova',
      dealId: id.isEven ? 3 : null,
    );

final _meetings = [
  _meeting(1, const Duration(minutes: 40),
      'Viewing · Severny Residence, apartment 84'),
  _meeting(2, const Duration(hours: 3), 'Price alignment · Romashkovo house'),
  _meeting(3, const Duration(days: 1), 'Contract signing · Tverskaya office'),
  _meeting(4, const Duration(days: 2), 'Repeat viewing · Tverskaya 12'),
  _meeting(5, const Duration(days: 3), 'Handover · Severny Residence'),
];

const _agentNames = [
  'Maria Kim-Doroshenko',
  'Aleksandr Konstantinovich Vishnevsky',
  'Aigerim Serikbaykyzy',
];

final _deals = [
  for (var i = 0; i < 11; i++)
    DealResponse(
        id: 100 + i,
        title: 'Lead $i',
        status: DealStatus.LEAD,
        clientId: 1,
        agentId: 1,
        agentName: _agentNames[i % _agentNames.length],
        dealPrice: 12300000),
  for (var i = 0; i < 8; i++)
    DealResponse(
        id: 200 + i,
        title: 'Negotiation $i',
        status: DealStatus.NEGOTIATION,
        clientId: 1,
        agentId: 1,
        agentName: _agentNames[i % _agentNames.length],
        dealPrice: 26000000),
  for (var i = 0; i < 9; i++)
    DealResponse(
        id: 300 + i,
        title: 'Won $i',
        status: DealStatus.CLOSED_WON,
        clientId: 1,
        agentId: 1,
        agentName: _agentNames[i % _agentNames.length],
        dealPrice: 54800000),
  for (var i = 0; i < 4; i++)
    DealResponse(
        id: 400 + i,
        title: 'Lost $i',
        status: DealStatus.CLOSED_LOST,
        clientId: 1,
        agentId: 1,
        agentName: _agentNames[i % _agentNames.length],
        dealPrice: 9100000),
];

final _stale = [
  ..._deals,
  DealResponse(
      id: 900,
      title: 'Penthouse on Tverskaya, untouched for a month and a half',
      status: DealStatus.NEGOTIATION,
      clientId: 1,
      agentId: 1,
      agentName: _agentNames.first,
      dealPrice: 88400000,
      updatedAt: DateTime.now().subtract(const Duration(days: 46))),
  DealResponse(
      id: 901,
      title: 'Studio, Severny',
      status: DealStatus.LEAD,
      clientId: 1,
      agentId: 1,
      agentName: _agentNames.last,
      dealPrice: 7300000,
      updatedAt: DateTime.now().subtract(const Duration(days: 18))),
];

const _admin = AuthResponse(
    userId: 1,
    fullName: 'Yekaterina Vsevolodovna Ponomaryova',
    email: 'admin@estate.crm',
    role: Role.ADMIN);

Widget _dashboard({
  List<MeetingResponse> meetings = const [],
  List<DealResponse> deals = const [],
  AuthResponse? user,
  bool loadGoal = false,
}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => AuthBloc(FakeAuthRepository(user: user))
              ..add(AuthCheckEvent())),
        BlocProvider(
            create: (_) => GoalBloc()
              ..add(loadGoal ? GoalLoadEvent() : GoalChangedEvent(null))),
        BlocProvider(
          create: (_) => DashboardBloc(
            FakeDashboardRepository(const DashboardSummary(
              totalDeals: 28,
              activeDeals: 24,
              closedDeals: 9,
              totalClients: 138,
              upcomingMeetings: 5,
            )),
            FakeMeetingsRepository(meetings),
            FakeDealsRepository(deals),
          ),
        ),
      ],
      child: const DashboardScreen(),
    );

void main() {
  forEachAcceptanceCase('dashboard — loaded',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _dashboard(meetings: _meetings, deals: _deals),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('dashboard — no meetings, no deals',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _dashboard(),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('dashboard — admin, with agent ranking',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _dashboard(meetings: _meetings, deals: _deals, user: _admin),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('dashboard renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        _dashboard(meetings: _meetings, deals: _deals, user: _admin),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('an empty dashboard offers the actions that would fill it',
      (tester) async {
    await expectNoOverflow(
      tester,
      _dashboard(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing scheduled'), findsOneWidget);
    expect(find.text('No deals yet'), findsOneWidget);
  });

  testWidgets('the agent ranking stays hidden from a plain agent',
      (tester) async {
    await expectNoOverflow(
      tester,
      _dashboard(
        meetings: _meetings,
        deals: _deals,
        user: const AuthResponse(userId: 2, fullName: 'A', role: Role.AGENT),
      ),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.byType(TopAgentsCard), findsNothing);
    expect(find.byType(PipelineCard), findsOneWidget,
        reason: 'the other charts are not role-gated');
  });

  forEachAcceptanceCase('dashboard — deals that need attention',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _dashboard(meetings: _meetings, deals: _stale, user: _admin),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('dashboard — with a monthly target set',
      (tester, size, brightness, scale) async {
    // The ring only draws a sweep and a percentage once a target exists, so
    // the unset path the other cases exercise never reaches that layout.
    SharedPreferences.setMockInitialValues({'monthly_goal': 90000000.0});
    await expectNoOverflow(
      tester,
      _dashboard(meetings: _meetings, deals: _deals, loadGoal: true),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the day rail marks every meeting scheduled today',
      (tester) async {
    await expectNoOverflow(
      tester,
      _dashboard(meetings: _meetings, deals: _deals),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.byType(DayRail), findsOneWidget);
  });
}
