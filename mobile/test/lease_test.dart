import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/presentation/bloc/leases_ending_bloc.dart';
import 'package:real_estate_crm/features/leases/presentation/screens/leases_ending_screen.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_labels.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'checklist_fixtures.dart';
import 'fakes.dart';
import 'lease_fixtures.dart';
import 'responsive_harness.dart';

/// Rent deals and the end of a lease: the sums and wording behind them, the
/// lease on the deal and its renewal, the Sale/Rent switch on the form, and
/// the dashboard card and list of the leases running out.

late FakeLeasesRepository _leases;

/// Remembers what the form sent and never answers, so the screen stays put.
class _RecordingDeals extends FakeDealsRepository {
  _RecordingDeals(super.deals);
  Map<String, dynamic>? sent;

  @override
  Future<DealResponse> updateDeal(int id, Map<String, dynamic> data) {
    sent = data;
    return Completer<DealResponse>().future;
  }
}

Future<void> _pumpDeal(WidgetTester tester,
    {AuthResponse user = checklistAgent, DealResponse? deal}) async {
  final deals = RecordingChecklistDeals([deal ?? rentDeal]);
  Injector.dealsRepository = deals;
  await expectNoOverflow(tester,
      withChecklistBlocs(const DealDetailScreen(id: 1), deals, user: user),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: const Locale('en'));
  await tester.pumpAndSettle();
}

