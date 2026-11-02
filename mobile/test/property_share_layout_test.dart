import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/compare/data/comparison_tray.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The listing with what goes out from it — brochure, seller's report,
/// comparison — gathered in one card under the photos and the facts, at
/// every acceptance size, both themes, text up to 1.5 and all three
/// languages. The comparison already holds this listing and another, so its
/// row is split in two: the narrowest the card gets.

const _listing = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84 with a deliberately long name',
  address: 'Dmitrovskoye shosse, 107k2',
  city: 'Almaty',
  type: PropertyType.APARTMENT,
  price: 28000000,
  areaSqm: 62,
  rooms: 3,
  floor: 5,
  totalFloors: 24,
  description: 'Bright flat with a finished interior, park views.',
);

const _other = PropertyResponse(
  id: 8,
  title: 'Tverskaya 12, apartment 5',
  address: 'Tverskaya 12',
  price: 31500000,
);

const _rows = [
  ValueKey('property-brochure'),
  ValueKey('property-seller-report'),
  ValueKey('compare-tray-toggle'),
  ValueKey('compare-tray-open'),
];

Widget _detail(Locale locale) => MultiBlocProvider(
      key: ValueKey(locale),
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(Injector.propertiesRepository)),
      ],
      child: const PropertyDetailScreen(id: 7),
    );

void main() {
  setUp(() {
    Injector.propertiesRepository =
        FakePropertiesRepository(const [_listing, _other]);
    Injector.comparisonTray = ComparisonTray(scope: () => null)
      ..toggle(_listing.id)
      ..toggle(_other.id);
  });

  forEachAcceptanceCase('listing — the share card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      final what = '${locale.languageCode}, ${size.width.toInt()}, '
          '$brightness, ${scale}x';
      await expectNoOverflow(tester, _detail(locale),
          size: size, brightness: brightness, textScale: scale, locale: locale);
      await tester.pumpAndSettle();

      final share = find.byKey(const ValueKey('property-share'));
      await tester.ensureVisible(share);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: what);

      for (final row in _rows) {
        final button = find.descendant(of: share, matching: find.byKey(row));
        expect(button, findsOneWidget, reason: '$row in the card, $what');
        expect(tester.getSize(button).height, greaterThanOrEqualTo(44),
            reason: '$row is a 44pt target, $what');
      }
    }
  });
}
