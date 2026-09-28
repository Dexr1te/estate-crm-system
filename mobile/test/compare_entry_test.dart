import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/compare/data/comparison_tray.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

/// Every way into the comparison lands on `/compare` with the right ids.

final _flats = [
  for (var i = 1; i <= 5; i++)
    PropertyResponse(
        id: i, title: 'Flat $i', price: 100000.0 * i, areaSqm: 40.0 + i),
];

const _buyer = ClientResponse(
    id: 9, fullName: 'Aigerim', type: ClientType.BUYER, wantedCity: 'Almaty');

Uri? _opened;

Future<void> _pumpRouted(
    WidgetTester tester, String initial, GoRoute home) async {
  _opened = null;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: initial, routes: [
    home,
    GoRoute(
      path: '/compare',
      builder: (_, s) {
        _opened = s.uri;
        return const Scaffold(body: Text('comparison'));
      },
    ),
  ]);
  await tester.pumpWidget(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
      BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
      BlocProvider(
          create: (_) => PropertiesBloc(FakePropertiesRepository(_flats))),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  ));
  await tester.pumpAndSettle();
}

Finder _card(int id) => find.text('Flat $id');

void main() {
  setUp(() {
    Injector.propertiesRepository = FakePropertiesRepository(_flats);
    Injector.comparisonTray = ComparisonTray(scope: () => null);
    Injector.clientsRepository = FakeClientsRepository(
        clients: const [_buyer],
        matches: [for (final f in _flats) PropertyMatch(property: f)]);
  });

  group('picking on the properties list', () {
    final home = GoRoute(
        path: '/properties', builder: (_, __) => const PropertiesScreen());

    testWidgets('two picked, the bar opens the comparison of those two',
        (tester) async {
      await _pumpRouted(tester, '/properties', home);
      expect(find.byKey(const ValueKey('compare-bar')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('properties-compare')));
      await tester.pumpAndSettle();
      expect(find.text('Pick two to four listings'), findsOneWidget);

      await tester.tap(_card(3));
      await tester.pump();
      expect(find.byKey(const ValueKey('compare-open')), findsNothing,
          reason: 'one listing is nothing to compare');
      await tester.tap(_card(1));
      await tester.pump();

      await tester.tap(find.text('Compare (2)'));
      await tester.pumpAndSettle();
      expect(find.text('comparison'), findsOneWidget);
      expect(_opened?.queryParameters, {'ids': '3,1'});
    });

    testWidgets('a fifth is refused with a reason', (tester) async {
      await _pumpRouted(tester, '/properties', home);
      await tester.tap(find.byKey(const ValueKey('properties-compare')));
      await tester.pumpAndSettle();
      for (var id = 1; id <= 5; id++) {
        await tester.ensureVisible(_card(id));
        await tester.tap(_card(id));
        await tester.pump();
      }
      expect(find.text('Compare (4)'), findsOneWidget);
      expect(find.textContaining('Up to 4 listings'), findsOneWidget);
    });

    testWidgets('leaving compare mode clears the picks', (tester) async {
      await _pumpRouted(tester, '/properties', home);
      final toggle = find.byKey(const ValueKey('properties-compare'));
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await tester.tap(_card(1));
      await tester.tap(_card(2));
      await tester.pump();
      expect(find.text('Compare (2)'), findsOneWidget);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('compare-bar')), findsNothing);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.text('Compare (2)'), findsNothing);
      expect(find.text('Pick two to four listings'), findsOneWidget);
    });

    testWidgets('the tray shows under the list once it holds two',
        (tester) async {
      Injector.comparisonTray.toggle(4);
      await _pumpRouted(tester, '/properties', home);
      expect(find.byKey(const ValueKey('compare-tray-bar')), findsNothing);

      Injector.comparisonTray.toggle(2);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('compare-tray-bar-open')));
      await tester.pumpAndSettle();
      expect(_opened?.queryParameters, {'ids': '4,2'});
    });
  });

  group('from a buyer', () {
    final home = GoRoute(
        path: '/clients/:id',
        builder: (_, s) =>
            ClientDetailScreen(id: int.parse(s.pathParameters['id']!)));

    testWidgets('the matches card compares the top matches for the buyer',
        (tester) async {
      await _pumpRouted(tester, '/clients/9', home);
      final compare = find.byKey(const ValueKey('matches-compare'));
      await tester.scrollUntilVisible(compare, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(compare);
      await tester.pumpAndSettle();
      expect(_opened?.queryParameters, {'ids': '1,2,3,4', 'client': '9'});
    });

    testWidgets('the send sheet compares what is ticked', (tester) async {
      await _pumpRouted(tester, '/clients/9', home);
      final send = find.text('Send listings');
      await tester.scrollUntilVisible(send, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(send);
      await tester.pumpAndSettle();

      final compare = find.byKey(const ValueKey('send-compare'));
      await tester.ensureVisible(compare);
      await tester.tap(compare);
      await tester.pumpAndSettle();
      expect(_opened, isNull, reason: 'five are ticked; four is the limit');
      expect(find.textContaining('Up to 4 listings'), findsOneWidget);

      for (final id in [2, 4, 5]) {
        final row =
            find.descendant(of: find.byType(BottomSheet), matching: _card(id));
        await tester.ensureVisible(row);
        await tester.tap(row);
        await tester.pump();
      }
      await tester.ensureVisible(compare);
      await tester.tap(compare);
      await tester.pumpAndSettle();
      expect(_opened?.queryParameters, {'ids': '1,3', 'client': '9'});
    });
  });

  testWidgets('a listing page adds to the tray, and the tray opens it',
      (tester) async {
    Injector.comparisonTray.toggle(5);
    await _pumpRouted(
        tester,
        '/properties/2',
        GoRoute(
            path: '/properties/:id',
            builder: (_, s) =>
                PropertyDetailScreen(id: int.parse(s.pathParameters['id']!))));
    final toggle = find.byKey(const ValueKey('compare-tray-toggle'));
    await tester.scrollUntilVisible(toggle, 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Add to comparison'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(Injector.comparisonTray.ids, [5, 2]);
    expect(find.text('Remove from comparison'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('compare-tray-open')));
    await tester.pumpAndSettle();
    expect(_opened?.queryParameters, {'ids': '5,2'});
  });
}
