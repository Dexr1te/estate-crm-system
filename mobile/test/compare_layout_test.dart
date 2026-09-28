import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/compare/presentation/screens/compare_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';

import 'compare_screen_test.dart' show compareFlats, installCompareFakes;
import 'fakes.dart';
import 'responsive_harness.dart';

/// The comparison and the compare bar hold at every size, theme, text scale
/// and language.
void main() {
  setUp(installCompareFakes);

  for (final ids in [
    [1, 2],
    [1, 2, 3, 4],
  ]) {
    forEachAcceptanceCase('comparison of ${ids.length}',
        (tester, size, brightness, scale) async {
      for (final locale in kAcceptanceLocales) {
        await expectNoOverflow(
          tester,
          CompareScreen(ids: ids, clientId: 9),
          size: size,
          brightness: brightness,
          textScale: scale,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '${locale.languageCode} after loading');
        expect(find.byKey(const ValueKey('compare-send')), findsOneWidget);
      }
    });
  }

  forEachAcceptanceCase('properties compare bar',
      (tester, size, brightness, scale) async {
    Injector.propertiesRepository = FakePropertiesRepository(compareFlats);
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
            BlocProvider(
                create: (_) =>
                    PropertiesBloc(FakePropertiesRepository(compareFlats))),
          ],
          child: PropertiesScreen(key: ValueKey(locale)),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('properties-compare')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'hint bar');
      for (final title in [compareFlats[0].title, compareFlats[1].title]) {
        await tester.scrollUntilVisible(find.text(title), 60,
            scrollable: find.descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable)));
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(find.byKey(const ValueKey('compare-open')), findsOneWidget);
      expect(tester.takeException(), isNull,
          reason: '${locale.languageCode} with two picked');
    }
  });

  testWidgets('at 600 and wider every column shows without scrolling',
      (tester) async {
    await expectNoOverflow(tester, const CompareScreen(ids: [1, 2, 3, 4]),
        size: const Size(768, 1024),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('compare-columns-scroll')), findsNothing);
    for (final id in [1, 2, 3, 4]) {
      final head = tester.getRect(find.byKey(ValueKey('compare-head-$id')));
      expect(head.right, lessThanOrEqualTo(768));
    }
  });

  testWidgets('narrower, the labels stay while the columns scroll',
      (tester) async {
    await expectNoOverflow(tester, const CompareScreen(ids: [1, 2, 3, 4]),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();
    final label = find.text('Price per m²');
    final before = tester.getRect(label);
    await tester.drag(find.byKey(const ValueKey('compare-columns-scroll')),
        const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(tester.getRect(label), before);
    expect(tester.getRect(find.byKey(const ValueKey('compare-head-1'))).left,
        lessThan(before.left));
  });
}
