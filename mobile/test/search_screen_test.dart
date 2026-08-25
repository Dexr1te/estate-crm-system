import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_text_scaling.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/search/data/repositories/search_repository_impl.dart';
import 'package:real_estate_crm/features/search/presentation/screens/search_screen.dart';
import 'package:real_estate_crm/features/search/presentation/widgets/search_result_tile.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _clients = [
  ClientResponse(
    id: 1,
    fullName: 'Айгерим Нурланова',
    phone: '+7 701 111 22 33',
    email: 'aigerim@example.kz',
  ),
  ClientResponse(id: 2, fullName: 'Пётр Смирнов', phone: '+7 777 000 11 22'),
];

const _properties = [
  PropertyResponse(
    id: 10,
    title: 'ЖК Айгерим, квартира 12 — a long listing title for wrapping',
    address: 'ул. Абая 10',
    city: 'Астана',
    price: 24000000,
  ),
  PropertyResponse(
    id: 11,
    title: 'Дом в Ромашково',
    address: 'Ромашково, 4',
    price: 54800000,
    status: PropertyStatus.SOLD,
  ),
];

const _deals = [
  DealResponse(
    id: 20,
    title: 'Айгерим — двухкомнатная',
    clientId: 1,
    clientName: 'Айгерим Нурланова',
    agentId: 5,
    agentName: 'Нурлан Беков',
    dealPrice: 24000000,
  ),
  DealResponse(
    id: 21,
    title: 'Офис, Тверская 12',
    clientId: 2,
    clientName: 'Пётр Смирнов',
    agentId: 5,
    dealPrice: 54800000,
  ),
];

/// Counts the round trips global search makes, so a test can prove which
/// keystrokes never left the device.
class _CountingClients extends FakeClientsRepository {
  _CountingClients() : super(clients: _clients);

  int queries = 0;

  @override
  Future<List<ClientResponse>> getClients({
    ClientType? type,
    int? agentId,
    String? search,
  }) {
    queries++;
    return super.getClients(type: type, agentId: agentId, search: search);
  }
}

late _CountingClients _clientsRepo;

void _installFakes() {
  _clientsRepo = _CountingClients();
  Injector.clientsRepository = _clientsRepo;
  Injector.propertiesRepository = FakePropertiesRepository(_properties);
  Injector.dealsRepository = FakeDealsRepository(_deals);
}

/// Types [query] and lets the debounce expire and the three answers land.
Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump(const Duration(milliseconds: 400));
  // Settling here would spin forever on the shimmer, so the frames the fakes
  // need are pumped by hand.
  await tester.pump();
  await tester.pump();
}

/// The screen under a real router, for the taps that navigate.
Widget _routedApp() => MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(
              path: '/clients/:id', builder: (_, s) => _Stub('client ${s.id}')),
          GoRoute(
              path: '/properties/:id',
              builder: (_, s) => _Stub('property ${s.id}')),
          GoRoute(path: '/deals/:id', builder: (_, s) => _Stub('deal ${s.id}')),
        ],
      ),
      builder: (context, child) => MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: AppTextScaling(child: child ?? const SizedBox.shrink()),
      ),
    );

