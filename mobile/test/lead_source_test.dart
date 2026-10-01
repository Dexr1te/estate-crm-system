import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:real_estate_crm/features/analytics/presentation/widgets/lead_sources_card.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/lead_source.dart';
import 'package:real_estate_crm/features/imports/presentation/widgets/import_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_ru.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Where a client came from: a picker on the form, a line on the card, a
/// filter on the list that its export follows, and the analytics breakdown of
/// which channels bring clients and which of them buy.

const _referred = ClientResponse(
  id: 1,
  fullName: 'Aigerim Bekova',
  phone: '+7 916 220-84-11',
  leadSource: LeadSource.REFERRAL,
  leadSourceDetail: 'Dana, the neighbour',
);

const _fromPortal = ClientResponse(
  id: 2,
  fullName: 'Madina Seitkali',
  type: ClientType.SELLER,
  leadSource: LeadSource.PORTAL,
  leadSourceDetail: 'krisha.kz',
);

const _unknown = ClientResponse(id: 3, fullName: 'Timur Aliev');

/// Long and Cyrillic: what a narrow screen at 1.5 has to hold.
const _crowded = ClientResponse(
  id: 4,
  fullName: 'Александра Константиновна Вишневская-Рождественская',
  leadSource: LeadSource.COLD_CALL,
  leadSourceDetail:
      'Обзвон базы собственников Медеуского района по списку от октября',
);

const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

const _breakdown = LeadSourceBreakdown(
  clients: 6,
  won: 2,
  sources: [
    LeadSourceRow(
        source: 'REFERRAL', clients: 3, won: 2, conversionRate: 2 / 3),
    LeadSourceRow(source: 'PORTAL', clients: 2, won: 0, conversionRate: 0),
    LeadSourceRow(source: 'UNKNOWN', clients: 1, won: 0, conversionRate: 0),
  ],
);

late FakeClientsRepository _clients;

Widget _list() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => ClientsBloc(_clients)),
      ],
      child: const ClientsScreen(),
    );

Widget _card(LeadSourceBreakdown breakdown) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [LeadSourcesCard(breakdown: breakdown)],
      ),
    );

