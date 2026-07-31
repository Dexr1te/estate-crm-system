import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _properties = [
  PropertyResponse(
    id: 1,
    title: 'Severny Residence, apartment 84 with a deliberately long name',
    address: 'Dmitrovskoye shosse, 107k2',
    city: 'Moscow',
    type: PropertyType.APARTMENT,
    status: PropertyStatus.AVAILABLE,
    price: 12300000,
    areaSqm: 58,
    rooms: 2,
    floor: 5,
    totalFloors: 24,
    description: 'Bright flat with a finished interior, park views.',
  ),
  PropertyResponse(
    id: 2,
    title: 'Дом в Ромашково',
    address: 'Одинцовский р-н, ул. Лесная 4',
    type: PropertyType.HOUSE,
    status: PropertyStatus.RESERVED,
    price: 26000000,
    areaSqm: 180,
    rooms: 5,
  ),
  PropertyResponse(
    id: 3,
    title: 'Офис, Тверская 12',
    address: 'БЦ «Тверской», 3 этаж',
    type: PropertyType.OFFICE,
    status: PropertyStatus.SOLD,
    price: 54800000,
    areaSqm: 240,
  ),
];

void _installFakes() {
  Injector.propertiesRepository = FakePropertiesRepository(_properties);
}

Widget _wrap(Widget child, {List<PropertyResponse> items = _properties}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(items))),
      ],
      child: child,
    );

void main() {
  setUp(_installFakes);

  forEachAcceptanceCase('properties list',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const PropertiesScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('properties list — empty',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const PropertiesScreen(), items: const []),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('property detail',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const PropertyDetailScreen(id: 1)),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('property form — step 1',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const PropertyFormScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('properties render in ${locale.languageCode}', (tester) async {
      for (final screen in [
        const PropertiesScreen(),
        const PropertyDetailScreen(id: 1),
        const PropertyFormScreen(),
      ]) {
        await expectNoOverflow(
          tester,
          _wrap(screen),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '${screen.runtimeType} in ${locale.languageCode}');
      }
    });
  }

  testWidgets('form advances to step 2 only when the basics validate',
      (tester) async {
    await expectNoOverflow(
      tester,
      _wrap(const PropertyFormScreen()),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2'), findsOneWidget);

    await tester.ensureVisible(find.text('Next — details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next — details'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Test listing');
    await tester.enterText(find.byType(TextFormField).at(1), '12300000');
    await tester.enterText(find.byType(TextFormField).at(3), 'Some street 1');
    await tester.ensureVisible(find.text('Next — details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next — details'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 2'), findsOneWidget);
  });
}
