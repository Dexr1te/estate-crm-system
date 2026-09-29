import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_price_hint.dart';

import 'price_insight_fixtures.dart';
import 'responsive_harness.dart';

/// While a listing is being written, what similar ones in the agency's book
/// go for at this area — asked once the agent stops typing, and silent when
/// the book has too little to say.

final _hint = find.byKey(const ValueKey('property-price-hint'));
final _useMedian = find.byKey(const ValueKey('property-price-use-median'));
Finder _field(int i) => find.byType(TextFormField).at(i);
const _price = 1, _area = 2, _city = 4;

Future<void> _form(WidgetTester tester,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, wrapPriceInsight(const PropertyFormScreen()),
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, int field, String text) async {
  await tester.ensureVisible(_field(field));
  await tester.enterText(_field(field), text);
}

Future<void> _fillAndWait(WidgetTester tester) async {
  await _type(tester, _city, 'Almaty');
  await _type(tester, _area, '60');
  await tester.pump(priceHintDebounce);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('asks once the typing stops, and shows the range for the area',
      (tester) async {
    installPriceInsight(form: priceInsight());
    await _form(tester);

    await _type(tester, _city, 'Alm');
    await tester.pump(const Duration(milliseconds: 200));
    await _type(tester, _city, 'Almaty');
    await _type(tester, _area, '6');
    await tester.pump(const Duration(milliseconds: 200));
    await _type(tester, _area, '60');
    await tester.pump(const Duration(milliseconds: 300));
    expect(priceRepository.insightRequests, isEmpty);

    await tester.pump(priceHintDebounce);
    await tester.pumpAndSettle();
    expect(priceRepository.insightRequests, hasLength(1));
    expect(priceRepository.insightRequests.single, {
      'city': 'Almaty',
      'type': PropertyType.APARTMENT,
      'rooms': null,
      'areaSqm': 60.0,
      'excludeId': null,
    });
    expect(
        find.text('Similar listings: ${formatPrice(28500000)}–'
            '${formatPrice(39000000)} for this area'),
        findsOneWidget);
  });

  testWidgets('"Use median" fills the price', (tester) async {
    installPriceInsight(form: priceInsight());
    await _form(tester);
    await _fillAndWait(tester);

    await tester.ensureVisible(_useMedian);
    await tester.pumpAndSettle();
    await tester.tap(_useMedian);
    await tester.pump();
    expect(tester.widget<TextFormField>(_field(_price)).controller!.text,
        '33000000');
  });

  testWidgets('nothing is asked without a city and an area', (tester) async {
    installPriceInsight(form: priceInsight());
    await _form(tester);
    await _type(tester, _area, '60');
    await tester.pump(priceHintDebounce * 2);
    expect(priceRepository.insightRequests, isEmpty);
    expect(_hint, findsNothing);
  });

  testWidgets('a thin book shows no hint', (tester) async {
    installPriceInsight(form: priceInsight(lowConfidence: true));
    await _form(tester);
    await _fillAndWait(tester);
    expect(priceRepository.insightRequests, hasLength(1));
    expect(_hint, findsNothing);
  });

  testWidgets('an empty book shows no hint', (tester) async {
    installPriceInsight();
    await _form(tester);
    await _fillAndWait(tester);
    expect(_hint, findsNothing);
  });

  forEachAcceptanceCase('the price hint on the form',
      (tester, size, brightness, scale) async {
    installPriceInsight(form: priceInsight());
    await _form(tester, size: size, brightness: brightness, textScale: scale);
    await _fillAndWait(tester);
    expect(tester.takeException(), isNull);
    expect(_hint, findsOneWidget);
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'the price hint renders in ${locale.languageCode} '
          '${brightness.name}', (tester) async {
        installPriceInsight(form: priceInsight());
        await _form(tester,
            size: const Size(320, 568),
            brightness: brightness,
            textScale: 1.5,
            locale: locale);
        await _fillAndWait(tester);
        expect(tester.takeException(), isNull);
        expect(_hint, findsOneWidget);
      });
    }
  }
}
