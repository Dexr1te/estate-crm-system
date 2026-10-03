import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/widgets/leases_ending_card.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/leases/presentation/bloc/leases_ending_bloc.dart';
import 'package:real_estate_crm/features/leases/presentation/screens/leases_ending_screen.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_row.dart';

import 'checklist_fixtures.dart';
import 'fakes.dart';
import 'lease_fixtures.dart';
import 'responsive_harness.dart';

/// The lease wherever it shows — the dashboard card, the full list, and the
/// card on the deal with its renewal sheet — at every acceptance size, both
/// themes, larger text and all three languages, with the longest titles and
/// names in the fixtures.

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

void main() {
  late FakeLeasesRepository leases;

  setUp(() {
    AppClock.freeze(leaseNow);
    leases = FakeLeasesRepository(ending: endingLeases, deal: rentDeal);
    Injector.leasesRepository = leases;
  });
  tearDown(() {
    AppClock.reset();
    Injector.leasesRepository = FakeLeasesRepository();
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  forEachAcceptanceCase('leases card', (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      final bloc = LeasesEndingBloc(leases)..add(LeasesEndingLoadEvent());
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
                child: LeasesEndingCard(onSeeAll: () {}),
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
      expect(find.byType(LeaseRow), findsNWidgets(kLeasesPreview));
    }
  });

  forEachAcceptanceCase('leases screen',
      (tester, size, brightness, scale) async {
    for (final locale in kAcceptanceLocales) {
      await expectNoOverflow(
        tester,
        LeasesEndingScreen(key: ValueKey(locale)),
        size: size,
        brightness: brightness,
        textScale: scale,
        locale: locale,
      );
      await _settle(tester, 'screen, ${locale.languageCode}');
      expect(find.byType(LeaseRow), findsWidgets);
    }
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'the lease on the deal and its renewal sheet, '
          '${locale.languageCode} ${brightness.name} at 320 and 1.5x',
          (tester) async {
        final deals = RecordingChecklistDeals([rentDeal]);
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
        final renew = find.byKey(const Key('deal-lease-renew'));
        await tester.ensureVisible(renew);
        await _settle(tester, 'lease card, ${locale.languageCode}');
        await tester.tap(renew);
        await _settle(tester, 'renew sheet, ${locale.languageCode}');
        expect(find.byKey(const Key('lease-renew-save')), findsOneWidget);
      });
    }
  }
}
