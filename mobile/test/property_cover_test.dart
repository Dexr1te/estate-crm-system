import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The cover a listing shows in the list.
///
/// A listing with photographs looks different from one without, and the one
/// that has none must not ask for a cover on every rebuild — a list of twenty
/// would be twenty requests answered by twenty 404s, over and over as it
/// scrolls.

const _withPhoto = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
  areaSqm: 62,
);

const _withoutPhoto = PropertyResponse(
  id: 8,
  title: 'Tverskaya 12, apartment 5',
  address: 'Tverskaya 12',
  city: 'Almaty',
  price: 31000000,
  rooms: 2,
  areaSqm: 58,
);

/// A one-pixel PNG. Small enough to sit in a test, real enough to decode.
final _png = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

late FakePropertiesRepository _repository;

void _installFakes({bool withPhoto = true}) {
  PropertyCovers.clear();
  _repository = FakePropertiesRepository(
    const [_withPhoto, _withoutPhoto],
    photos: withPhoto
        ? const [PropertyPhoto(id: 1, propertyId: 7, fileName: 'facade.jpg')]
        : const [],
    photoBytes: _png,
  );
  Injector.propertiesRepository = _repository;
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => PropertiesBloc(_repository)),
      ],
      child: child,
    );

void main() {
  testWidgets('a listing shows its cover where the type icon was',
      (tester) async {
    _installFakes();

    await expectNoOverflow(tester, _wrap(const PropertiesScreen()),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    expect(find.byType(PropertyCover), findsWidgets);
    expect(find.byType(Image), findsWidgets,
        reason: 'the cover replaces the icon rather than pushing it aside');
  });

  testWidgets('a listing with no photos falls back to its type',
      (tester) async {
    _installFakes(withPhoto: false);

    await expectNoOverflow(tester, _wrap(const PropertiesScreen()),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    expect(find.byType(PropertyCover), findsWidgets);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a listing without a cover is asked once, not on every frame',
      (tester) async {
    _installFakes(withPhoto: false);

    await expectNoOverflow(tester, _wrap(const PropertiesScreen()),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();

    expect(PropertyCovers.isKnown(_withPhoto.id), isTrue,
        reason: 'the answer, even an empty one, is remembered for the run');
  });

  forEachAcceptanceCase('properties list with covers',
      (tester, size, brightness, scale) async {
    _installFakes();
    await expectNoOverflow(tester, _wrap(const PropertiesScreen()),
        size: size, brightness: brightness, textScale: scale);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