Future<_RecordingDeals> _pumpForm(
    WidgetTester tester, DealResponse deal) async {
  final deals = _RecordingDeals([deal]);
  Injector.dealsRepository = deals;
  await expectNoOverflow(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => DealsBloc(deals)),
      ],
      child: const DealFormScreen(dealId: 1),
    ),
    size: const Size(430, 2400),
    brightness: Brightness.light,
    textScale: 1.0,
  );
  await tester.pumpAndSettle();
  return deals;
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Saves the form. The fake never answers, so the button keeps spinning and
/// the test settles nothing after it.
Future<void> _submit(WidgetTester tester) async {
  final save = find.text('Update Deal');
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  await tester.pump();
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final kk = lookupAppLocalizations(const Locale('kk'));

  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(leaseNow);
    _leases = FakeLeasesRepository(deal: rentDeal);
    Injector.leasesRepository = _leases;
  });
  tearDown(() {
    AppClock.reset();
    Injector.leasesRepository = FakeLeasesRepository();
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  group('where a lease stands', () {
    test('days are counted on calendar dates, whatever the hour', () {
      expect(leaseDaysLeft(leaseDay(0), leaseNow), 0);
      expect(leaseDaysLeft(leaseDay(3), DateTime(2026, 10, 1, 23, 59)), 3);
      expect(leaseDaysLeft(leaseDay(-2), leaseNow), -2);
    });

    test('ending is a won rent within 30 days that has not ended', () {
      expect(leaseEnding(rentDeal, leaseNow), isTrue);
      expect(leaseEnding(rentDeal.copyWith(leaseEnd: leaseDay(31)), leaseNow),
          isFalse);
      expect(leaseEnding(rentDeal.copyWith(leaseEnd: leaseDay(-1)), leaseNow),
          isFalse);
      expect(
          leaseEnding(
              rentDeal.copyWith(status: DealStatus.NEGOTIATION), leaseNow),
          isFalse);
      expect(leaseEnding(checklistDeal, leaseNow), isFalse);
      expect(leaseRenewable(rentDeal), isTrue);
      expect(
          leaseRenewable(rentDeal.copyWith(status: DealStatus.LEAD)), isFalse);
      expect(leaseRenewable(checklistDeal), isFalse);
    });

    test('a rent adds nothing to the pipeline value and leads with its rent',
        () {
      expect(dealSaleValue(rentDeal.copyWith(budget: 900)), 0);
      expect(dealSaleValue(checklistDeal), 42000000);
      expect(dealShownAmount(rentDeal), 350000);
      expect(dealShownAmount(checklistDeal), 42000000);
    });

    test('a renewal goes out as the server takes it', () {
      expect(LeaseRenewal(leaseEnd: DateTime(2027, 10, 26)).toJson(),
          {'leaseEnd': '2027-10-26'});
      expect(
          LeaseRenewal(leaseEnd: DateTime(2027, 1, 2), monthlyRent: 400000)
              .toJson(),
          {'leaseEnd': '2027-01-02', 'monthlyRent': 400000.0});
    });

    test('JSON: a rent deal and a lease ending; an unknown kind is a sale', () {
      final d = DealResponse.fromJson({
        'id': 1,
        'clientId': 1,
        'agentId': 5,
        'kind': 'RENT',
        'monthlyRent': 350000,
        'leaseStart': '2025-11-01',
        'leaseEnd': '2026-10-31',
        'leaseReminderDays': null,
        'leaseReminderDaysEffective': 30,
        'landlordId': 2,
        'landlordName': 'Bolat',
      });
      expect(d.kind, DealKind.rent);
      expect(d.leaseEnd, DateTime(2026, 10, 31));
      expect(d.landlordName, 'Bolat');
      expect(DealResponse.fromJson({'id': 1, 'clientId': 1, 'agentId': 5}).kind,
          DealKind.sale);
      expect(
          DealResponse.fromJson(
              {'id': 1, 'clientId': 1, 'agentId': 5, 'kind': 'BARTER'}).kind,
          DealKind.sale);
      final l = LeaseEnding.fromJson({
        'dealId': 11,
        'dealTitle': 'Dostyk 5',
        'monthlyRent': 300000,
        'leaseEnd': '2026-10-11',
        'daysLeft': 10,
        'reminderDays': 45,
        'tenantId': 3,
        'tenantName': 'Arman',
        'tenantPhone': '+77015551234',
        'landlordId': null,
      });
      expect(l.leaseEnd, DateTime(2026, 10, 11));
      expect(l.reminderDays, 45);
      expect(l.landlordId, isNull);
    });
  });

  group('the wording', () {
    test('time left, in all three languages, with plural forms', () {
      expect(leaseTimeLeftLabel(en, 0), 'Lease ends today');
      expect(leaseTimeLeftLabel(en, 1), 'Lease ends tomorrow');
      expect(leaseTimeLeftLabel(en, 5), 'Lease ends in 5 days');
      expect(leaseTimeLeftLabel(en, -1), 'Lease ended yesterday');
      expect(leaseTimeLeftLabel(en, -3), 'Lease ended 3 days ago');
      expect(leaseTimeLeftLabel(ru, 21), 'Аренда заканчивается через 21 день');
      expect(leaseTimeLeftLabel(ru, 3), 'Аренда заканчивается через 3 дня');
      expect(leaseTimeLeftLabel(ru, 5), 'Аренда заканчивается через 5 дней');
      expect(leaseTimeLeftLabel(kk, 5), 'Жалдау 5 күннен кейін аяқталады');
    });

    test('kinds are named, never raw', () {
      for (final l10n in [en, ru, kk]) {
        for (final k in DealKind.values) {
          final label = dealKindLabel(l10n, k);
          expect(label, isNot(contains(k.name)));
          expect(label.trim(), isNotEmpty);
        }
      }
      expect(dealKindLabel(en, DealKind.rent), 'Rent');
      expect(dealKindLabel(ru, DealKind.sale), 'Продажа');
    });

    test('the reminder notification reads as a sentence', () {
      expect(en.notificationsLeaseEnding('Dostyk 5', 0),
          'The lease on Dostyk 5 ends today');
      expect(en.notificationsLeaseEnding('Dostyk 5', 12),
          'The lease on Dostyk 5 ends in 12 days');
      expect(ru.notificationsLeaseEnding('Dostyk 5', 2),
          'Аренда по сделке «Dostyk 5» заканчивается через 2 дня');
    });
  });

  group('on the deal', () {
    testWidgets('a rent shows its lease, how long is left and the landlord',
        (tester) async {
      await _pumpDeal(tester);
      expect(find.byKey(const Key('deal-summary-rent')), findsOneWidget);
      final card = find.byKey(const Key('deal-lease-card'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      expect(find.text('LEASE'), findsOneWidget);
      expect(find.byKey(const Key('deal-lease-left-warning')), findsOneWidget);
      expect(find.text('Lease ends in 25 days'), findsOneWidget);
      expect(find.text('30 days before the end'), findsOneWidget);
      expect(find.text('Bolat Ospanov-Nurmukhambetov'), findsOneWidget);
    });

    testWidgets('a sale has no lease card', (tester) async {
      await _pumpDeal(tester, deal: checklistDeal);
      expect(find.byKey(const Key('deal-lease-card')), findsNothing);
      expect(find.byKey(const Key('deal-summary-rent')), findsNothing);
    });

    testWidgets('renewing: a year on by default, the new rent, the new end',
        (tester) async {
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-lease-renew')));
      expect(find.text('Renew the lease'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('lease-renew-rent')), '400000');
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('lease-renew-save')));

      expect(_leases.renewed, hasLength(1));
      final (dealId, renewal) = _leases.renewed.single;
      expect(dealId, 1);
      expect(renewal.leaseEnd, DateTime(2027, 10, 26));
      expect(renewal.monthlyRent, 400000);
      expect(find.text('Lease renewed'), findsOneWidget);
      // 2027-10-26 is a year and 25 days away.
      expect(find.text('Lease ends in 390 days'), findsOneWidget);
      expect(find.byKey(const Key('deal-lease-left')), findsOneWidget);
    });

    testWidgets('the rent is not sent again when it did not change',
        (tester) async {
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-lease-renew')));
      await _tap(tester, find.byKey(const Key('lease-renew-save')));
      expect(_leases.renewed.single.$2.monthlyRent, isNull);
    });

    testWidgets('a refused renewal says so and leaves the lease as it was',
        (tester) async {
      _leases.renewError = Exception('409');
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-lease-renew')));
      await _tap(tester, find.byKey(const Key('lease-renew-save')));
      expect(find.text("Couldn't renew the lease"), findsOneWidget);
      expect(find.text('Lease ends in 25 days'), findsOneWidget);
    });

    testWidgets('a rent not yet won cannot be renewed and says when it can',
        (tester) async {
      await _pumpDeal(tester,
          deal: rentDeal.copyWith(status: DealStatus.NEGOTIATION));
      await tester.ensureVisible(find.byKey(const Key('deal-lease-card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('deal-lease-renew')), findsNothing);
      expect(find.text('A lease can be renewed once the deal is won.'),
          findsOneWidget);
    });

    testWidgets('a colleague reads the lease but cannot renew it',
        (tester) async {
      await _pumpDeal(tester, user: checklistColleague);
      await tester.ensureVisible(find.byKey(const Key('deal-lease-card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('deal-lease-renew')), findsNothing);
    });
  });

  group('the form', () {
    testWidgets('a rent loads its lease and sends it back, with no price',
        (tester) async {
      final deals = await _pumpForm(tester, rentDeal);
      expect(find.byKey(const ValueKey('deal-form-rent')), findsOneWidget);
      await _submit(tester);

      final sent = deals.sent!;
      expect(sent['kind'], 'RENT');
      expect(sent['monthlyRent'], 350000);
      expect(sent['leaseStart'], leaseDateParam(leaseDay(-340)));
      expect(sent['leaseEnd'], leaseDateParam(leaseDay(25)));
      expect(sent['landlordId'], 2);
      expect(sent.containsKey('dealPrice'), isFalse);
      expect(sent.containsKey('leaseReminderDays'), isFalse);
    });

    testWidgets('a sale is sent as one, with its price', (tester) async {
      final deals = await _pumpForm(tester, checklistDeal);
      expect(find.byKey(const ValueKey('deal-form-lease-start')), findsNothing);
      await _submit(tester);
      expect(deals.sent!['kind'], 'SALE');
      expect(deals.sent!['dealPrice'], 42000000);
      expect(deals.sent!.containsKey('monthlyRent'), isFalse);
    });

    testWidgets(
        'switching to Rent asks for the rent and both days before it sends',
        (tester) async {
      final deals = await _pumpForm(tester, checklistDeal);
      await _tap(tester, find.byKey(const ValueKey('deal-form-kind-rent')));
      await _submit(tester);

      expect(deals.sent, isNull);
      expect(find.text('Enter the rent per month'), findsOneWidget);
      expect(find.text('Pick the first and the last day of the lease'),
          findsOneWidget);

      await tester.enterText(
          find.byKey(const ValueKey('deal-form-rent')), '300000');
      await _tap(tester, find.byKey(const ValueKey('deal-form-lease-start')));
      await _tap(tester, find.text('OK'));
      await _tap(tester, find.byKey(const ValueKey('deal-form-lease-end')));
      await _tap(tester, find.text('OK'));
      await tester.enterText(
          find.byKey(const ValueKey('deal-form-lease-reminder')), '400');
      await _submit(tester);
      expect(deals.sent, isNull);
      expect(find.text('From 1 to 365 days'), findsOneWidget);

      await tester.enterText(
          find.byKey(const ValueKey('deal-form-lease-reminder')), '45');
      await _submit(tester);
      final sent = deals.sent!;
      expect(sent['kind'], 'RENT');
      expect(sent['monthlyRent'], 300000);
      expect(sent['leaseStart'], '2026-10-01');
      expect(sent['leaseEnd'], '2027-10-01');
      expect(sent['leaseReminderDays'], 45);
      expect(sent.containsKey('dealPrice'), isFalse);
    });
  });

  group('running out', () {
    testWidgets('the dashboard card: the soonest three, a count, See all',
        (tester) async {
      _leases.ending = endingLeases;
      final bloc = LeasesEndingBloc(_leases)..add(LeasesEndingLoadEvent());
      addTearDown(bloc.close);
      var seeAll = 0;
      await tester.pumpWidget(leasesCardApp(bloc, onSeeAll: () => seeAll++));
      await tester.pumpAndSettle();

      expect(_leases.asked.single.$1, kLeaseWindowDays);
      expect(_leases.asked.single.$2, leaseNow);
      expect(find.text('LEASES ENDING'), findsOneWidget);
      expect(find.byType(LeaseRow), findsNWidgets(3));
      expect(find.text('4 in all'), findsOneWidget);
      expect(find.text('Lease ends today'), findsOneWidget);
      expect(find.text('Lease ends tomorrow'), findsOneWidget);
      // A landlord's button only where the deal names one.
      expect(
          find.byKey(const ValueKey('lease-call-landlord-11')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('lease-call-landlord-12')), findsNothing);
      expect(
          find.byKey(const ValueKey('lease-call-tenant-12')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('leases-see-all')));
      expect(seeAll, 1);
      await tester.tap(find.text('Dostyk 5'));
      await tester.pumpAndSettle();
      expect(find.text('deal 12'), findsOneWidget);
    });

    testWidgets('the dashboard card is not there when nothing runs out',
        (tester) async {
      final bloc = LeasesEndingBloc(_leases)..add(LeasesEndingLoadEvent());
      addTearDown(bloc.close);
      await tester.pumpWidget(leasesCardApp(bloc));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('leases-hidden')), findsOneWidget);
      expect(find.byKey(const ValueKey('leases-card')), findsNothing);
    });

    testWidgets('the dashboard card keeps a failure to itself, with a retry',
        (tester) async {
      _leases.failEnding = true;
      final bloc = LeasesEndingBloc(_leases)..add(LeasesEndingLoadEvent());
      addTearDown(bloc.close);
      await tester.pumpWidget(leasesCardApp(bloc));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load the leases"), findsOneWidget);
      _leases.failEnding = false;
      _leases.ending = endingLeases.take(1).toList();
      await tester.tap(find.byKey(const ValueKey('leases-retry')));
      await tester.pumpAndSettle();
      expect(find.byType(LeaseRow), findsOneWidget);
    });

    testWidgets('the list: every lease, soonest first, or why there are none',
        (tester) async {
      _leases.ending = endingLeases;
      await expectNoOverflow(tester, const LeasesEndingScreen(),
          size: const Size(390, 2000),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
      expect(find.byType(LeaseRow), findsNWidgets(4));
      expect(find.text('4'), findsOneWidget);

      _leases.ending = const [];
      await expectNoOverflow(tester, const LeasesEndingScreen(key: Key('b')),
          size: const Size(390, 2000),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
      expect(find.text('No leases end in the next 30 days'), findsOneWidget);
    });
  });
}
