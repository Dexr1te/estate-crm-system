import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// What an agent sees once a buyer's requirements are written down.
///
/// The rules of the match are the backend's and are tested there. What matters
/// here is that the three states read differently — no requirements yet, nothing
/// that fits, and matches — because they call for different moves: the first is
/// the agent's, the second is the market's.

const _buyerWithRequirements = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  type: ClientType.BUYER,
  wantedCity: 'Almaty',
  wantedType: PropertyType.APARTMENT,
  budgetMax: 30000000,
  minRooms: 2,
  minAreaSqm: 55,
);

const _buyerWithNothingStated = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  type: ClientType.BUYER,
);

const _seller = ClientResponse(
  id: 1,
  fullName: 'Aleksandr Konstantinovich Vishnevsky',
  type: ClientType.SELLER,
);

final _matches = [
  const PropertyMatch(
    property: PropertyResponse(
      id: 7,
      title: 'Severny Residence, apartment 84',
      address: 'Severny Residence 12',
      city: 'Almaty',
      price: 28000000,
      rooms: 3,
      areaSqm: 62,
    ),
  ),
  const PropertyMatch(
    property: PropertyResponse(
      id: 8,
      title: 'Tverskaya 12, apartment 5',
      address: 'Tverskaya 12',
      city: 'Almaty',
      price: 31500000,
      rooms: 2,
      areaSqm: 58,
    ),
    overBudget: true,
  ),
];

final _interested = [
  const ClientMatch(client: _buyerWithRequirements),
  const ClientMatch(
    client: ClientResponse(
      id: 2,
      fullName: 'Aigerim Serikbaykyzy',
      phone: '+7 701 000-11-22',
      type: ClientType.BUYER,
      budgetMax: 27000000,
    ),
    overBudget: true,
  ),
];

const _listing = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
  areaSqm: 62,
);

void _installFakes({
  ClientResponse client = _buyerWithRequirements,
  List<PropertyMatch> matches = const [],
  List<ClientMatch> interested = const [],
}) {
  Injector.clientsRepository =
      FakeClientsRepository(clients: [client], matches: matches);
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.propertiesRepository =
      FakePropertiesRepository(const [_listing], interested: interested);
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(const []))),
      ],
      child: child,
    );

Future<void> _open(WidgetTester tester, Widget screen,
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
  testWidgets('a buyer with requirements lists what fits, marking the dear one',
      (tester) async {
    _installFakes(matches: _matches);

    await _open(tester, const ClientDetailScreen(id: 1));

    expect(find.text('MATCHING LISTINGS'), findsOneWidget);
    expect(find.text('Severny Residence, apartment 84'), findsOneWidget);
    expect(find.text('Tverskaya 12, apartment 5'), findsOneWidget);
    expect(find.text('Over budget'), findsOneWidget,
        reason: 'the one above the ceiling is shown, and shown as such');
    expect(find.text('2'), findsWidgets,
        reason: 'the count sits in the header');
  });

  testWidgets('requirements with nothing to answer them say so',
      (tester) async {
    _installFakes(matches: const []);

    await _open(tester, const ClientDetailScreen(id: 1));

    expect(find.text('Nothing on the books fits yet'), findsOneWidget);
  });

  testWidgets('a buyer who has stated nothing is asked, not told',
      (tester) async {
    _installFakes(client: _buyerWithNothingStated);

    await _open(tester, const ClientDetailScreen(id: 1));

    expect(
        find.text(
            'Say what this buyer is looking for and matching listings appear here'),
        findsOneWidget,
        reason: 'an empty wish list is the agent to fill in, not a dead end');
    expect(find.text('Nothing on the books fits yet'), findsNothing);
  });

  testWidgets('a seller has no matching section at all', (tester) async {
    _installFakes(client: _seller, matches: _matches);

    await _open(tester, const ClientDetailScreen(id: 1));

    expect(find.text('MATCHING LISTINGS'), findsNothing);
  });

  testWidgets('a listing names the buyers it answers', (tester) async {
    _installFakes(interested: _interested);

    await _open(tester, const PropertyDetailScreen(id: 7));

    expect(find.text('BUYERS LOOKING FOR THIS'), findsOneWidget);
    expect(find.text('Irina Alexandrovna Sokolova'), findsOneWidget);
    expect(find.text('Aigerim Serikbaykyzy'), findsOneWidget);
    expect(find.text('Over budget'), findsOneWidget);
  });

  testWidgets('a listing nobody asked for says that plainly', (tester) async {
    _installFakes(interested: const []);

    await _open(tester, const PropertyDetailScreen(id: 7));

    expect(find.text('No buyer has asked for anything like this yet'),
        findsOneWidget);
  });

  testWidgets(
      'the form offers requirements to a buyer and hides them for a seller',
      (tester) async {
    _installFakes();

    await _open(tester, const ClientFormScreen());

    expect(find.text('LOOKING FOR'), findsOneWidget);
    expect(find.text('Budget to'), findsOneWidget);

    await tester.tap(find.text('Seller'));
    await tester.pumpAndSettle();

    expect(find.text('LOOKING FOR'), findsNothing,
        reason: 'a seller has no wish list, so the fields have no business '
            'standing there collecting figures nobody will read');
  });

  testWidgets('an edited buyer arrives with their requirements filled in',
      (tester) async {
    _installFakes();

    await _open(tester, const ClientFormScreen(clientId: 1));

    expect(find.text('Almaty'), findsWidgets);
    expect(find.text('30000000'), findsOneWidget,
        reason: 'the ceiling comes back as a plain figure, not 3.0E7');
    expect(find.text('2'), findsWidgets);
  });

  forEachAcceptanceCase('client detail with matches',
      (tester, size, brightness, scale) async {
    _installFakes(matches: _matches);
    await _open(tester, const ClientDetailScreen(id: 1),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('property detail with interested buyers',
      (tester, size, brightness, scale) async {
    _installFakes(interested: _interested);
    await _open(tester, const PropertyDetailScreen(id: 7),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the requirements form renders in ${locale.languageCode}',
        (tester) async {
      _installFakes();
      await _open(tester, const ClientFormScreen(clientId: 1),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale);
    });
  }
}
