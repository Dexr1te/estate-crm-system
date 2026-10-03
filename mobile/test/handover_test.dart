import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_history_card.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_event.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/handover_state.dart';
import 'package:real_estate_crm/features/teams/presentation/screens/handover_screen.dart';
import 'package:real_estate_crm/features/teams/presentation/screens/manager_console_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Handing an agent's work to a colleague while both stay: the manager picks
/// who takes it and what moves, sees the server's counts for exactly that,
/// confirms, and is told what moved. A client's history says who had it.

const _manager = TeamMemberResponse(
  id: 1,
  fullName: 'Nurlan Bekov',
  email: 'nurlan@almaty.kz',
  role: Role.MANAGER,
  status: UserAccountStatus.active,
  isActive: true,
  isTeamManager: true,
);

const _aigerim = TeamMemberResponse(
  id: 2,
  fullName: 'Aigerim Serikbaykyzy',
  email: 'aigerim@almaty.kz',
  role: Role.AGENT,
  status: UserAccountStatus.active,
  isActive: true,
  isTeamManager: false,
);

const _timur = TeamMemberResponse(
  id: 3,
  fullName: 'Timur Aliev',
  email: 'timur@almaty.kz',
  role: Role.AGENT,
  status: UserAccountStatus.active,
  isActive: true,
  isTeamManager: false,
);

const _invited = TeamMemberResponse(
  id: 4,
  fullName: 'Daniyar Nurlanuly',
  email: 'daniyar@almaty.kz',
  role: Role.AGENT,
  status: UserAccountStatus.pendingInvite,
  isActive: true,
  isTeamManager: false,
);

const _clients = [
  ClientResponse(
      id: 11, fullName: 'Aliya Buyer', phone: '+7 701 555 1234', agentId: 2),
  ClientResponse(id: 12, fullName: 'Bolat Seller', agentId: 2),
  ClientResponse(id: 13, fullName: 'Someone Else', agentId: 3),
];

FakeTeamsRepository _setUp() {
  final teams = FakeTeamsRepository(
    myTeam: const TeamResponse(id: 1, name: 'Almaty Realty', memberCount: 4),
    members: const [_manager, _aigerim, _timur, _invited],
  );
  Injector.teamsRepository = teams;
  Injector.clientsRepository = FakeClientsRepository(clients: _clients);
  return teams;
}

