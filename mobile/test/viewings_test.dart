import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Booking a showing, and the listing remembering it.
///
/// The point of the feature is that neither end has to be retyped: a match
/// opens the form with the buyer and the flat already in it, and afterwards the
/// listing can say who has seen it.

const _listing = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
  areaSqm: 62,
);

const _buyer = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  type: ClientType.BUYER,
  wantedCity: 'Almaty',
  budgetMax: 30000000,
);

final _viewings = [
  MeetingResponse(
    id: 31,
    title: 'Viewing',
    scheduledAt: DateTime(2026, 3, 14, 11),
    agentId: 5,
    agentName: 'Maria Kim-Doroshenko',
    clientId: 1,
    clientName: 'Irina Alexandrovna Sokolova',
    propertyId: 7,
    propertyTitle: 'Severny Residence, apartment 84',
    propertyAddress: 'Severny Residence 12',
  ),
  MeetingResponse(
    id: 30,
    title: 'Viewing',
    scheduledAt: DateTime(2026, 3, 9, 16),
    completed: true,
    agentId: 5,
    agentName: 'Maria Kim-Doroshenko',
    clientId: 2,
    clientName: 'Aigerim Serikbaykyzy',
    propertyId: 7,
  ),
];

void _installFakes({List<MeetingResponse> viewings = const []}) {
  Injector.clientsRepository = FakeClientsRepository(
      clients: const [_buyer],
      matches: const [PropertyMatch(property: _listing)]);
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.propertiesRepository =
      FakePropertiesRepository(const [_listing], viewings: viewings);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(const []))),
        BlocProvider(
            create: (_) => MeetingsBloc(FakeMeetingsRepository(const []))),
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
  testWidgets('a match offers to be shown, not only read', (tester) async {
    _installFakes();

    await _open(tester, const ClientDetailScreen(id: 1));

    expect(find.text('Schedule a viewing'), findsOneWidget);
  });

  testWidgets('the form opens knowing the buyer and the flat', (tester) async {
    _installFakes();

    await _open(tester,
        const MeetingFormScreen(initialClientId: 1, initialPropertyId: 7));

    expect(find.text('Irina Alexandrovna Sokolova'), findsOneWidget,
        reason: 'the buyer came in on the route and must not be picked again');
    expect(find.text('Severny Residence, apartment 84'), findsOneWidget);
    expect(find.text('Severny Residence 12'), findsWidgets,
        reason: 'the address fills the location, which is where a viewing '
            'happens');
  });

  testWidgets('a plain new meeting picks nothing for you', (tester) async {
    _installFakes();

    await _open(tester, const MeetingFormScreen());

    expect(find.text('Not selected'), findsWidgets);
  });

  testWidgets('a listing lists who has seen it', (tester) async {
    _installFakes(viewings: _viewings);

    await _open(tester, const PropertyDetailScreen(id: 7));

    expect(find.text('VIEWINGS'), findsOneWidget);
    expect(find.text('Irina Alexandrovna Sokolova'), findsWidgets);
    expect(find.text('Aigerim Serikbaykyzy'), findsOneWidget);
  });

  testWidgets('a listing nobody has seen says so', (tester) async {
    _installFakes();

    await _open(tester, const PropertyDetailScreen(id: 7));

    expect(find.text('This listing has not been shown yet'), findsOneWidget);
  });

  forEachAcceptanceCase('property detail with viewings',
      (tester, size, brightness, scale) async {
    _installFakes(viewings: _viewings);
    await _open(tester, const PropertyDetailScreen(id: 7),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the viewing form renders in ${locale.languageCode}',
        (tester) async {
      _installFakes();
      await _open(tester,
          const MeetingFormScreen(initialClientId: 1, initialPropertyId: 7),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale);
    });
  }
}
