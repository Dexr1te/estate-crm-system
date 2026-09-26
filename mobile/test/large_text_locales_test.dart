import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'responsive_harness.dart';

// The two rows that overflowed at the largest text the app allows, on the
// narrowest phone, in the locale whose words are longest for them: the card's
// header with a "Reserved" chip in ru, and the form's app bar with its step
// counter in kk. Held here at exactly those settings, and in every locale.

const _small = Size(320, 568);

PropertyResponse _listing(PropertyStatus status) => PropertyResponse(
      id: 2,
      title: 'Дом в Ромашково с участком у леса',
      address: 'Одинцовский р-н, ул. Лесная 4',
      type: PropertyType.HOUSE,
      status: status,
      price: 26000000,
      areaSqm: 180,
      rooms: 5,
    );

Widget _card() => Scaffold(
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
          children: [
            for (final status in PropertyStatus.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PropertyCard(
                  property: _listing(status),
                  onTap: () {},
                ),
              ),
          ],
        ),
      ),
    );

Widget _formBar() => Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return DetailScaffold(
          title: l10n.propertiesNewProperty,
          trailingLabel: l10n.propertiesStepOf(1, 2),
          children: const [SizedBox(height: 40)],
        );
      },
    );

void main() {
  for (final locale in kAcceptanceLocales) {
    final code = locale.languageCode;
    for (final brightness in Brightness.values) {
      testWidgets('property card fits at 320 @1.5 in $code ${brightness.name}',
          (tester) async {
        await expectNoOverflow(tester, _card(),
            size: _small,
            brightness: brightness,
            textScale: 1.5,
            locale: locale);
        await tester.pumpAndSettle();
        expect(find.byType(PropertyCard), findsWidgets);
      });

      testWidgets('form app bar fits at 320 @1.5 in $code ${brightness.name}',
          (tester) async {
        await expectNoOverflow(tester, _formBar(),
            size: _small,
            brightness: brightness,
            textScale: 1.5,
            locale: locale);
      });
    }
  }

  // Below means below, not squeezed: the chip and the step counter each get
  // a line of their own when they no longer fit, and stay beside at 1.0.
  double topOf(WidgetTester tester, Finder f) => tester.getTopLeft(f).dy;

  testWidgets('reserved chip moves under the address in ru @1.5',
      (tester) async {
    await expectNoOverflow(tester, _card(),
        size: _small,
        brightness: Brightness.light,
        textScale: 1.5,
        locale: const Locale('ru'));
    await tester.pumpAndSettle();
    final chip = find.text('Забронирован');
    final address = find.text('Одинцовский р-н, ул. Лесная 4').at(1);
    expect(topOf(tester, chip), greaterThan(tester.getBottomLeft(address).dy));
  });

  testWidgets('reserved chip sits beside the title in en @1.0 at 390',
      (tester) async {
    await expectNoOverflow(tester, _card(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
        locale: const Locale('en'));
    await tester.pumpAndSettle();
    final chip = find.text('Reserved');
    final title = find.text('Дом в Ромашково с участком у леса').at(1);
    expect(topOf(tester, chip), lessThan(tester.getBottomLeft(title).dy));
  });

  testWidgets('step counter goes under the title in kk @1.5', (tester) async {
    await expectNoOverflow(tester, _formBar(),
        size: _small,
        brightness: Brightness.light,
        textScale: 1.5,
        locale: const Locale('kk'));
    final title = find.text('Жаңа нысан');
    final step = find.text('2 қадамнан 1-і');
    expect(topOf(tester, step),
        greaterThanOrEqualTo(tester.getBottomLeft(title).dy));
    expect(tester.getTopLeft(step).dx, tester.getTopLeft(title).dx);
  });
}