Future<void> _settle() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(WidgetTester tester,
    {Size size = const Size(390, 1100),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, const HandoverScreen(agentId: 2),
      size: size, brightness: brightness, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
}

final _dialogConfirm = find.descendant(
    of: find.byType(Dialog), matching: find.byType(AppFilledButton));

Future<void> _chooseTimur(WidgetTester tester) async {
  await _tap(tester, find.byKey(const Key('handover-target')));
  await _tap(tester, find.text('Timur Aliev').last);
}

void main() {
  group('the bloc', () {
    test('anybody active but the agent can take over; the clients are theirs',
        () async {
      final teams = _setUp();
      final bloc = HandoverBloc(teams, Injector.clientsRepository, fromId: 2)
        ..add(HandoverLoadEvent());
      await _settle();

      expect(bloc.state.status, HandoverStatus.ready);
      expect(bloc.state.from?.fullName, 'Aigerim Serikbaykyzy');
      expect(bloc.state.candidates.map((m) => m.id), [1, 3],
          reason: 'not the agent, not an invite nobody has used');
      expect(bloc.state.clients.map((c) => c.id), [11, 12]);
      expect(bloc.state.selection, isNull, reason: 'nobody to take it yet');
      expect(teams.previews, isEmpty);
      await bloc.close();
    });

    test('each change asks for the counts of exactly that', () async {
      final teams = _setUp();
      final bloc = HandoverBloc(teams, Injector.clientsRepository, fromId: 2)
        ..add(HandoverLoadEvent());
      await _settle();

      bloc.add(HandoverTargetEvent(3));
      await _settle();
      expect(teams.previews.last.toJson(), {
        'fromAgentId': 2,
        'toAgentId': 3,
        'clients': true,
        'listings': true,
        'deals': true,
        'upcoming': true,
      });
      expect(bloc.state.preview?.total, 20);
      expect(bloc.state.canConfirm, isTrue);

      bloc.add(HandoverPartEvent(HandoverPart.listings, false));
      bloc.add(HandoverClientsEvent({11}));
      await _settle();
      expect(teams.previews.last.toJson(), {
        'fromAgentId': 2,
        'toAgentId': 3,
        'clients': false,
        'listings': false,
        'deals': true,
        'upcoming': true,
        'clientIds': [11],
      });
      expect(bloc.state.preview?.clients, 1);

      for (final part in HandoverPart.values) {
        bloc.add(HandoverPartEvent(part, false));
      }
      await _settle();
      expect(bloc.state.selection, isNull);
      expect(bloc.state.preview, isNull);
      expect(bloc.state.canConfirm, isFalse);
      await bloc.close();
    });

    test(
        'a preview that fails keeps the button off; a handover that fails says so',
        () async {
      final teams = _setUp()..previewError = Exception('offline');
      final bloc = HandoverBloc(teams, Injector.clientsRepository, fromId: 2)
        ..add(HandoverLoadEvent());
      await _settle();
      bloc.add(HandoverTargetEvent(3));
      await _settle();
      expect(bloc.state.previewFailure, isNotNull);
      expect(bloc.state.canConfirm, isFalse);

      teams
        ..previewError = null
        ..handOverError = Exception('conflict');
      bloc.add(HandoverTargetEvent(3));
      await _settle();
      bloc.add(HandoverConfirmEvent());
      await _settle();
      expect(bloc.state.outcome, isA<HandoverFailed>());
      expect(bloc.state.result, isNull);
      await bloc.close();
    });

    test('an agent who is not in the agency reads as not found', () async {
      final teams = _setUp();
      final bloc = HandoverBloc(teams, Injector.clientsRepository, fromId: 99)
        ..add(HandoverLoadEvent());
      await _settle();
      expect(bloc.state.status, HandoverStatus.error);
      await bloc.close();
    });
  });

  group('the screen', () {
    testWidgets('pick a colleague, see the counts, confirm, see what moved',
        (tester) async {
      final teams = _setUp();
      await _pumpScreen(tester);

      expect(find.text('Hand over work'), findsWidgets);
      expect(
          find.text('Choose who takes over to see what moves'), findsOneWidget);

      await _chooseTimur(tester);
      expect(find.text('Timur Aliev'), findsOneWidget);
      expect(find.text('20'), findsNothing);
      expect(find.text('4'), findsOneWidget, reason: 'clients');
      expect(find.text('6'), findsOneWidget, reason: 'tasks');

      await _tap(tester, find.byKey(const Key('handover-confirm')));
      expect(find.text('Hand over to Timur Aliev?'), findsOneWidget);
      await _tap(tester, _dialogConfirm);

      expect(teams.handedOver?.toAgentId, 3);
      expect(find.byKey(const Key('handover-result')), findsOneWidget);
      expect(find.text('Handed over to Timur Aliev'), findsOneWidget);
    });

    testWidgets('some clients picked by hand go on their own', (tester) async {
      final teams = _setUp();
      await _pumpScreen(tester);
      await _chooseTimur(tester);

      await _tap(tester, find.byKey(const Key('handover-pick-clients')));
      expect(find.text('Aliya Buyer'), findsOneWidget);
      expect(find.text('Someone Else'), findsNothing,
          reason: "a colleague's client is not this agent's to give");
      await _tap(tester, find.byKey(const ValueKey('handover-client-12')));
      expect(find.text('1 client picked'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('handover-pick-done')));

      expect(teams.previews.last.clientIds, [11]);
      expect(find.text('1 client picked'), findsOneWidget);
    });

    testWidgets('nothing chosen says so and cannot be confirmed',
        (tester) async {
      _setUp();
      await _pumpScreen(tester);
      await _chooseTimur(tester);
      for (final part in HandoverPart.values) {
        await _tap(tester, find.byKey(Key('handover-part-${part.name}')));
      }
      expect(
          find.text('Choose at least one thing to hand over'), findsOneWidget);
      final button = tester
          .widget<AppFilledButton>(find.byKey(const Key('handover-confirm')));
      expect(button.onPressed, isNull);
    });

    forEachAcceptanceCase('hand over work, with the counts',
        (tester, size, brightness, scale) async {
      _setUp();
      await _pumpScreen(tester,
          size: size, brightness: brightness, scale: scale);
      await _chooseTimur(tester);
      expect(tester.takeException(), isNull);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('hand over work in ${locale.languageCode}', (tester) async {
        _setUp();
        await _pumpScreen(tester,
            size: const Size(320, 568),
            brightness: Brightness.dark,
            scale: 1.5,
            locale: locale);
        await _chooseTimur(tester);
        await _tap(tester, find.byKey(const Key('handover-confirm')));
        await _tap(tester, _dialogConfirm);
        expect(find.byKey(const Key('handover-result')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the way in', () {
    testWidgets(
        "an agent's sheet in the console offers to hand over their work",
        (tester) async {
      _setUp();
      await expectNoOverflow(
          tester,
          BlocProvider(
              create: (_) => AuthBloc(FakeAuthRepository(
                  user: const AuthResponse(
                      userId: 1,
                      fullName: 'Nurlan Bekov',
                      role: Role.MANAGER,
                      teamId: 1)))
                ..add(AuthCheckEvent()),
              child: const ManagerConsoleScreen()),
          size: const Size(390, 1400),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();

      await _tap(tester, find.text('Aigerim Serikbaykyzy'));
      expect(find.byKey(const Key('member-hand-over')), findsOneWidget);
      expect(find.text('Hand over work'), findsOneWidget);
      Navigator.of(tester.element(find.byKey(const Key('member-hand-over'))))
          .pop();
      await tester.pumpAndSettle();

      await _tap(tester, find.text('Daniyar Nurlanuly'));
      expect(find.byKey(const Key('member-hand-over')), findsNothing,
          reason: 'an invite nobody has used holds nothing');
    });
  });

  group('the history', () {
    Widget card(List<ClientActivity> activities) => Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClientHistoryCard(
                activities: activities,
                onLog: () {},
                onRetry: () {},
                onDelete: (_) {},
                onEdit: (_) => fail('a handover line is not reworded'),
                canDelete: (_) => true,
              ),
            ],
          ),
        );

    final line = ClientActivity(
      id: 7,
      clientId: 11,
      occurredAt: DateTime(2026, 10, 1, 10),
      authorId: 1,
      authorName: 'Nurlan Bekov',
      handoverFromName: 'Aigerim Serikbaykyzy',
      handoverToName: 'Timur Aliev',
    );

    testWidgets('says who had the client and who has it now', (tester) async {
      await expectNoOverflow(tester, card([line]),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      expect(find.text('Handed over'), findsOneWidget);
      expect(find.text('From Aigerim Serikbaykyzy to Timur Aliev'),
          findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('handover-line-7')));
      await tester.pump();
    });

    testWidgets('a client nobody held says only who has it', (tester) async {
      await expectNoOverflow(
          tester, card([line.copyWith(handoverFromName: '')]),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      expect(find.text('To Timur Aliev'), findsOneWidget);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('the line in ${locale.languageCode}', (tester) async {
        await expectNoOverflow(tester, card([line]),
            size: const Size(320, 568),
            brightness: Brightness.dark,
            textScale: 1.5,
            locale: locale);
      });
    }
  });
}
