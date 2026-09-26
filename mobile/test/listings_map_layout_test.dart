import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_map_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_listing_card.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_markers.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The map screens at every acceptance size, both themes and every text
/// scale: the map view with a pin's card up and the no-location hint, the
/// form's pin section with a pin in it, and the detail's still map.

const _listings = [
  PropertyResponse(
    id: 1,
    title:
        'Esentai Park, apartment 12 with a deliberately long name that wraps',
    address: 'Al-Farabi 77, block 3, entrance 2, a long address as well',
    city: 'Almaty',
    status: PropertyStatus.RESERVED,
    price: 128000000,
    rooms: 4,
    areaSqm: 142,
    floor: 12,
    totalFloors: 24,
    latitude: 43.2400,
    longitude: 76.8900,
  ),
  PropertyResponse(
    id: 2,
    title: 'Kok-Tobe house',
    address: 'Kok-Tobe 5',
    type: PropertyType.HOUSE,
    status: PropertyStatus.SOLD,
    price: 54000000,
    latitude: 43.2385,
    longitude: 76.8880,
  ),
  PropertyResponse(id: 3, title: 'No pin yet', address: 'Abaya 10', price: 1),
];

void _install() {
  Injector.propertiesRepository = FakePropertiesRepository(_listings);
  Injector.clientsRepository = FakeClientsRepository();
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(_listings))),
      ],
      child: child,
    );

Future<void> _mapWithCard(WidgetTester tester, Size size, Brightness b,
    double scale, Locale locale) async {
  await expectNoOverflow(tester, _wrap(const PropertiesScreen()),
      size: size, brightness: b, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
  final tabs = find.byKey(const ValueKey('properties-view-tabs'));
  await tester
      .tap(find.descendant(of: tabs, matching: find.byType(InkWell)).last);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('properties-map')), findsOneWidget);
  expect(find.byKey(const ValueKey('map-unpinned-hint')), findsOneWidget);
  expect(tester.takeException(), isNull);

  final pin =
      find.byWidgetPredicate((w) => w is PricePin && w.property.id == 1);
  await tester.tap(pin);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('map-card-1')), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> _formWithPin(WidgetTester tester, Size size, Brightness b,
    double scale, Locale locale) async {
  await expectNoOverflow(tester, _wrap(const PropertyFormScreen(propertyId: 1)),
      size: size, brightness: b, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
  final clear = find.byKey(const ValueKey('location-picker-clear'));
  await tester.ensureVisible(clear);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('location-picker-pin')), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> _detailPreview(WidgetTester tester, Size size, Brightness b,
    double scale, Locale locale) async {
  await expectNoOverflow(tester, _wrap(const PropertyDetailScreen(id: 1)),
      size: size, brightness: b, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
  final open = find.byKey(const ValueKey('property-open-in-maps'));
  await tester.ensureVisible(open);
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('property-location-map')), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  setUp(_install);

  forEachAcceptanceCase('properties map',
      (tester, size, b, scale) => _mapWithCard(tester, size, b, scale, _en));
  forEachAcceptanceCase('property form — pin',
      (tester, size, b, scale) => _formWithPin(tester, size, b, scale, _en));
  forEachAcceptanceCase('property detail — map preview',
      (tester, size, b, scale) => _detailPreview(tester, size, b, scale, _en));

  // The map's own card and hint at the largest text, in every language. (The
  // list behind it is covered by properties_screens_test.)
  for (final locale in kAcceptanceLocales) {
    testWidgets('map card and hint at 1.5x in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
          tester,
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                MapListingCard(property: _listings.first, onTap: () {}),
                const SizedBox(height: 12),
                UnpinnedHint(
                    count: 21,
                    repository: FakePropertiesRepository(_listings),
                    filters: const MapFilters()),
              ]),
            ),
          ),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in kAcceptanceLocales) {
    for (final entry in {
      'map': _mapWithCard,
      'form pin': _formWithPin,
      'detail preview': _detailPreview,
    }.entries) {
      testWidgets('${entry.key} renders in ${locale.languageCode}',
          (tester) async {
        await entry.value(
            tester, const Size(320, 568), Brightness.dark, 1.5, locale);
      });
    }
  }
}

const _en = Locale('en');
