import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_price_history.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// A listing's price history.
///
/// A reduction used to overwrite the old figure without a trace. Now the
/// listing shows what it was, the card lists every change, and a cut made
/// lately is flagged wherever the listing is named — a buyer who passed at the
/// old price may well not pass at the new one.

final _now = DateTime(2026, 9, 25, 12);

PropertyResponse _listing({
  double price = 46500000,
  double? previousPrice = 50000000,
  Duration? changedAgo = const Duration(days: 4),
}) =>
    PropertyResponse(
      id: 1,
      title: 'Dostyk Residence, apartment 210 with a view of the mountains',
      address: 'Dostyk avenue 210, Medeu district',
      city: 'Almaty',
      price: price,
      rooms: 3,
      areaSqm: 94,
      floor: 12,
      totalFloors: 24,
      previousPrice: previousPrice,
      priceChangedAt: changedAgo == null ? null : _now.subtract(changedAgo),
    );

final _history = [
  PropertyPriceChange(
    id: 3,
    propertyId: 1,
    oldPrice: 50000000,
    newPrice: 46500000,
    changedById: 4,
    changedByName: 'Aigerim Serikbaykyzy-Nurmukhambetova',
    changedAt: _now.subtract(const Duration(days: 4)),
  ),
  PropertyPriceChange(
    id: 2,
    propertyId: 1,
    oldPrice: 48000000,
    newPrice: 50000000,
    changedAt: _now.subtract(const Duration(days: 40)),
  ),
];

late FakePropertiesRepository _repository;

void _install({
  PropertyResponse? listing,
  List<PropertyPriceChange> history = const [],
}) {
  AppClock.freeze(_now);
  addTearDown(AppClock.reset);
  final l = listing ?? _listing();
  _repository = FakePropertiesRepository([l], priceHistory: history);
  Injector.propertiesRepository = _repository;
  Injector.clientsRepository = FakeClientsRepository(
    clients: const [
      ClientResponse(
          id: 1,
          fullName: 'Irina Sokolova',
          type: ClientType.BUYER,
          budgetMax: 48000000),
    ],
    matches: [PropertyMatch(property: l)],
  );
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => PropertiesBloc(_repository)),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
      ],
      child: child,
    );

Future<void> _show(WidgetTester tester, Widget screen,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, _wrap(screen),
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  group('the 30-day rule', () {
    test('a cut made four days ago is recent', () {
      expect(isRecentPriceReduction(_listing(), _now), isTrue);
    });

    test('a cut made exactly thirty days ago still counts', () {
      expect(
          isRecentPriceReduction(
              _listing(changedAgo: const Duration(days: 30)), _now),
          isTrue);
    });

    test('a cut made thirty-one days ago is old news', () {
      expect(
          isRecentPriceReduction(
              _listing(changedAgo: const Duration(days: 31)), _now),
          isFalse);
    });

    test('a rise is not a reduction, however recent', () {
      expect(
          isRecentPriceReduction(
              _listing(price: 52000000, previousPrice: 50000000), _now),
          isFalse);
    });

    test('a listing whose price never changed is not flagged', () {
      expect(
          isRecentPriceReduction(
              _listing(previousPrice: null, changedAgo: null), _now),
          isFalse);
    });
  });

  group('the percentage', () {
    test('a cut reads with a minus sign', () {
      expect(formatPriceChangePercent(50000000, 46500000), '−7%');
    });

    test('a rise reads with a plus sign and one decimal', () {
      expect(formatPriceChangePercent(48000000, 50000000), '+4.2%');
    });

    test('the decimal separator follows the language', () {
      expect(formatPriceChangePercent(48000000, 50000000, 'ru'), '+4,2%');
    });
  });

  testWidgets('the detail shows the old price struck through and the history',
      (tester) async {
    _install(history: _history);
    await _show(tester, const PropertyDetailScreen(id: 1));

    final was = tester.widget<Text>(find.text(r'$50.0M').first);
    expect(was.style?.decoration, TextDecoration.lineThrough);
    expect(find.text('PRICE HISTORY'), findsOneWidget);
    expect(find.text(r'$50.0M → $46.5M'), findsOneWidget);
    expect(find.text('−7%'), findsOneWidget);
    expect(find.textContaining('Aigerim Serikbaykyzy'), findsOneWidget);
    expect(find.text(r'$48.0M → $50.0M'), findsOneWidget);
  });

  testWidgets('a listing whose price never moved has no history card',
      (tester) async {
    _install(listing: _listing(previousPrice: null, changedAgo: null));
    await _show(tester, const PropertyDetailScreen(id: 1));

    expect(find.text('PRICE HISTORY'), findsNothing);
    expect(
        find.byWidgetPredicate((w) =>
            w is Text && w.style?.decoration == TextDecoration.lineThrough),
        findsNothing);
  });

  testWidgets('the list flags a recent cut', (tester) async {
    _install();
    await _show(tester, const PropertiesScreen());

    expect(find.byType(PriceReducedChip), findsOneWidget);
  });

  testWidgets('the list stops flagging a cut after thirty days',
      (tester) async {
    _install(listing: _listing(changedAgo: const Duration(days: 31)));
    await _show(tester, const PropertiesScreen());

    expect(find.byType(PriceReducedChip), findsNothing);
  });

  testWidgets('a buyer\'s matches flag a listing that has come down',
      (tester) async {
    _install();
    await _show(tester, const ClientDetailScreen(id: 1));

    expect(find.byType(PriceReducedChip), findsOneWidget);
  });

  forEachAcceptanceCase('property detail with a price history',
      (tester, size, brightness, scale) async {
    _install(history: _history);
    await _show(tester, const PropertyDetailScreen(id: 1),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('properties list with a reduced listing',
      (tester, size, brightness, scale) async {
    _install();
    await _show(tester, const PropertiesScreen(),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('buyer matches with a reduced listing',
      (tester, size, brightness, scale) async {
    _install();
    await _show(tester, const ClientDetailScreen(id: 1),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('price history renders in ${locale.languageCode}',
        (tester) async {
      _install(history: _history);
      for (final screen in [
        const PropertiesScreen(),
        const PropertyDetailScreen(id: 1),
        const ClientDetailScreen(id: 1),
      ]) {
        await _show(tester, screen,
            size: const Size(320, 568),
            brightness: Brightness.dark,
            textScale: 1.5,
            locale: locale);
      }
    });
  }
}
