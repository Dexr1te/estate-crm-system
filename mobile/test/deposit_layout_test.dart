import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/deposits_ending_card.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deposits/presentation/bloc/deposits_ending_bloc.dart';
import 'package:real_estate_crm/features/deposits/presentation/screens/deposits_ending_screen.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_labels.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_row.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';

import 'checklist_fixtures.dart';
import 'deposit_fakes.dart';
import 'deposit_fixtures.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// The deposit wherever it shows — the dashboard card, the full list, the
/// card on the deal and its sheets, and the badge on a listing card — at
/// every acceptance size, both themes, larger text and all three languages,
/// with the longest titles and names in the fixtures.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

void main() {
  late FakeDepositsRepository deposits;

  setUp(() {
    AppClock.freeze(depositNow);
    deposits = FakeDepositsRepository(
      byDeal: {
        1: [activeDepositFixture(), pastDepositFixture()]
      },
      ending: endingDeposits,
    );
    Injector.depositsRepository = deposits;
  });
  tearDown(() {
    AppClock.reset();
    Injector.depositsRepository = FakeDepositsRepository();
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  forEachAcceptanceCase('deposits card',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      final bloc = DepositsEndingBloc(deposits)..add(DepositsEndingLoadEvent());
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
                child: DepositsEndingCard(onSeeAll: () {}),
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
      expect(find.byType(DepositRow), findsNWidgets(kDepositsPreview));
    }
  });

  forEachAcceptanceCase('deposits screen',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        DepositsEndingScreen(key: ValueKey(locale)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'screen, ${locale.languageCode}');
      expect(find.byType(DepositRow), findsWidgets);
    }
  });

  forEachAcceptanceCase('reserved badge on the listing cards',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        Scaffold(
          key: ValueKey(locale),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PropertyCard(
                  property: PropertyResponse(
                      id: 1,
                      title: 'Esentai Park, apartment 12 with a long name',
                      address: 'Al-Farabi 77',
                      status: PropertyStatus.RESERVED,
                      price: 28000000,
                      mandateType: MandateType.EXCLUSIVE,
                      mandateEndDate: depositDay(40),
                      depositHoldUntil: depositDay(2)),
                  onTap: () {}),
              const SizedBox(height: 8),
              PropertyCard(
                  property: PropertyResponse(
                      id: 2,
                      title: 'Dostyk 5',
                      price: 41000000,
                      depositHoldUntil: DateTime(2027, 1, 20)),
                  onTap: () {}),
            ],
          ),
        ),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'cards, ${locale.languageCode}');
      expect(find.byType(DepositBadge), findsNWidgets(2));
    }
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'the deposit on the deal and its sheets, '
          '${locale.languageCode} ${brightness.name} at 320 and 1.5x',
          (tester) async {
        final deals = RecordingChecklistDeals();
        Injector.dealsRepository = deals;
        await expectNoOverflow(
          tester,
          withChecklistBlocs(const DealDetailScreen(id: 1), deals),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await _settle(tester, 'deal, ${locale.languageCode}');
        final card = find.byKey(const Key('deal-deposit-card'));
        await tester.ensureVisible(card);
        await _settle(tester, 'deposit card, ${locale.languageCode}');

        final edit = find.byKey(const Key('deal-deposit-edit'));
        await tester.ensureVisible(edit);
        await tester.pumpAndSettle();
        await tester.tap(edit);
        await _settle(tester, 'edit sheet, ${locale.languageCode}');
        expect(find.byKey(const Key('deposit-save')), findsOneWidget);
        await tester.tapAt(const Offset(10, 10));
        await _settle(tester, 'edit sheet closed, ${locale.languageCode}');

        final close = find.byKey(const Key('deal-deposit-close'));
        await tester.ensureVisible(close);
        await tester.pumpAndSettle();
        await tester.tap(close);
        await _settle(tester, 'close sheet, ${locale.languageCode}');
        expect(find.byKey(const Key('deposit-close-confirm')), findsOneWidget);
      });
    }
  }
}
