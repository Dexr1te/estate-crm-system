import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/features/deposits/presentation/bloc/deposits_ending_bloc.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_labels.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_row.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'checklist_fixtures.dart';
import 'deposit_fakes.dart';
import 'deposit_fixtures.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// The deposit on a deal: the card on the deal with its record, edit and
/// close sheets, the reserved badge on a listing, and the dashboard card and
/// list of the deposits whose hold is running out.

late FakeDepositsRepository _deposits;

Future<void> _pumpDeal(WidgetTester tester,
    {AuthResponse user = checklistAgent,
    DealResponse deal = checklistDeal}) async {
  final deals = RecordingChecklistDeals([deal]);
  Injector.dealsRepository = deals;
  await expectNoOverflow(tester,
      withChecklistBlocs(const DealDetailScreen(id: 1), deals, user: user),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: const Locale('en'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('deal-deposit-card')));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final kk = lookupAppLocalizations(const Locale('kk'));

  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(depositNow);
    _deposits = FakeDepositsRepository();
    Injector.depositsRepository = _deposits;
  });
  tearDown(() {
    AppClock.reset();
    Injector.depositsRepository = FakeDepositsRepository();
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  group('where a deposit stands', () {
    test('days are counted on calendar dates, whatever the hour', () {
      expect(depositDaysLeft(depositDay(0), depositNow), 0);
      expect(depositDaysLeft(depositDay(3), DateTime(2026, 10, 1, 23, 59)), 3);
      expect(depositDaysLeft(depositDay(-7), depositNow), -7);
    });

    test('ending is anything up to seven days out, or gone; only while active',
        () {
      DealDeposit at(int days, {bool active = true}) => DealDeposit(
          id: 1,
          dealId: 1,
          receivedOn: depositDay(-30),
          holdUntil: depositDay(days),
          active: active);
      expect(depositEnding(at(-2), depositNow), isTrue);
      expect(depositEnding(at(7), depositNow), isTrue);
      expect(depositEnding(at(8), depositNow), isFalse);
      expect(depositEnding(at(-2, active: false), depositNow), isFalse);
      expect(
          depositHoldEnding(
              PropertyResponse(id: 1, depositHoldUntil: depositDay(3)),
              depositNow),
          isTrue);
      expect(depositHoldEnding(const PropertyResponse(id: 1), depositNow),
          isFalse);
    });

    test('a draft goes out as the server takes it, and checks its dates', () {
      final draft = DepositDraft(
          amount: 500000,
          receivedOn: DateTime(2026, 10, 1),
          holdUntil: DateTime(2026, 10, 20),
          holder: DepositHolder.SELLER,
          note: '  ');
      expect(draft.isValid, isTrue);
      expect(draft.toJson(), {
        'amount': 500000.0,
        'receivedOn': '2026-10-01',
        'holdUntil': '2026-10-20',
        'holder': 'SELLER',
        'note': null,
      });
      expect(
          DepositDraft(
                  amount: 1,
                  receivedOn: DateTime(2026, 10, 2),
                  holdUntil: DateTime(2026, 10, 1),
                  holder: DepositHolder.AGENCY)
              .isValid,
          isFalse);
      expect(
          DepositDraft(
                  amount: 0,
                  receivedOn: DateTime(2026, 10, 1),
                  holdUntil: DateTime(2026, 10, 1),
                  holder: DepositHolder.AGENCY)
              .isValid,
          isFalse);
    });

    test('JSON: a deposit and the hold on a listing; unknown values degrade',
        () {
      final d = DealDeposit.fromJson({
        'id': 7,
        'dealId': 1,
        'amount': 500000,
        'receivedOn': '2026-09-22',
        'holdUntil': '2026-10-06',
        'holder': 'NOTARY',
        'active': false,
        'outcome': 'FORFEITED',
        'closedOn': '2026-10-01',
      });
      expect(d.holder, DepositHolder.NOTARY);
      expect(d.outcome, DepositOutcome.FORFEITED);
      expect(d.holdUntil, DateTime(2026, 10, 6));

      final future = DealDeposit.fromJson({
        'id': 8,
        'dealId': 1,
        'receivedOn': '2026-09-22',
        'holdUntil': '2026-10-06',
        'holder': 'BANK',
        'outcome': 'SPENT',
      });
      expect(future.holder, DepositHolder.AGENCY);
      expect(future.outcome, isNull);

      expect(
          PropertyResponse.fromJson({'id': 3, 'depositHoldUntil': '2026-10-06'})
              .depositHoldUntil,
          DateTime(2026, 10, 6));
      expect(PropertyResponse.fromJson({'id': 3}).depositHoldUntil, isNull);
    });
  });

  group('the wording', () {
    test('time left, in all three languages, with plural forms', () {
      expect(depositTimeLeftLabel(en, 0), 'Hold ends today');
      expect(depositTimeLeftLabel(en, 1), 'Hold ends tomorrow');
      expect(depositTimeLeftLabel(en, 5), 'Hold ends in 5 days');
      expect(depositTimeLeftLabel(en, -1), 'Hold ended yesterday');
      expect(depositTimeLeftLabel(en, -3), 'Hold ended 3 days ago');
      expect(depositTimeLeftLabel(ru, 5), 'Бронь истекает через 5 дней');
      expect(depositTimeLeftLabel(ru, 2), 'Бронь истекает через 2 дня');
      expect(depositTimeLeftLabel(ru, -21), 'Бронь истекла 21 день назад');
      expect(depositTimeLeftLabel(kk, 5), 'Бронь 5 күннен кейін аяқталады');
    });

    test('holders and outcomes are named, never raw', () {
      for (final l10n in [en, ru, kk]) {
        for (final h in DepositHolder.values) {
          expect(depositHolderLabel(l10n, h), isNot(h.name));
        }
        for (final o in DepositOutcome.values) {
          expect(depositOutcomeLabel(l10n, o), isNot(o.name));
        }
      }
      expect(depositHolderLabel(ru, DepositHolder.NOTARY), 'Нотариус');
      expect(depositOutcomeLabel(en, DepositOutcome.APPLIED),
          'Applied to the purchase');
    });
  });

  group('on the deal', () {
    testWidgets('no deposit yet: the agent records one from the sheet',
        (tester) async {
      await _pumpDeal(tester);
      expect(find.text('No deposit recorded'), findsOneWidget);

      await _tap(tester, find.byKey(const Key('deal-deposit-record')));
      expect(find.text('Record a deposit'), findsOneWidget);
      // Nothing to save without an amount.
      final save = find.byKey(const Key('deposit-save'));
      await tester.enterText(find.byKey(const Key('deposit-amount')), '500000');
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('deposit-holder-SELLER')));
      await tester.enterText(find.byKey(const Key('deposit-note')), 'Receipt');
      await tester.pumpAndSettle();
      await _tap(tester, save);

      expect(_deposits.recorded, hasLength(1));
      final (dealId, draft) = _deposits.recorded.single;
      expect(dealId, 1);
      expect(draft.amount, 500000);
      expect(draft.holder, DepositHolder.SELLER);
      expect(draft.receivedOn, DateTime(2026, 10, 1));
      expect(draft.holdUntil, DateTime(2026, 10, 15));
      expect(draft.note, 'Receipt');

      expect(find.text('No deposit recorded'), findsNothing);
      expect(find.textContaining('500,000'), findsOneWidget);
      expect(find.text('Seller'), findsOneWidget);
      expect(find.text('Hold ends in 14 days'), findsOneWidget);
    });

    testWidgets('the save waits for an amount', (tester) async {
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-deposit-record')));
      await _tap(tester, find.byKey(const Key('deposit-save')));
      expect(_deposits.recorded, isEmpty);
    });

    testWidgets('an active deposit: what it is, edited and then ended',
        (tester) async {
      _deposits.byDeal[1] = [activeDepositFixture(), pastDepositFixture()];
      await _pumpDeal(tester);

      expect(find.textContaining('500,000'), findsOneWidget);
      expect(find.text('Notary'), findsOneWidget);
      expect(find.text('Hold ends in 5 days'), findsOneWidget);
      expect(find.byKey(const Key('deal-deposit-left-warning')), findsOneWidget,
          reason: 'five days out is inside the week');
      expect(find.text('Earlier deposits'), findsOneWidget);
      expect(find.textContaining('Refunded · Sep 6'), findsOneWidget);
      expect(find.byKey(const Key('deal-deposit-record')), findsNothing);

      await _tap(tester, find.byKey(const Key('deal-deposit-edit')));
      expect(find.text('Edit the deposit'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('deposit-amount')), '650000');
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('deposit-save')));
      expect(_deposits.updated.single.$2, 7);
      expect(_deposits.updated.single.$3.amount, 650000);
      expect(_deposits.updated.single.$3.holder, DepositHolder.NOTARY,
          reason: 'what was not touched goes back as it was');
      expect(find.textContaining('650,000'), findsOneWidget);

      await _tap(tester, find.byKey(const Key('deal-deposit-close')));
      expect(find.text('How did the deposit end?'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('deposit-close-confirm')));
      expect(_deposits.closed, isEmpty, reason: 'pick how it ended first');
      await _tap(tester, find.byKey(const Key('deposit-outcome-FORFEITED')));
      await _tap(tester, find.byKey(const Key('deposit-close-confirm')));
      final (_, id, closing) = _deposits.closed.single;
      expect(id, 7);
      expect(closing.outcome, DepositOutcome.FORFEITED);
      expect(closing.closedOn, DateTime(2026, 10, 1));

      expect(find.text('No deposit recorded'), findsOneWidget);
      expect(find.textContaining('Forfeited · Oct 1'), findsOneWidget);
    });

    testWidgets('a colleague reads the deposit but cannot change it',
        (tester) async {
      _deposits.byDeal[1] = [activeDepositFixture()];
      await _pumpDeal(tester, user: checklistColleague);
      expect(find.text('Notary'), findsOneWidget);
      expect(find.byKey(const Key('deal-deposit-edit')), findsNothing);
      expect(find.byKey(const Key('deal-deposit-close')), findsNothing);
    });

    testWidgets('a closed deal takes no new deposit', (tester) async {
      await _pumpDeal(tester,
          deal: checklistDeal.copyWith(status: DealStatus.CLOSED_LOST));
      expect(find.text('No deposit recorded'), findsOneWidget);
      expect(find.byKey(const Key('deal-deposit-record')), findsNothing);
    });

    testWidgets('a refused write says so and leaves the card as it was',
        (tester) async {
      _deposits.writeError = Exception('409');
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-deposit-record')));
      await tester.enterText(find.byKey(const Key('deposit-amount')), '100');
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('deposit-save')));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No deposit recorded'), findsOneWidget);
    });

    testWidgets('a load failure stays in the card with a retry',
        (tester) async {
      _deposits.failLoad = true;
      await _pumpDeal(tester);
      expect(find.text("Couldn't load the deposit"), findsOneWidget);
      _deposits.failLoad = false;
      await _tap(tester, find.byKey(const Key('deal-deposit-retry')));
      expect(find.text('No deposit recorded'), findsOneWidget);
    });
  });

  group('the listing', () {
    testWidgets(
        'a listing under deposit says reserved, in the warning hue near the end',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(children: [
            PropertyCard(
                property: PropertyResponse(
                    id: 1, title: 'Soon', depositHoldUntil: depositDay(3)),
                onTap: () {}),
            PropertyCard(
                property: PropertyResponse(
                    id: 2, title: 'Later', depositHoldUntil: depositDay(30)),
                onTap: () {}),
            PropertyCard(
                property: const PropertyResponse(id: 3, title: 'Free'),
                onTap: () {}),
          ]),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Reserved until Oct 4'), findsOneWidget);
      expect(find.text('Reserved until Oct 31'), findsOneWidget);
      expect(find.byKey(const ValueKey('deposit-badge-1-warning')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('deposit-badge-2')), findsOneWidget);
      expect(find.byType(DepositBadge), findsNWidgets(2));
    });
  });

  group('running out', () {
    testWidgets('the dashboard card: the soonest three, a count, See all',
        (tester) async {
      _deposits.ending = endingDeposits;
      final bloc = DepositsEndingBloc(_deposits)
        ..add(DepositsEndingLoadEvent());
      addTearDown(bloc.close);
      var seeAll = 0;
      await tester.pumpWidget(depositsCardApp(bloc, onSeeAll: () => seeAll++));
      await tester.pumpAndSettle();

      expect(find.text('DEPOSITS ENDING'), findsOneWidget);
      expect(find.byType(DepositRow), findsNWidgets(3));
      expect(find.text('4 in all'), findsOneWidget);
      expect(find.text('Hold ended 3 days ago'), findsOneWidget);
      expect(find.text('Hold ends today'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('deposits-see-all')));
      expect(seeAll, 1);
      await tester.tap(find.text('Dostyk 5'));
      await tester.pumpAndSettle();
      expect(find.text('deal 12'), findsOneWidget);
    });

    testWidgets('the dashboard card is not there when nothing runs out',
        (tester) async {
      final bloc = DepositsEndingBloc(_deposits)
        ..add(DepositsEndingLoadEvent());
      addTearDown(bloc.close);
      await tester.pumpWidget(depositsCardApp(bloc));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('deposits-hidden')), findsOneWidget);
      expect(find.byKey(const ValueKey('deposits-card')), findsNothing);
    });

    testWidgets('the dashboard card keeps a failure to itself, with a retry',
        (tester) async {
      _deposits.failEnding = true;
      final bloc = DepositsEndingBloc(_deposits)
        ..add(DepositsEndingLoadEvent());
      addTearDown(bloc.close);
      await tester.pumpWidget(depositsCardApp(bloc));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load the deposits"), findsOneWidget);
      _deposits.failEnding = false;
      _deposits.ending = endingDeposits.take(1).toList();
      await tester.tap(find.byKey(const ValueKey('deposits-retry')));
      await tester.pumpAndSettle();
      expect(find.byType(DepositRow), findsOneWidget);
    });
  });
}
