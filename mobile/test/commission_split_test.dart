import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_labels.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';
import 'package:real_estate_crm/features/commission_split/presentation/bloc/commission_split_bloc.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/commission_split_sheet.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/deal_commission_split_card.dart';
import 'package:real_estate_crm/features/commission_split/presentation/widgets/split_labels.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_detail_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'checklist_fixtures.dart';
import 'commission_split_fakes.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// A deal's commission split: the card on the deal, the editor sheet, what
/// the draft sends, the change log's words for it, and the layout at every
/// acceptance size with the longest names in all three languages.

const _commission = 1260000.0;

const _split = CommissionSplit(
  dealId: 1,
  commission: _commission,
  split: true,
  editable: true,
  shares: [
    CommissionShare(
        kind: CommissionPartyKind.AGENT,
        userId: 5,
        name: 'Aigul Bekova',
        percent: 50,
        amount: 630000),
    CommissionShare(
        kind: CommissionPartyKind.COLLEAGUE,
        userId: 9,
        name: 'Timur Aliev',
        percent: 30,
        amount: 378000),
    CommissionShare(
        kind: CommissionPartyKind.CO_BROKER,
        name: 'Ivan Petrovich Petrov-Vodkin',
        agency: 'Etazhi Real Estate Group Almaty Branch',
        percent: 20,
        amount: 252000),
  ],
  colleagues: [
    CommissionColleague(id: 9, fullName: 'Timur Aliev'),
    CommissionColleague(
        id: 11, fullName: 'Dana Seitova-Nurlanovna-Kassymova-Abenova'),
  ],
);

const _unsplit = CommissionSplit(
  dealId: 1,
  commission: _commission,
  editable: true,
  shares: [
    CommissionShare(
        kind: CommissionPartyKind.AGENT,
        userId: 5,
        name: 'Aigul Bekova',
        percent: 100,
        amount: _commission),
  ],
  colleagues: [
    CommissionColleague(id: 9, fullName: 'Timur Aliev'),
    CommissionColleague(id: 11, fullName: 'Dana Seitova'),
  ],
);

late FakeCommissionSplitRepository _repo;