Future<void> _pumpRouted(WidgetTester tester, String initial) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final auth = AuthBloc(FakeAuthRepository(user: _manager))
    ..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  final bloc = ClientsBloc(_clients);
  addTearDown(bloc.close);
  await tester.pumpWidget(MultiBlocProvider(
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
              path: '/clients/:id/edit',
              builder: (_, s) => ClientFormScreen(
                  clientId: int.parse(s.pathParameters['id']!))),
          GoRoute(
              path: '/clients/:id',
              builder: (_, s) =>
                  ClientDetailScreen(id: int.parse(s.pathParameters['id']!))),
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  // A focused field keeps scrolling itself back into view; let it go first.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _clients = FakeClientsRepository(
        clients: const [_referred, _fromPortal, _unknown, _crowded]);
    Injector.clientsRepository = _clients;
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  // The rules ---------------------------------------------------------------------------------

  test('a client reads its source, and an unknown one as none', () {
    final c = ClientResponse.fromJson(const {
      'id': 9,
      'leadSource': 'WALK_IN',
      'leadSourceDetail': 'Saw the sign',
    });
    expect(c.leadSource, LeadSource.WALK_IN);
    expect(c.leadSourceDetail, 'Saw the sign');
    expect(
        ClientResponse.fromJson(const {'id': 9, 'leadSource': 'BILLBOARD'})
            .leadSource,
        isNull);
    expect(ClientResponse.fromJson(const {'id': 9}).leadSource, isNull);
    expect(leadSourceFromName('UNKNOWN'), isNull);
    expect(leadSourceFromName('REPEAT'), LeadSource.REPEAT);
  });

  test('the list summary carries the source, and the export narrows by it', () {
    final all = ClientSummary.join(const [_referred, _unknown], const []);
    expect(all.map((c) => c.leadSource), [LeadSource.REFERRAL, null]);

    const filters = ExportFilters(leadSource: 'REFERRAL');
    expect(filters.toQuery(), {'leadSource': 'REFERRAL'});
    expect(filters.isEmpty, isFalse);
    expect(filters, isNot(const ExportFilters()));
  });

  test('an import names the two source columns', () {
    final ru = AppLocalizationsRu();
    expect(importFieldLabel(ru, ImportKind.clients, 'leadSource'),
        'Источник лида');
    expect(importFieldLabel(ru, ImportKind.clients, 'leadSourceDetail'),
        'Источник лида: подробности');
  });

  // The form ----------------------------------------------------------------------------------

  testWidgets('the form sends a picked source with its detail', (tester) async {
    await _pumpRouted(tester, '/clients/new');
    await tester.enterText(find.byType(TextField).first, 'Dana Omarova');
    expect(find.byKey(const ValueKey('lead-source-detail')), findsNothing,
        reason: 'no detail without a source');

    await _tapVisible(
        tester, find.byKey(const ValueKey('lead-source-REFERRAL')));
    await tester.enterText(
        find.byKey(const ValueKey('lead-source-detail')), '  Aigerim  ');
    await _tapVisible(tester, find.text('Create Client'));

    expect(_clients.created.single['leadSource'], 'REFERRAL');
    expect(_clients.created.single['leadSourceDetail'], 'Aigerim');
  });

  testWidgets('a new client with no source says so explicitly', (tester) async {
    await _pumpRouted(tester, '/clients/new');
    await tester.enterText(find.byType(TextField).first, 'Dana Omarova');
    await _tapVisible(tester, find.text('Create Client'));

    final sent = _clients.created.single;
    expect(sent.containsKey('leadSource'), isTrue);
    expect(sent['leadSource'], isNull);
    expect(sent['leadSourceDetail'], isNull);
  });

  testWidgets('editing loads the source, and "Not recorded" clears it',
      (tester) async {
    await _pumpRouted(tester, '/clients/2/edit');
    expect(find.text('krisha.kz'), findsOneWidget);

    await _tapVisible(tester, find.byKey(const ValueKey('lead-source-none')));
    expect(find.byKey(const ValueKey('lead-source-detail')), findsNothing);
    await _tapVisible(tester, find.text('Update Client'));

    expect(_clients.updated.single.$2['leadSource'], isNull);
    expect(_clients.updated.single.$2['leadSourceDetail'], isNull);
    expect(_clients.updated.single.$2.containsKey('leadSource'), isTrue);
  });

  // The card ----------------------------------------------------------------------------------

  testWidgets('the client card names the source and its detail',
      (tester) async {
    await _pumpRouted(tester, '/clients/1');
    expect(find.byKey(const ValueKey('client-detail-lead-source')),
        findsOneWidget);
    expect(find.text('Referral · Dana, the neighbour'), findsOneWidget);
    expect(find.text('REFERRAL'), findsNothing);
  });

  testWidgets('a client with no source has no such line', (tester) async {
    await _pumpRouted(tester, '/clients/3');
    expect(
        find.byKey(const ValueKey('client-detail-lead-source')), findsNothing);
  });

  // The list ----------------------------------------------------------------------------------

  testWidgets('the source filter narrows the list, and the export with it',
      (tester) async {
    await expectNoOverflow(tester, _list(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();
    expect(find.byType(ClientCard), findsNWidgets(4));

    await _tapVisible(
        tester, find.byKey(const ValueKey('clients-filter-source')));
    expect(find.text('Referral · 1'), findsOneWidget);
    expect(find.text('Website · 0'), findsOneWidget);
    await _tapVisible(
        tester, find.byKey(const ValueKey('lead-source-filter-REFERRAL')));

    expect(find.byType(ClientCard), findsOneWidget);
    expect(find.text('Aigerim Bekova'), findsOneWidget);
    expect(find.text('Referral'), findsOneWidget, reason: 'the pill says so');

    await _tapVisible(
        tester, find.byKey(const ValueKey('clients-filter-source')));
    await _tapVisible(
        tester, find.byKey(const ValueKey('lead-source-filter-all')));
    expect(find.byType(ClientCard), findsNWidgets(4));
    expect(find.text('Source'), findsOneWidget);
  });

  // Analytics ---------------------------------------------------------------------------------

  testWidgets('the breakdown shows each source, its clients and its wins',
      (tester) async {
    await expectNoOverflow(tester, _card(_breakdown),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    expect(find.text('WHERE CLIENTS COME FROM'), findsOneWidget);
    expect(find.text('Referral'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2 with a won deal · 67%'), findsOneWidget);
    expect(find.text('Listings portal'), findsOneWidget);
    expect(find.text('0 with a won deal · 0%'), findsNWidgets(2));
    expect(find.text('Not recorded'), findsOneWidget);
    expect(find.text('UNKNOWN'), findsNothing);
  });

  testWidgets('no clients in the period says so', (tester) async {
    await expectNoOverflow(tester, _card(const LeadSourceBreakdown()),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    expect(find.text('No clients added in this period.'), findsOneWidget);
  });

  group('on the analytics screen', () {
    late FakeAnalyticsRepository repo;

    setUp(() {
      AppClock.freeze(DateTime(2026, 9, 25, 15, 30));
      repo = FakeAnalyticsRepository(const DealFunnel(created: 3, won: 1));
      Injector.analyticsRepository = repo;
      Injector.agentsRepository = const FakeAgentsRepository([]);
    });
    tearDown(AppClock.reset);

    Future<void> show(WidgetTester tester) async {
      final auth = AuthBloc(FakeAuthRepository(user: _manager))
        ..add(AuthCheckEvent());
      addTearDown(auth.close);
      await auth.stream.firstWhere((s) => s is AuthAuthenticated);
      await expectNoOverflow(tester,
          BlocProvider.value(value: auth, child: const AnalyticsScreen()),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
    }

    testWidgets('the section sits among the others', (tester) async {
      repo.leadSources = _breakdown;
      await show(tester);
      await tester.scrollUntilVisible(find.text('WHERE CLIENTS COME FROM'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.byType(LeadSourcesCard), findsOneWidget);
    });

    testWidgets('a failed breakdown hides the section and nothing else',
        (tester) async {
      repo.leadSourcesError = Exception('network down');
      await show(tester);
      expect(find.text('FUNNEL'), findsOneWidget);
      expect(find.byType(LeadSourcesCard), findsNothing);
    });

    testWidgets('clients without deals still show where they came from',
        (tester) async {
      repo.funnel = const DealFunnel();
      repo.leadSources = _breakdown;
      await show(tester);
      expect(find.text('No deals in this period'), findsOneWidget);
      expect(find.byType(LeadSourcesCard), findsOneWidget);
    });
  });

  // Layout ------------------------------------------------------------------------------------

  forEachAcceptanceCase('lead source breakdown',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _card(_breakdown),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    final code = locale.languageCode;

    testWidgets('the breakdown renders in $code at 1.5', (tester) async {
      await expectNoOverflow(tester, _card(_breakdown),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
    });

    testWidgets('the list with its source pill renders in $code at 1.5',
        (tester) async {
      await expectNoOverflow(tester, _list(),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the form with a long detail renders in $code at 1.5',
        (tester) async {
      await expectNoOverflow(
          tester,
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
              BlocProvider(create: (_) => ClientsBloc(_clients)),
            ],
            child: const ClientFormScreen(clientId: 4),
          ),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the card with a long source renders in $code at 1.5',
        (tester) async {
      await expectNoOverflow(
          tester,
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
              BlocProvider(create: (_) => ClientsBloc(_clients)),
            ],
            child: const ClientDetailScreen(id: 4),
          ),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
