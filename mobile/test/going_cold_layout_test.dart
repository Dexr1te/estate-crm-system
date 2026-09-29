import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/cold_clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/cold_client_row.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/going_cold_card.dart';

import 'going_cold_fixtures.dart';
import 'responsive_harness.dart';

/// The going-cold card and the full list at every acceptance size, both
/// themes, three text scales and all three languages — with the longest name
/// and two reason chips side by side.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

void main() {
  setUp(() {
    AppClock.freeze(coldNow);
    addTearDown(AppClock.reset);
  });

  forEachAcceptanceCase('going-cold card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      installCold(coldClients);
      final bloc = coldBloc();
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
                child: GoingColdCard(onSeeAll: () {}, total: 128),
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
      expect(find.byType(ColdClientRow), findsNWidgets(kGoingColdPreview));
    }
  });

  forEachAcceptanceCase('going-cold screen',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      installCold(coldClients);
      await expectNoOverflow(
        tester,
        ColdClientsScreen(key: ValueKey(locale)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'screen, ${locale.languageCode}');
      expect(find.byKey(const ValueKey('cold-days-30')), findsOneWidget);
    }
  });
}
