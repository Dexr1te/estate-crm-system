import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/price_comparables_sheet.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_price_check.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

import 'price_insight_fixtures.dart';
import 'responsive_harness.dart';

/// Is this price right? The detail's "Price check" card, from the agency's
/// own book: where this listing's price per m² sits against the median.

final _card = find.byKey(const ValueKey('property-price-check'));
final _headline = find.byKey(const ValueKey('price-check-headline'));

Future<void> _detail(WidgetTester tester,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(
      tester, wrapPriceInsight(const PropertyDetailScreen(id: 1)),
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

String _headlineFor(double vs, String difference) =>
    '${formatPrice(600000 * (1 + vs / 100))} / m² '
    'vs median ${formatPrice(600000)} ($difference)';

void main() {
  final l10n = AppLocalizationsEn();

  test('the difference reads above, below or at the median', () {
    expect(priceDifferenceLabel(l10n, 12), '12% above');
    expect(priceDifferenceLabel(l10n, -8.4), '8% below');
    expect(priceDifferenceLabel(l10n, 0.4), 'at the median');
  });

  test('an insight with no comparables has nothing to say', () {
    expect(hasPriceCheck(const PriceInsight()), isFalse);
    expect(hasPriceCheck(priceInsight()), isTrue);
  });

  for (final (vs, difference) in [
    (12.0, '12% above'),
    (-8.0, '8% below'),
    (0.0, 'at the median'),
  ]) {
    testWidgets('a listing $difference says so', (tester) async {
      installPriceInsight(detail: priceInsight(vs: vs));
      await _detail(tester);

      expect(_card, findsOneWidget);
      expect(tester.widget<Text>(_headline).data, _headlineFor(vs, difference));
      expect(find.byKey(const ValueKey('price-range-marker')), findsOneWidget);
      expect(find.byKey(const ValueKey('price-range-median')), findsOneWidget);
      expect(find.text('Based on 7 listings in Almaty'), findsOneWidget);
      expect(
          find.text('Sold at a median of ${formatPrice(500000)} per m² · '
              '30 days on the market'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('price-check-low-confidence')),
          findsNothing);
    });
  }

  testWidgets('a thin book is flagged as a rough guide', (tester) async {
    installPriceInsight(detail: priceInsight(lowConfidence: true));
    await _detail(tester);
    expect(find.byKey(const ValueKey('price-check-low-confidence')),
        findsOneWidget);
  });

  testWidgets('with no comparables there is no card at all', (tester) async {
    installPriceInsight();
    await _detail(tester);
    expect(_card, findsNothing);
  });

  testWidgets('the comparables open from the card, and each opens its listing',
      (tester) async {
    installPriceInsight(detail: priceInsight());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapPriceInsight(MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(initialLocation: '/properties/1', routes: [
        GoRoute(
            path: '/properties/:id',
            builder: (_, s) => s.pathParameters['id'] == '1'
                ? const PropertyDetailScreen(id: 1)
                : Scaffold(body: Text('listing ${s.pathParameters['id']}'))),
      ]),
    )));
    await tester.pumpAndSettle();

    final open = find.byKey(const ValueKey('price-check-comparables'));
    await tester.ensureVisible(open);
    await tester.pumpAndSettle();
    await tester.tap(open);
    await tester.pumpAndSettle();

    expect(find.text('Comparable listings'), findsOneWidget);
    expect(find.text('Sold by a deal'), findsOneWidget);
    expect(
        find.text('${formatPrice(27500000)} · ${formatPrice(550000)} per m²'),
        findsOneWidget);
    Finder inSheet(String text) => find.descendant(
        of: find.byType(PriceComparablesList), matching: find.text(text));
    expect(inSheet('Sold'), findsOneWidget);
    expect(inSheet('Reserved'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('price-comparable-3')));
    await tester.pumpAndSettle();
    expect(find.text('listing 3'), findsOneWidget);
  });

  forEachAcceptanceCase('the price check card',
      (tester, size, brightness, scale) async {
    installPriceInsight(detail: priceInsight(lowConfidence: true));
    await _detail(tester, size: size, brightness: brightness, textScale: scale);
    expect(_card, findsOneWidget);
  });

  forEachAcceptanceCase('the comparables sheet',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
        tester,
        const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AppSheetShell(
              title: 'Comparable listings',
              child: PriceComparablesList(comparables: priceComparables),
            ),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'the card and sheet render in ${locale.languageCode} '
          '${brightness.name}', (tester) async {
        installPriceInsight(detail: priceInsight(lowConfidence: true));
        await _detail(tester,
            size: const Size(320, 568),
            brightness: brightness,
            textScale: 1.5,
            locale: locale);
        expect(_card, findsOneWidget);
        final open = find.byKey(const ValueKey('price-check-comparables'));
        await tester.ensureVisible(open);
        await tester.pumpAndSettle();
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
            find.byKey(const ValueKey('price-comparable-3')), findsOneWidget);
      });
    }
  }
}
