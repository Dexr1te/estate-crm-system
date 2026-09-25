import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/send_matches_sheet.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Sending a buyer the flats that answer them, straight from their card.
///
/// The agent picks which of the matches go, and the message is built for the
/// client to read — nothing internal, such as "over budget", leaks into it.

const _buyer = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  type: ClientType.BUYER,
  wantedCity: 'Almaty',
  budgetMax: 30000000,
);

const _severny = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
  areaSqm: 62,
  floor: 5,
  totalFloors: 9,
);

const _tverskaya = PropertyResponse(
  id: 8,
  title: 'Tverskaya 12, apartment 5',
  address: 'Tverskaya 12',
  city: 'Almaty',
  price: 31500000,
  rooms: 2,
  areaSqm: 58,
);

const _matches = [
  PropertyMatch(property: _severny),
  PropertyMatch(property: _tverskaya, overBudget: true),
];

final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');

late FakeShareGateway _share;

void _installFakes({ClientResponse client = _buyer, bool withPhotos = false}) {
  PropertyCovers.clear();
  _share = FakeShareGateway();
  Injector.shareGateway = _share;
  Injector.clientsRepository =
      FakeClientsRepository(clients: [client], matches: _matches);
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.propertiesRepository = FakePropertiesRepository(
    const [_severny, _tverskaya],
    photos: withPhotos
        ? const [PropertyPhoto(id: 1, propertyId: 7, fileName: 'facade.png')]
        : const [],
    photoBytes: _png,
  );
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
      ],
      child: child,
    );

Future<void> _openSheet(WidgetTester tester) async {
  await expectNoOverflow(tester, _wrap(const ClientDetailScreen(id: 1)),
      size: const Size(390, 844), brightness: Brightness.light, textScale: 1.0);
  await tester.pumpAndSettle();
  final button = find.text('Send listings');
  await tester.scrollUntilVisible(button, 200,
      scrollable: find.byType(Scrollable).first);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  test('the message lists each flat the way a client reads it', () {
    final text = composeMatchesMessage(
        AppLocalizationsEn(), const [_severny, _tverskaya]);

    expect(text, startsWith('Hello!'));
    expect(text, contains('1. Severny Residence, apartment 84'));
    expect(text, contains('Apartment · 62 m² · 3 rooms · 5/9'));
    expect(text, contains('Severny Residence 12, Almaty'));
    expect(text, contains(r'$28.0M'));
    expect(text, contains('2. Tverskaya 12, apartment 5'));
    expect(text.indexOf('1. Severny'), lessThan(text.indexOf('2. Tverskaya')));
    expect(text, endsWith('I will arrange a viewing.'));
    expect(text, isNot(contains('budget')),
        reason: 'what the agent knows about the budget stays with the agent');
  });

  test('a flat with nothing but a type does not say its type twice', () {
    final text = composeMatchesMessage(AppLocalizationsEn(),
        const [PropertyResponse(id: 3, title: 'Flat on Abay')]);

    expect(text, contains('\nApartment\n'));
    expect(text, isNot(contains('Apartment · Apartment')));
  });

  testWidgets('everything that matches is picked, and one can be left out',
      (tester) async {
    _installFakes();
    await _openSheet(tester);

    expect(find.text('2 SELECTED'), findsOneWidget);

    await tester.tap(find.text('Tverskaya 12, apartment 5').last);
    await tester.pump();
    expect(find.text('1 SELECTED'), findsOneWidget);

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(_share.calls, 1);
    expect(_share.sharedText, contains('Severny Residence, apartment 84'));
    expect(_share.sharedText, isNot(contains('Tverskaya')));
    expect(find.text('1 SELECTED'), findsNothing,
        reason: 'a completed share closes the sheet');
  });

  testWidgets('covers travel with the text when there are any', (tester) async {
    _installFakes(withPhotos: true);
    await _openSheet(tester);

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(_share.sharedImages.map((i) => i.fileName),
        ['listing-7.png', 'listing-8.png']);
  });

  testWidgets('with photos switched off only the text goes', (tester) async {
    _installFakes(withPhotos: true);
    await _openSheet(tester);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(_share.calls, 1);
    expect(_share.sharedImages, isEmpty);
  });

  testWidgets('with nothing picked there is nothing to send', (tester) async {
    _installFakes();
    await _openSheet(tester);

    await tester.tap(find.text('Severny Residence, apartment 84').last);
    await tester.tap(find.text('Tverskaya 12, apartment 5').last);
    await tester.pump();
    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(_share.calls, 0);
  });

  testWidgets('a dismissed share keeps the sheet open', (tester) async {
    _installFakes();
    _share.outcome = ShareOutcome.dismissed;
    await _openSheet(tester);

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(find.text('2 SELECTED'), findsOneWidget);
  });

  testWidgets('without a phone WhatsApp is off and the sheet says why',
      (tester) async {
    _installFakes(
        client: const ClientResponse(
            id: 1,
            fullName: 'Irina Sokolova',
            type: ClientType.BUYER,
            wantedCity: 'Almaty'));
    await _openSheet(tester);

    expect(find.text('No phone number on the card, so WhatsApp is unavailable'),
        findsOneWidget);
    final whatsApp = tester.widget<AppGhostButton>(find.ancestor(
        of: find.text('WhatsApp'), matching: find.byType(AppGhostButton)));
    expect(whatsApp.onPressed, isNull);
  });

  forEachAcceptanceCase('send matches sheet',
      (tester, size, brightness, scale) async {
    _installFakes();
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AppSheetShell(
              title: 'Send listings',
              subtitle: 'Irina Alexandrovna Sokolova',
              child: SendMatchesSheet(client: _buyer, matches: _matches),
            ),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