extension on GoRouterState {
  String get id => pathParameters['id']!;
}

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _installFakes();
  });

  forEachAcceptanceCase('search results',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await _search(tester, 'айгер');
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('search renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        const SearchScreen(),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.3,
        locale: locale,
      );
      await _search(tester, 'айгер');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('one query answers for clients, listings and deals at once',
      (tester) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _search(tester, 'айгер');

    expect(find.byType(ClientResultTile), findsOneWidget);
    expect(find.byType(PropertyResultTile), findsOneWidget);
    expect(find.byType(DealResultTile), findsOneWidget);

    // The two rows that do not match are not on screen.
    expect(find.text('Пётр Смирнов'), findsNothing);
    expect(find.text('Дом в Ромашково'), findsNothing);
  });

  testWidgets('a client is found by phone number', (tester) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _search(tester, '777 000');

    expect(find.text('Пётр Смирнов'), findsOneWidget);
    expect(find.byType(ClientResultTile), findsOneWidget);
  });

  testWidgets('a deal is found by its id', (tester) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _search(tester, '21');

    expect(find.text('Офис, Тверская 12'), findsOneWidget);
  });

  testWidgets('a query too short to mean anything is never sent',
      (tester) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _search(tester, 'а');

    expect(_clientsRepo.queries, 0);
    expect(find.byType(ClientResultTile), findsNothing);
  });

  testWidgets('typing a name costs one request, not one per letter',
      (tester) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );

    for (final prefix in ['ай', 'айг', 'айге', 'айгер']) {
      await tester.enterText(find.byType(TextField), prefix);
      await tester.pump(const Duration(milliseconds: 80));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump();

    expect(_clientsRepo.queries, 1);
  });

  testWidgets('a query that matches nothing says so', (tester) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _search(tester, 'zzzzz');

    expect(find.text('Nothing found'), findsOneWidget);
  });

  testWidgets('emptying the field puts the results away', (tester) async {
    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await _search(tester, 'айгер');
    expect(find.byType(ClientResultTile), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(find.byType(ClientResultTile), findsNothing);
    expect(find.text('Search everything'), findsOneWidget);
  });

  testWidgets('a remembered query is offered back and re-runs on tap',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'recent_searches': ['айгер'],
    });

    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pump();

    final pill = find.text('айгер');
    expect(pill, findsOneWidget);

    await tester.tap(pill);
    await tester.pump();
    await tester.pump();

    expect(find.byType(ClientResultTile), findsOneWidget);
  });

  testWidgets('a field filled from a recent query can be emptied again',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'recent_searches': ['айгер'],
    });

    await expectNoOverflow(
      tester,
      const SearchScreen(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pump();
    await tester.tap(find.text('айгер'));
    await tester.pump();
    await tester.pump();

    final clear = find.byIcon(Icons.close_rounded);
    expect(clear, findsOneWidget,
        reason: 'the field has a query in it, so there has to be a way out of '
            'it that is not deleting five characters by hand');

    await tester.tap(clear);
    await tester.pump();

    expect(find.byType(ClientResultTile), findsNothing);
    // The field is empty again, so the query is back to being a suggestion.
    expect(find.text('айгер'), findsOneWidget);
  });

  testWidgets('opening a result navigates and remembers the query',
      (tester) async {
    await tester.pumpWidget(_routedApp());
    await tester.pump();
    await _search(tester, 'айгер');

    await tester.tap(find.byType(DealResultTile));
    await tester.pumpAndSettle();

    expect(find.text('deal 20'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('recent_searches'), ['айгер']);
  });

  group('dealMatches', () {
    const deal = DealResponse(
      id: 7,
      title: 'Айгерим — двухкомнатная',
      clientId: 1,
      clientName: 'Айгерим Нурланова',
      agentId: 5,
      agentName: 'Нурлан Беков',
      propertyTitle: 'ЖК Астана Тауэр',
    );

    test('matches the title, the people and the listing, case-insensitively',
        () {
      expect(dealMatches(deal, 'ДВУХКОМ'), isTrue);
      expect(dealMatches(deal, 'нурланова'), isTrue);
      expect(dealMatches(deal, 'беков'), isTrue);
      expect(dealMatches(deal, 'тауэр'), isTrue);
      expect(dealMatches(deal, 'ромашково'), isFalse);
    });

    test('matches the id whole, with or without the hash', () {
      expect(dealMatches(deal, '7'), isTrue);
      expect(dealMatches(deal, '#7'), isTrue);
      expect(dealMatches(deal, '77'), isFalse);
    });

    test('an empty query matches nothing rather than everything', () {
      expect(dealMatches(deal, ''), isFalse);
      expect(dealMatches(deal, '   '), isFalse);
    });
  });
}