Future<void> _pumpDeal(WidgetTester tester,
    {AuthResponse user = checklistAgent}) async {
  final deals = RecordingChecklistDeals();
  Injector.dealsRepository = deals;
  await expectNoOverflow(tester,
      withChecklistBlocs(const DealDetailScreen(id: 1), deals, user: user),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: const Locale('en'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('deal-split-card')));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _settle(WidgetTester tester, String what) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: what);
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final kk = lookupAppLocalizations(const Locale('kk'));

  setUp(() {
    _repo = FakeCommissionSplitRepository(byDeal: {1: _split});
    Injector.commissionSplitRepository = _repo;
  });
  tearDown(() {
    Injector.commissionSplitRepository = FakeCommissionSplitRepository();
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  group('the draft', () {
    SplitLineDraft agent(double? p) => SplitLineDraft(
        kind: CommissionPartyKind.AGENT, userId: 5, name: 'Aigul', percent: p);
    SplitLineDraft colleague(double? p) => SplitLineDraft(
        kind: CommissionPartyKind.COLLEAGUE,
        userId: 9,
        name: 'Timur',
        percent: p);
    SplitLineDraft broker(String name, double? p, {String? agency}) =>
        SplitLineDraft(
            kind: CommissionPartyKind.CO_BROKER,
            name: name,
            agency: agency,
            percent: p);

    test('a percentage is typed with a point or a comma', () {
      expect(parseSplitPercent('12,5'), 12.5);
      expect(parseSplitPercent(' 30 '), 30);
      expect(parseSplitPercent(''), isNull);
      expect(parseSplitPercent('a lot'), isNull);
    });

    test('the shares total exactly 100, counted in hundredths', () {
      expect(
          CommissionSplitDraft(
              [agent(33.33), colleague(33.33), broker('I', 33.34)]).isValid,
          isTrue);
      final short = CommissionSplitDraft([agent(50), colleague(40)]);
      expect(short.totalsHundred, isFalse);
      expect(short.total, 90);
      expect(short.isValid, isFalse);
    });

    test(
        'each share is above 0 with two decimals at most; the agent may hold none',
        () {
      expect(colleague(0).percentValid, isFalse);
      expect(colleague(100.5).percentValid, isFalse);
      expect(colleague(12.345).percentValid, isFalse);
      expect(colleague(null).percentValid, isFalse);
      expect(agent(0).percentValid, isTrue);
      expect(CommissionSplitDraft([agent(0), colleague(100)]).isValid, isTrue);
    });

    test('a co-broker needs a name; the agency is optional', () {
      expect(
          CommissionSplitDraft([agent(50), broker(' ', 50)]).isValid, isFalse);
      expect(CommissionSplitDraft([agent(50), broker('Ivan', 50)]).isValid,
          isTrue);
    });

    test(
        'the request names everyone with a share, and leaves out an agent with none',
        () {
      expect(
          CommissionSplitDraft([
            agent(0),
            colleague(70),
            broker(' Ivan Petrov ', 30, agency: ' '),
          ]).toJson(),
          {
            'shares': [
              {'userId': 9, 'percent': 70.0},
              {
                'coBrokerName': 'Ivan Petrov',
                'coBrokerAgency': null,
                'percent': 30.0
              },
            ],
          });
      expect(CommissionSplitDraft([agent(100)]).allToAgent, isTrue);
    });
  });

  group('words', () {
    test('a co-broker is named with their agency; a colleague who left says so',
        () {
      expect(splitPartyLabel(en, _split.shares[2]),
          'Co-broker, Etazhi Real Estate Group Almaty Branch');
      expect(splitPartyLabel(ru, _split.shares[0]), 'Агент сделки');
      expect(
          splitPartyLabel(
              kk,
              const CommissionShare(
                  kind: CommissionPartyKind.COLLEAGUE, active: false)),
          kk.splitsInactive);
      expect(splitPercentLabel(en, 12.5), '12.5%');
    });

    test('the change log says what the split was and became', () {
      const line = RecordChange(
          id: 1,
          entityType: ChangeEntityType.deal,
          field: 'commissionSplit',
          newValue: 'Aigul Bekova 50%, Ivan Petrov (Etazhi) 50%');
      expect(changeLineLabel(en, line, 'en'),
          'Commission split: Not split → Aigul Bekova 50%, Ivan Petrov (Etazhi) 50%');
      expect(changeFieldLabel(ru, 'commissionSplit'), 'Сплит комиссии');
      expect(
          changeLineLabel(
              kk,
              const RecordChange(
                  id: 2,
                  field: 'commissionSplit',
                  oldValue: 'Aigul Bekova 100%'),
              'kk'),
          contains(kk.splitsNotSplit));
    });

    test('a refusal the app knows reads in the reader\'s language', () {
      expect(
          splitFailureLabel(
              ru,
              const ApiFailure(ApiFailureKind.badRequest,
                  serverText: 'The shares have to add up to 100%, not 90%',
                  serverCode: 'SPLIT_TOTAL_NOT_100')),
          ru.splitsTotalMustBe100);
      expect(splitFailureLabel(en, const ApiFailure(ApiFailureKind.forbidden)),
          en.coreErrorForbidden);
    });
  });

  group('the card on the deal', () {
    testWidgets('shows who gets what, the agent first, each with the amount',
        (tester) async {
      await _pumpDeal(tester);
      final card = find.byKey(const Key('deal-split-card'));
      for (final name in [
        'Aigul Bekova',
        'Timur Aliev',
        'Ivan Petrovich Petrov-Vodkin'
      ]) {
        expect(find.descendant(of: card, matching: find.text(name)),
            findsOneWidget);
      }
      expect(find.descendant(of: card, matching: find.text('50%')),
          findsOneWidget);
      expect(
          find.descendant(of: card, matching: find.text(formatPrice(630000))),
          findsOneWidget);
      expect(
          find.descendant(of: card, matching: find.text(formatPrice(252000))),
          findsOneWidget);
      expect(find.text(en.splitsEdit), findsOneWidget);
    });

    testWidgets('a colleague with a share reads it but cannot change it',
        (tester) async {
      _repo.byDeal[1] = _split.copyWith(editable: false, colleagues: []);
      await _pumpDeal(tester, user: checklistColleague);
      expect(find.byKey(const Key('deal-split-edit')), findsNothing);
      expect(find.text('Timur Aliev'), findsWidgets);
    });

    testWidgets('an unsplit deal is all its agent\'s, with a way to split it',
        (tester) async {
      _repo.byDeal[1] = _unsplit;
      await _pumpDeal(tester);
      expect(find.text(en.splitsAllToAgent('Aigul Bekova')), findsOneWidget);
      expect(find.text(en.splitsAdd), findsOneWidget);
    });

    testWidgets('without a price or a rate it says when amounts will show',
        (tester) async {
      _repo.byDeal[1] = const CommissionSplit(dealId: 1, shares: [
        CommissionShare(
            kind: CommissionPartyKind.AGENT,
            name: 'Aigul Bekova',
            percent: 100),
      ]);
      await _pumpDeal(tester);
      expect(find.text(en.splitsAmountUnknown), findsOneWidget);
    });

    testWidgets('a split that will not load says so and retries',
        (tester) async {
      _repo.failLoad = true;
      await _pumpDeal(tester);
      expect(find.text(en.splitsLoadFailed), findsOneWidget);
      _repo.failLoad = false;
      await _tap(tester, find.byKey(const Key('deal-split-retry')));
      expect(find.text('Timur Aliev'), findsWidgets);
    });

    testWidgets(
        'the agent adds a co-broker, balances the rest to themselves and saves',
        (tester) async {
      _repo.byDeal[1] = _unsplit;
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-split-edit')));
      expect(find.byKey(const Key('split-save')), findsOneWidget);

      await _tap(tester, find.byKey(const Key('split-add-cobroker')));
      await tester.enterText(
          find.byKey(const Key('split-cobroker-name-1')), 'Ivan Petrov');
      await tester.enterText(
          find.byKey(const Key('split-cobroker-agency-1')), 'Etazhi');
      await tester.enterText(find.byKey(const Key('split-percent-1')), '25');
      await tester.pumpAndSettle();
      expect(find.text(en.splitsTotal('125')), findsOneWidget);
      expect(find.byKey(const Key('split-total-wrong')), findsOneWidget);
      expect(
          tester
              .widget<AppFilledButton>(find.byKey(const Key('split-save')))
              .onPressed,
          isNull);

      await _tap(tester, find.byKey(const Key('split-balance')));
      expect(find.text(en.splitsTotal('100')), findsOneWidget);
      await _tap(tester, find.byKey(const Key('split-save')));

      expect(_repo.saved, hasLength(1));
      expect(_repo.saved.single.$2.toJson(), {
        'shares': [
          {'userId': 5, 'percent': 75.0},
          {
            'coBrokerName': 'Ivan Petrov',
            'coBrokerAgency': 'Etazhi',
            'percent': 25.0
          },
        ],
      });
      expect(find.text(en.splitsCoBrokerFrom('Etazhi')), findsOneWidget);
      expect(find.text(en.splitsEdit), findsOneWidget);
    });

    testWidgets('a colleague is picked from the agency, once', (tester) async {
      _repo.byDeal[1] = _unsplit;
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-split-edit')));
      await _tap(tester, find.byKey(const Key('split-add-colleague')));
      await _tap(tester, find.text('Dana Seitova'));
      await tester.enterText(find.byKey(const Key('split-percent-0')), '60');
      await tester.enterText(find.byKey(const Key('split-percent-1')), '40');
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('split-add-colleague')));
      expect(find.text('Dana Seitova'), findsOneWidget,
          reason: 'only on the line; the picker offers Timur alone');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const Key('split-save')));
      expect(_repo.saved.single.$2.toJson()['shares'], [
        {'userId': 5, 'percent': 60.0},
        {'userId': 11, 'percent': 40.0},
      ]);
    });

    testWidgets('a share can be removed, and everything given back',
        (tester) async {
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-split-edit')));
      await _tap(tester, find.byKey(const Key('split-remove-2')));
      expect(find.byKey(const Key('split-cobroker-name-2')), findsNothing);
      await _tap(tester, find.byKey(const Key('split-clear')));
      expect(_repo.saved.single.$2.toJson(), {
        'shares': [
          {'userId': 5, 'percent': 100.0},
        ],
      });
      expect(find.text(en.splitsAllToAgent('Aigul Bekova')), findsOneWidget);
    });

    testWidgets('a refusal is worded in the reader\'s language',
        (tester) async {
      _repo.writeError = DioException(
        requestOptions: RequestOptions(path: '/deals/1/commission-split'),
        response: Response(
          requestOptions: RequestOptions(path: '/deals/1/commission-split'),
          statusCode: 400,
          data: {
            'code': 'SPLIT_COLLEAGUE_INACTIVE',
            'message': 'Timur Aliev is not an active member of the agency',
          },
        ),
      );
      await _pumpDeal(tester);
      await _tap(tester, find.byKey(const Key('deal-split-edit')));
      await _tap(tester, find.byKey(const Key('split-save')));
      expect(find.text(en.splitsColleagueInactive), findsOneWidget);
      expect(find.text(en.splitsEdit), findsOneWidget);
    });
  });

  group('layout', () {
    forEachAcceptanceCase('the split card and the share note',
        (tester, size, brightness, scale) async {
      for (final locale in kAcceptanceLocales) {
        final bloc = CommissionSplitBloc(_repo, dealId: 1)
          ..add(CommissionSplitLoadEvent());
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DealCommissionSplitCard(),
                      SizedBox(height: 12),
                      CommissionShareNote(),
                    ],
                  ),
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
        expect(find.byKey(const Key('deal-split-share-2')), findsOneWidget);
      }
    });

    forEachAcceptanceCase('the split editor',
        (tester, size, brightness, scale) async {
      for (final locale in kAcceptanceLocales) {
        await expectNoOverflow(
          tester,
          Scaffold(
            key: ValueKey(locale),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: CommissionSplitForm(
                split: _split.copyWith(shares: [
                  ..._split.shares,
                  const CommissionShare(
                      kind: CommissionPartyKind.CO_BROKER,
                      name: '',
                      percent: 0.5),
                ]),
                onConfirm: (_) {},
              ),
            ),
          ),
          size: size,
          brightness: brightness,
          textScale: scale,
          locale: locale,
        );
        await _settle(tester, 'editor, ${locale.languageCode}');
        expect(find.byKey(const Key('split-total-wrong')), findsOneWidget);
        expect(find.byKey(const Key('split-save')), findsOneWidget);
      }
    });
  });
}
