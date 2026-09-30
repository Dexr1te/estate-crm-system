import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/mandates_ending_card.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/mandates_ending_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_badge.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_row.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';

import 'fakes.dart';
import 'mandate_fixtures.dart';
import 'responsive_harness.dart';

/// The seller agreement wherever it shows — the dashboard card, the full
/// list, the badge on a card and on the listing, and the form — at every
/// acceptance size, both themes, text up to 1.5 and all three languages, with
/// the longest title and agent name in the fixtures.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

Widget _blocs(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(Injector.propertiesRepository)),
      ],
      child: child,
    );

void main() {
  setUp(() {
    AppClock.freeze(mandateNow);
    addTearDown(AppClock.reset);
    installMandates(mandateListings);
  });

  forEachAcceptanceCase('agreements card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      final bloc = mandatesBloc();
      addTearDown(bloc.close);
      await expectNoOverflow(
        tester,
        Scaffold(
          key: ValueKey(locale),
          body: Builder(
            builder: (context) => SingleChildScrollView(
              padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
              child: BlocProvider.value(
                value: bloc,
                child: MandatesEndingCard(onSeeAll: () {}),
              ),
            ),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'card, ${locale.languageCode}');
      expect(find.byType(MandateRow), findsNWidgets(kMandatesPreview));
    }
  });

  forEachAcceptanceCase('agreements screen',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        MandatesEndingScreen(key: ValueKey(locale)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'screen, ${locale.languageCode}');
      expect(find.byType(MandateRow), findsWidgets);
    }
  });

  forEachAcceptanceCase('agreement badge on the listing cards',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        Scaffold(
          key: ValueKey(locale),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final p in mandateListings) ...[
                PropertyCard(property: p, onTap: () {}),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'cards, ${locale.languageCode}');
      expect(find.byType(MandateBadge), findsWidgets);
    }
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'the listing and its form with an agreement, '
          '${locale.languageCode} ${brightness.name} at 320 and 1.5x',
          (tester) async {
        await expectNoOverflow(
          tester,
          _blocs(const PropertyDetailScreen(id: 11)),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await _settle(tester, 'detail, ${locale.languageCode}');
        expect(find.byType(MandateBadge), findsOneWidget);

        await expectNoOverflow(
          tester,
          _blocs(const PropertyFormScreen(propertyId: 11)),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await _settle(tester, 'form, ${locale.languageCode}');
        final next = find.byType(AppFilledButton);
        await tester.ensureVisible(next);
        await tester.pumpAndSettle();
        await tester.tap(next);
        await _settle(tester, 'form step 2, ${locale.languageCode}');
        final section = find.byKey(const ValueKey('property-mandate-section'));
        await tester.ensureVisible(section);
        await _settle(tester, 'agreement section, ${locale.languageCode}');
        expect(find.byKey(const ValueKey('mandate-end-date-clear')),
            findsOneWidget);
      });
    }
  }
}
