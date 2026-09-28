import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/features/route/presentation/screens/route_screen.dart';
import 'package:real_estate_crm/features/route/presentation/widgets/maps_chooser_sheet.dart';

import 'day_route_fixtures.dart';
import 'responsive_harness.dart';

/// The route screen and the maps chooser at every acceptance size, both
/// themes, three text scales and all three languages. Mid-morning, so one
/// stop is over, one is next, one overlaps and one is not on the map.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

void main() {
  setUp(() {
    AppClock.freeze(routeAt(10, 45));
    addTearDown(AppClock.reset);
  });

  forEachAcceptanceCase('route screen',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      installRoute();
      await expectNoOverflow(
        tester,
        RouteScreen(key: ValueKey(locale), day: routeDay),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'route, ${locale.languageCode}');
      expect(find.byKey(const ValueKey('route-map')), findsOneWidget);
    }
  });

  forEachAcceptanceCase('maps chooser',
      (tester, size, brightness, scale) async {
    final route = DayRoute.from(routeMeetings());
    for (final locale in kAcceptanceLocales) {
      for (final whole in [true, false]) {
        await expectNoOverflow(
          tester,
          Scaffold(
            key: ValueKey('$locale-$whole'),
            body: Align(
              alignment: Alignment.bottomCenter,
              child: AppSheetShell(
                title: 'Open in a maps app',
                child: MapsChooser(
                    stops: whole ? route.legs : [route.legs.first],
                    whole: whole),
              ),
            ),
          ),
          size: size,
          brightness: brightness,
          textScale: scale,
          locale: locale,
        );
        await _settle(tester, 'chooser, ${locale.languageCode}, $whole');
      }
    }
  });
}
