import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/duplicate_warning.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The same buyer entered twice.
///
/// Leaving the phone or email field asks whether the agency already has this
/// person, and says so under the field without stopping the save. A manager can
/// then fold the two cards into one from the client's page, after confirming
/// what moves and that the other card goes.

const _target = ClientResponse(
  id: 1,
  fullName: 'Aigerim Bekova',
  phone: '+7 916 220-84-11',
  email: 'aigerim@mail.kz',
  agentName: 'Aigul Bekova',
);

const _source = ClientResponse(
  id: 2,
  fullName: 'Aigerim B.',
  phone: '89162208411',
  agentName: 'Timur Aliev',
);

const _colleagues = ClientDuplicate(
  id: 2,
  fullName: 'Aigerim B.',
  agentId: 9,
  agentName: 'Timur Aliev',
  phone: '89162208411',
  matchedOn: DuplicateMatch.PHONE,
);

const _longOne = ClientDuplicate(
  id: 3,
  fullName: 'Aleksandra Konstantinovna Vishnevskaya-Rozhdestvenskaya',
  agentName: 'Aleksandr Konstantinovich Vishnevsky-Rozhdestvensky',
  email: 'a.vishnevskaya@very-long-agency-domain.kz',
  matchedOn: DuplicateMatch.PHONE_AND_EMAIL,
  visible: false,
);

const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);
const _agent = AuthResponse(
    userId: 5, fullName: 'Aigul Bekova', role: Role.AGENT, teamId: 1);

late FakeClientsRepository _clients;

Widget _warning(List<ClientDuplicate> duplicates) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [DuplicateWarning(duplicates: duplicates, onOpen: (_) {})],
      ),
    );

/// The screens under a real router, for the taps that navigate.
Widget _routed(String initial, AuthBloc auth, ClientsBloc bloc) =>
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider.value(value: bloc),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: initial,
          routes: [
            GoRoute(
                path: '/clients',
                builder: (_, __) => const Scaffold(body: Text('client list'))),
            GoRoute(
                path: '/clients/new',
                builder: (_, __) => const ClientFormScreen()),
            GoRoute(
                path: '/clients/:id',
                builder: (_, s) => s.pathParameters['id'] == '1'
                    ? const ClientDetailScreen(id: 1)
                    : Scaffold(body: Text('client ${s.pathParameters['id']}'))),
          ],
        ),
      ),
    );

Future<ClientsBloc> _pump(WidgetTester tester, String initial,
    {AuthResponse me = _manager}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final auth = AuthBloc(FakeAuthRepository(user: me))..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  final bloc = ClientsBloc(_clients);
  addTearDown(bloc.close);
  await tester.pumpWidget(_routed(initial, auth, bloc));
  await tester.pumpAndSettle();
  return bloc;
}

/// Types into the phone field and leaves it, as someone moving on would.
Future<void> _typePhoneAndLeave(WidgetTester tester, String phone) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(1), phone);
  await tester.tap(fields.at(0));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _clients = FakeClientsRepository(
        clients: const [_target, _source], duplicates: const [_colleagues]);
    Injector.clientsRepository = _clients;
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  forEachAcceptanceCase('duplicate warning',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _warning(const [_colleagues, _longOne]),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('duplicate warning renders in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
          tester, _warning(const [_colleagues, _longOne, _colleagues]),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
    });
  }

  // The form -----------------------------------------------------------------

  testWidgets('leaving the phone field names the colleague who has this buyer',
      (tester) async {
    await _pump(tester, '/clients/new', me: _agent);
    expect(find.byType(DuplicateWarning), findsNothing);

    await _typePhoneAndLeave(tester, '+7 916 220 84 11');

    expect(_clients.duplicateQueries.single, ('+7 916 220 84 11', '', null));
    expect(find.text('Already in the agency: Aigerim B. (agent Timur Aliev)'),
        findsOneWidget);
    expect(find.text('Same phone'), findsOneWidget);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('client 2'), findsOneWidget);
  });

  testWidgets('the warning does not stop the save', (tester) async {
    await _pump(tester, '/clients/new', me: _agent);
    await tester.enterText(find.byType(TextField).at(0), 'Aigerim');
    await _typePhoneAndLeave(tester, '89162208411');
    expect(find.byType(DuplicateWarning), findsOneWidget);

    final create = find.text('Create Client');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();

    expect(_clients.created.single['phone'], '89162208411');
    expect(find.text('client list'), findsOneWidget);
  });

  testWidgets('leaving the field again with nothing changed asks only once',
      (tester) async {
    await _pump(tester, '/clients/new', me: _agent);
    await _typePhoneAndLeave(tester, '89162208411');
    await tester.tap(find.byType(TextField).at(1));
    await tester.tap(find.byType(TextField).at(0));
    await tester.pump(const Duration(milliseconds: 400));

    expect(_clients.duplicateQueries, hasLength(1));
  });

  testWidgets('a card the agent may not open is named without an Open',
      (tester) async {
    _clients = FakeClientsRepository(duplicates: const [_longOne]);
    Injector.clientsRepository = _clients;
    await _pump(tester, '/clients/new', me: _agent);
    await _typePhoneAndLeave(tester, '89162208411');

    expect(find.byType(DuplicateWarning), findsOneWidget);
    expect(find.text('Same phone and email'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
  });

  // The merge ----------------------------------------------------------------

  testWidgets('an agent is not offered the merge', (tester) async {
    await _pump(tester, '/clients/1', me: _agent);
    expect(find.byTooltip('Merge with another card'), findsNothing);
  });

  testWidgets('a manager picks the duplicate, confirms, and stays on the card',
      (tester) async {
    await _pump(tester, '/clients/1');

    await tester.tap(find.byTooltip('Merge with another card'));
    await tester.pumpAndSettle();
    expect(find.text('Which card is the same person?'), findsOneWidget);
    expect(_clients.duplicateQueries.single,
        ('+7 916 220-84-11', 'aigerim@mail.kz', 1));

    await tester.tap(find.text('Aigerim B.'));
    await tester.pumpAndSettle();
    expect(find.text('Merge into this card?'), findsOneWidget);
    expect(find.textContaining('The card Aigerim B. is then deleted'),
        findsOneWidget);

    await tester.tap(find.text('Merge'));
    await tester.pumpAndSettle();

    expect(_clients.merges.single, (1, 2));
    expect(find.text('Cards merged'), findsOneWidget);
    expect(find.byType(ClientDetailScreen), findsOneWidget);
  });

  testWidgets('cancelling the confirmation merges nothing', (tester) async {
    await _pump(tester, '/clients/1');
    await tester.tap(find.byTooltip('Merge with another card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aigerim B.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_clients.merges, isEmpty);
  });

  testWidgets('with no duplicate detected, every other client is offered',
      (tester) async {
    _clients = FakeClientsRepository(clients: const [_target, _source]);
    Injector.clientsRepository = _clients;
    await _pump(tester, '/clients/1');
    final onPage = find.text('Aigerim Bekova').evaluate().length;

    await tester.tap(find.byTooltip('Merge with another card'));
    await tester.pumpAndSettle();

    expect(find.text('Aigerim B.'), findsOneWidget);
    expect(find.text('Aigerim Bekova'), findsNWidgets(onPage),
        reason: 'the card itself is not a candidate');
  });
}
