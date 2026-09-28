import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/data/comparison_tray.dart';
import 'package:real_estate_crm/features/compare/presentation/screens/compare_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

final compareFlats = [
  PropertyResponse(
      id: 1,
      title: 'Abay 10, a flat with a long name for the column head',
      status: PropertyStatus.AVAILABLE,
      city: 'Almaty',
      address: 'Abay 10',
      price: 100000,
      areaSqm: 50,
      rooms: 2,
      floor: 1,
      totalFloors: 9,
      agentName: 'Dana Seitkali',
      createdAt: DateTime(2026, 9, 18)),
  const PropertyResponse(
      id: 2,
      title: 'Satpaev 5',
      status: PropertyStatus.RESERVED,
      price: 120000,
      areaSqm: 80,
      rooms: 3),
  PropertyResponse(
      id: 3,
      title: 'Dostyk 40',
      price: 150000,
      previousPrice: 160000,
      priceChangedAt: DateTime(2026, 9, 3),
      createdAt: DateTime(2026, 8, 29)),
  const PropertyResponse(
      id: 4, title: 'Tole bi 7', price: 90000, areaSqm: 70, rooms: 2),
];

late FakeShareGateway _share;
late FakePropertiesRepository _repo;
String? _openedPath;

void installCompareFakes() {
  AppClock.freeze(DateTime(2026, 9, 28, 12));
  addTearDown(AppClock.reset);
  _share = FakeShareGateway();
  Injector.shareGateway = _share;
  _repo = FakePropertiesRepository(compareFlats);
  _repo.shareLinks[2] =
      const PropertyShareLink(url: 'https://crm.test/l/2', viewCount: 14);
  Injector.propertiesRepository = _repo;
  Injector.comparisonTray = ComparisonTray(scope: () => null);
  Injector.clientsRepository = FakeClientsRepository(matches: [
    PropertyMatch(property: compareFlats[0]),
    PropertyMatch(property: compareFlats[1], overBudget: true),
  ]);
}

Future<void> _pump(WidgetTester tester, String location) async {
  _openedPath = null;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: location, routes: [
    GoRoute(
      path: '/compare',
      builder: (_, s) => CompareScreen(
        ids: [
          for (final id in s.uri.queryParameters['ids']!.split(','))
            int.parse(id)
        ],
        clientId: int.tryParse(s.uri.queryParameters['client'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/properties/:id',
      builder: (_, s) {
        _openedPath = s.uri.path;
        return const Scaffold(body: Text('listing'));
      },
    ),
  ]);
  await tester.pumpWidget(MaterialApp.router(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  ));
  await tester.pumpAndSettle();
}

String _cell(WidgetTester tester, String row, int id) => tester
    .widget<Text>(find.descendant(
        of: find.byKey(ValueKey('compare-cell-$row-$id')),
        matching: find.byType(Text)))
    .data!;

bool _isBest(WidgetTester tester, String row, int id) {
  final text = tester.widget<Text>(find.descendant(
      of: find.byKey(ValueKey('compare-cell-$row-$id')),
      matching: find.byType(Text)));
  final t = AppTokens.of(tester.element(find.byType(CompareScreen)));
  return text.style?.color ==
      StatusPalette.resolve(t, StatusHue.positive).label;
}

void main() {
  setUp(installCompareFakes);

  testWidgets('each row reads the listing, a dash where it is unknown',
      (tester) async {
    await _pump(tester, '/compare?ids=1,2,3');

    expect(_cell(tester, 'price', 1), formatPrice(100000));
    expect(_cell(tester, 'pricePerSqm', 1), formatPrice(2000));
    expect(_cell(tester, 'pricePerSqm', 2), formatPrice(1500));
    expect(_cell(tester, 'pricePerSqm', 3), '—');
    expect(_cell(tester, 'area', 2), '80 m²');
    expect(_cell(tester, 'floor', 1), '1/9 · first floor');
    expect(_cell(tester, 'place', 1), 'Almaty, Abay 10');
    expect(_cell(tester, 'agent', 1), 'Dana Seitkali');
    expect(_cell(tester, 'agent', 2), '—');
    expect(_cell(tester, 'days', 1), '10 days');
    expect(_cell(tester, 'days', 3), '30 days');
    expect(
        _cell(tester, 'priceChange', 3), startsWith('−${formatPrice(10000)}'));
    expect(_cell(tester, 'linkViews', 2), '14');
    expect(_cell(tester, 'linkViews', 1), '—');
    expect(find.byKey(const ValueKey('compare-cell-fit-1')), findsNothing,
        reason: 'no buyer, no fit row');
  });

  testWidgets('the best value in a row is marked, and only there',
      (tester) async {
    await _pump(tester, '/compare?ids=1,2,3');
    expect(_isBest(tester, 'price', 1), isTrue);
    expect(_isBest(tester, 'price', 2), isFalse);
    expect(_isBest(tester, 'pricePerSqm', 2), isTrue);
    expect(_isBest(tester, 'pricePerSqm', 1), isFalse);
    expect(_isBest(tester, 'area', 2), isTrue);
    expect(_isBest(tester, 'rooms', 2), isFalse, reason: 'rooms have no best');
  });

  testWidgets('opened for a buyer, the fit shows', (tester) async {
    await _pump(tester, '/compare?ids=1,2,3&client=9');
    expect(_cell(tester, 'fit', 1), 'Fits requirements');
    expect(_cell(tester, 'fit', 2), 'Over budget');
    expect(_cell(tester, 'fit', 3), 'Outside requirements');
  });

  testWidgets('a column is removed, and one left asks for another',
      (tester) async {
    Injector.comparisonTray
      ..toggle(1)
      ..toggle(3);
    await _pump(tester, '/compare?ids=1,2,3');
    await tester.ensureVisible(find.byKey(const ValueKey('compare-remove-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('compare-remove-3')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('compare-head-3')), findsNothing);
    expect(find.byKey(const ValueKey('compare-head-2')), findsOneWidget);
    expect(Injector.comparisonTray.ids, [1]);

    await tester.tap(find.byKey(const ValueKey('compare-remove-2')));
    await tester.pumpAndSettle();
    expect(find.text('Pick two listings to compare'), findsOneWidget);
  });

  testWidgets('tapping a column head opens that listing', (tester) async {
    await _pump(tester, '/compare?ids=1,2');
    await tester.tap(find.text('Satpaev 5'));
    await tester.pumpAndSettle();
    expect(_openedPath, '/properties/2');
  });

  testWidgets('sending carries the links, or not', (tester) async {
    await _pump(tester, '/compare?ids=1,2');
    await tester.tap(find.byKey(const ValueKey('compare-send')));
    await tester.pumpAndSettle();
    expect(_share.sharedText, contains('https://crm.test/l/2'));
    expect(
        _share.sharedText, contains(FakePropertiesRepository.shareUrlFor(1)));
    expect(_share.sharedText, endsWith('Best price per m²: Satpaev 5'));

    await tester.tap(find.byKey(const ValueKey('compare-links')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('compare-send')));
    await tester.pumpAndSettle();
    expect(_share.calls, 2);
    expect(_share.sharedText, isNot(contains('https://')));
  });
}
