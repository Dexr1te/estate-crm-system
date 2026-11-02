import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/follow_ups_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'responsive_harness.dart';

/// The dashboard's way into the six follow-up lists: there with nothing in
/// any of them, each row saying what its list holds and opening it.

/// Each row, what it is called, and where it goes.
const _rows = [
  ('follow-ups-cold', 'Going cold', '/clients/cold'),
  ('follow-ups-dates', 'Birthdays and anniversaries', '/clients/dates'),
  ('follow-ups-mandates', 'Seller agreements ending', '/properties/mandates'),
  ('follow-ups-keys', 'Keys out', '/properties/keys'),
  ('follow-ups-deposits', 'Deposits ending', '/deals/deposits'),
  ('follow-ups-leases', 'Leases ending', '/deals/leases'),
];

Widget _page() => Builder(
      builder: (context) => Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
          child: const FollowUpsCard(),
        ),
      ),
    );

Future<void> _pumpRouted(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: '/', routes: [
    GoRoute(path: '/', builder: (_, __) => _page()),
    for (final (_, _, route) in _rows)
      GoRoute(
          path: route,
          builder: (_, __) => Scaffold(body: Text('opened $route'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('names all six lists and says what each holds', (tester) async {
    await _pumpRouted(tester);

    expect(find.text('KEEP AN EYE ON'), findsOneWidget);
    for (final (key, title, _) in _rows) {
      final row = find.byKey(ValueKey(key));
      expect(row, findsOneWidget, reason: key);
      expect(
          find.descendant(of: row, matching: find.text(title)), findsOneWidget,
          reason: '$key is named like the list it opens');
    }
    expect(find.text('No contact for 14 days or more'), findsOneWidget);
    expect(find.text('Listing keys handed out and not yet returned'),
        findsOneWidget);
  });

  for (final (key, _, route) in _rows) {
    testWidgets('$key opens $route', (tester) async {
      await _pumpRouted(tester);

      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();

      expect(find.text('opened $route'), findsOneWidget);
    });
  }

  testWidgets('every row is a full-size tap target', (tester) async {
    await _pumpRouted(tester);

    for (final (key, _, _) in _rows) {
      expect(tester.getSize(find.byKey(ValueKey(key))).height,
          greaterThanOrEqualTo(AppMetrics.minHitTarget),
          reason: key);
    }
  });

  forEachAcceptanceCase('follow-ups card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        KeyedSubtree(key: ValueKey(locale), child: _page()),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'card, ${locale.languageCode}');
      expect(find.byKey(const ValueKey('follow-ups-leases')), findsOneWidget);
    }
  });
}
