import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/keys/presentation/bloc/keys_out_bloc.dart';
import 'package:real_estate_crm/features/keys/presentation/screens/keys_out_screen.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/hand_over_keys_sheet.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/key_out_row.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/keys_out_card.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/property_keys_card.dart';

import 'fakes.dart';
import 'keys_fixtures.dart';
import 'responsive_harness.dart';

/// The keys wherever they show — the card on a listing, out and in, its
/// hand-over sheet and return question, the full keys-out list and the
/// dashboard card — at every acceptance size, both themes, larger text and
/// all three languages, with the longest names and notes in the fixtures.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

Widget _page(Locale locale, Widget child) => Scaffold(
      key: ValueKey(locale),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
          child: child,
        ),
      ),
    );

void main() {
  late FakeKeysRepository keys;

  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(keysNow);
    keys = FakeKeysRepository(
      byProperty: {1: overdueKeys(), 2: keysInOffice()},
      out: keysOutList,
    );
    Injector.keysRepository = keys;
    Injector.agentsRepository = const FakeAgentsRepository(keysAgents);
  });
  tearDown(() {
    AppClock.reset();
    Injector.keysRepository = FakeKeysRepository();
    Injector.agentsRepository = const FakeAgentsRepository([]);
  });

  forEachAcceptanceCase('keys card, overdue with a past',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        _page(locale, const PropertyKeysCard(propertyId: 1)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'overdue card, ${locale.languageCode}');
      expect(
          find.byKey(const ValueKey('property-keys-overdue')), findsOneWidget);
    }
  });

  forEachAcceptanceCase('keys card, in the office',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        _page(locale, const PropertyKeysCard(propertyId: 2)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'in-office card, ${locale.languageCode}');
      expect(find.byKey(const ValueKey('property-keys-in-office')),
          findsOneWidget);
    }
  });

  forEachAcceptanceCase('keys out screen',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        KeysOutScreen(key: ValueKey(locale)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'screen, ${locale.languageCode}');
      expect(find.byType(KeyOutRow), findsWidgets);
    }
  });

  forEachAcceptanceCase('keys out on the dashboard',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      final bloc = KeysOutBloc(keys)..add(KeysOutLoadEvent());
      addTearDown(bloc.close);
      await expectNoOverflow(
        tester,
        _page(
          locale,
          BlocProvider.value(
            value: bloc,
            child: KeysOutCard(onSeeAll: () {}),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'dashboard card, ${locale.languageCode}');
      expect(find.byType(KeyOutRow), findsNWidgets(kKeysOutPreview));
    }
  });

  forEachAcceptanceCase('hand-over sheet',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        Scaffold(
          key: ValueKey(locale),
          body: const Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: AppSheetShell(title: 'Keys', child: HandOverKeysForm()),
            ),
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'sheet, ${locale.languageCode}');
      await tester.tap(find.byKey(const ValueKey('keys-to-someone-else')));
      await _settle(tester, 'sheet by name, ${locale.languageCode}');
      expect(find.byKey(const ValueKey('keys-holder-name')), findsOneWidget);
    }
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'the sheet, the picker and the return question, '
          '${locale.languageCode} ${brightness.name} at 320 and 1.5x',
          (tester) async {
        await expectNoOverflow(
          tester,
          _page(locale, const PropertyKeysCard(propertyId: 2)),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await _settle(tester, 'card, ${locale.languageCode}');

        final handOver = find.byKey(const ValueKey('property-keys-hand-over'));
        await tester.ensureVisible(handOver);
        await tester.pumpAndSettle();
        await tester.tap(handOver);
        await _settle(tester, 'sheet open, ${locale.languageCode}');
        await tester.tap(find.byKey(const ValueKey('keys-colleague')));
        await _settle(tester, 'picker, ${locale.languageCode}');
        await tester.tap(find.text('Timur Aliev').last);
        await _settle(tester, 'picked, ${locale.languageCode}');
        final save = find.byKey(const ValueKey('keys-save'));
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await _settle(tester, 'handed over, ${locale.languageCode}');

        final back = find.byKey(const ValueKey('property-keys-return'));
        await tester.ensureVisible(back);
        await tester.pumpAndSettle();
        await tester.tap(back);
        await _settle(tester, 'return question, ${locale.languageCode}');
        expect(find.byType(Dialog), findsOneWidget);
      });
    }
  }
}
