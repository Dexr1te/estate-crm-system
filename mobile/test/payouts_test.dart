import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/payout_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/commission_split/data/datasources/commission_split_remote_datasource.dart';
import 'package:real_estate_crm/features/commission_split/data/repositories/commission_split_repository_impl.dart';
import 'package:real_estate_crm/features/payouts/data/datasources/payouts_remote_datasource.dart';
import 'package:real_estate_crm/features/payouts/data/repositories/payouts_repository_impl.dart';
import 'package:real_estate_crm/features/payouts/presentation/bloc/payouts_bloc.dart';
import 'package:real_estate_crm/features/payouts/presentation/screens/payouts_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Payouts: what the agency still owes from split commissions and what it
/// has paid out — the models, the two repositories as they talk to the
/// server, the bloc, and the screen for a manager and for an agent, at every
/// acceptance size in all three languages.

final _wonAt = DateTime(2026, 9, 3, 12);
final _paidAt = DateTime(2026, 10, 2, 15, 30);

final _timur = PayoutItem(
  shareId: 21,
  dealId: 7,
  dealTitle: 'Flat to let, Abay avenue 150, apartment 48, eleventh floor',
  closedAt: _wonAt,
  agentId: 9,
  agentName: 'Timur Aliev',
  percent: 40,
  amount: 100000,
);

final _ivan = PayoutItem(
  shareId: 22,
  dealId: 8,
  dealTitle: 'Abay 10',
  closedAt: _wonAt,
  kind: CommissionPartyKind.CO_BROKER,
  agentName: 'Ivan Petrovich Petrov-Vodkin',
  agency: 'Etazhi Real Estate Group Almaty Branch',
  percent: 20,
);

final _dana = PayoutItem(
  shareId: 23,
  dealId: 8,
  dealTitle: 'Abay 10',
  closedAt: _wonAt,
  agentId: 11,
  agentName: 'Dana Seitova-Nurlanovna-Kassymova-Abenova',
  percent: 30,
  amount: 90000,
  paid: true,
  paidAt: _paidAt,
  paidById: 1,
  paidByName: 'Asel Nurlanovna Bekmukhambetova',
  note: 'Transfer 4411 from the agency account at Halyk, confirmed by phone',
);

const _owed = [
  PayoutPartyTotal(
      agentId: 9, name: 'Timur Aliev', unpaid: 1250000000, shares: 3),
  PayoutPartyTotal(
      kind: CommissionPartyKind.CO_BROKER,
      name: 'Ivan Petrovich Petrov-Vodkin',
      agency: 'Etazhi Real Estate Group Almaty Branch',
      unpaid: 60000,
      shares: 1),
];

PayoutList _manager(PayoutStatus status) => PayoutList(
      status: status,
      wholeTeam: true,
      unpaidTotal: 1250060000,
      paidTotal: 90000,
      byAgent: _owed,
      items: status == PayoutStatus.unpaid ? [_timur, _ivan] : [_dana],
    );

PayoutList _agent(PayoutStatus status) => PayoutList(
      status: status,
      unpaidTotal: 100000,
      paidTotal: 0,
      byAgent: const [
        PayoutPartyTotal(agentId: 9, name: 'Timur Aliev', unpaid: 100000),
      ],
      items: status == PayoutStatus.unpaid ? [_timur] : const [],
    );

late FakePayoutsRepository _repo;

FakePayoutsRepository _with(PayoutList Function(PayoutStatus) lists) {
  _repo = FakePayoutsRepository(byStatus: {
    for (final s in PayoutStatus.values) s: lists(s),
  });
  Injector.payoutsRepository = _repo;
  return _repo;
}

Future<void> _pumpScreen(WidgetTester tester,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, PayoutsScreen(key: ValueKey(locale)),
      size: size, brightness: brightness, textScale: scale, locale: locale);
  await tester.pumpAndSettle();
}

/// The tab reading [label]: "Выплачено" is a tab and a total in Russian.
Finder _tab(String label) => find.descendant(
    of: find.byKey(const Key('payouts-tabs')), matching: find.text(label));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// The server, answering whatever was asked with [body] and remembering it.
class _Host implements HttpClientAdapter {
  final Object body;
  final asked = <RequestOptions>[];
  _Host(this.body);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    asked.add(options);
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final en = lookupAppLocalizations(const Locale('en'));

  setUp(() => _with(_manager));
  tearDown(() => Injector.payoutsRepository = FakePayoutsRepository());

  group('the models', () {
    test('read the server\'s list, a co-broker without an account included',
        () {
      final list = PayoutList.fromJson({
        'status': 'PAID',
        'wholeTeam': true,
        'unpaidTotal': 160000.00,
        'paidTotal': 90000,
        'byAgent': [
          {
            'kind': 'CO_BROKER',
            'agentId': null,
            'name': 'Ivan Petrov',
            'agency': 'Etazhi',
            'unpaid': 60000.00,
            'shares': 1
          },
        ],
        'items': [
          {
            'shareId': 23,
            'dealId': 8,
            'dealTitle': 'Abay 10',
            'closedAt': '2026-09-03T12:00:00',
            'kind': 'COLLEAGUE',
            'agentId': 11,
            'agentName': 'Dana Seitova',
            'percent': 30.00,
            'amount': 90000.00,
            'paid': true,
            'paidAt': '2026-10-02T15:30:00.123456',
            'paidById': 1,
            'paidByName': 'Asel Nurlanovna',
            'note': 'Cash',
          },
          {'shareId': 24, 'dealId': 9, 'kind': 'SOMETHING_NEW'},
        ],
      });
      expect(list.status, PayoutStatus.paid);
      expect(list.wholeTeam, isTrue);
      expect(list.unpaidTotal, 160000);
      expect(list.byAgent.single.kind, CommissionPartyKind.CO_BROKER);
      expect(list.byAgent.single.agentId, isNull);
      final dana = list.items.first;
      expect(dana.paid, isTrue);
      expect(dana.paidAt, DateTime(2026, 10, 2, 15, 30, 0, 123, 456));
      expect(dana.closedAt, DateTime(2026, 9, 3, 12));
      expect(dana.amount, 90000);
      expect(dana.note, 'Cash');
      final bare = list.items.last;
      expect(bare.amount, isNull, reason: 'no price or rate yet');
      expect(bare.paid, isFalse);
      expect(bare.kind, CommissionPartyKind.CO_BROKER);
      expect(PayoutList.fromJson(const {}).status, PayoutStatus.unpaid);
    });
  });

  group('the repositories', () {
    late SessionStore session;

    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      session = SessionStore();
      await session.load();
    });

    test('the payouts list asks for one status, and one colleague if named',
        () async {
      final host = _Host({'status': 'PAID', 'wholeTeam': true, 'items': []});
      final repo = PayoutsRepositoryImpl(
          PayoutsRemoteDataSource(ApiClient(session, adapter: host)));

      final list = await repo.getPayouts(status: PayoutStatus.paid, agentId: 9);
      expect(list.status, PayoutStatus.paid);
      expect(host.asked.single.method, 'GET');
      expect(host.asked.single.path, '/payouts');
      expect(
          host.asked.single.queryParameters, {'status': 'PAID', 'agentId': 9});

      await repo.getPayouts(status: PayoutStatus.unpaid);
      expect(host.asked.last.queryParameters, {'status': 'UNPAID'});
    });

    test('a share is marked paid with its note, and undone, on its deal',
        () async {
      final host = _Host({
        'dealId': 5,
        'won': true,
        'payoutsEditable': true,
        'shares': [
          {'kind': 'AGENT', 'userId': 1, 'percent': 70},
          {
            'id': 12,
            'kind': 'COLLEAGUE',
            'userId': 9,
            'percent': 30,
            'paid': true,
            'paidAt': '2026-10-02T15:30:00',
            'paidById': 1,
            'paidByName': 'Asel',
            'payoutNote': 'Cash'
          },
        ],
      });
      final repo = CommissionSplitRepositoryImpl(
          CommissionSplitRemoteDataSource(ApiClient(session, adapter: host)));

      final split = await repo.markPaid(5, 12, note: 'Cash');
      expect(host.asked.single.method, 'POST');
      expect(
          host.asked.single.path, '/deals/5/commission-split/shares/12/payout');
      expect(host.asked.single.data, {'note': 'Cash'});
      expect(split.won, isTrue);
      expect(split.payoutsEditable, isTrue);
      expect(split.shares.first.id, isNull);
      expect(split.shares.last.id, 12);
      expect(split.shares.last.paid, isTrue);
      expect(split.shares.last.paidAt, DateTime(2026, 10, 2, 15, 30));
      expect(split.shares.last.paidByName, 'Asel');
      expect(split.shares.last.payoutNote, 'Cash');

      await repo.undoPayout(5, 12);
      expect(host.asked.last.method, 'DELETE');
      expect(
          host.asked.last.path, '/deals/5/commission-split/shares/12/payout');
    });
  });

  group('the bloc', () {
    test('opens on the unpaid shares and switches tabs', () async {
      final bloc = PayoutsBloc(_repo)..add(PayoutsLoadEvent());
      addTearDown(bloc.close);
      final unpaid =
          await bloc.stream.firstWhere((s) => s.load == PayoutsLoad.loaded);
      expect(unpaid.tab, PayoutStatus.unpaid);
      expect(unpaid.list!.items, hasLength(2));

      bloc.add(PayoutsTabChanged(PayoutStatus.paid));
      final switching = await bloc.stream.first;
      expect(switching.tab, PayoutStatus.paid);
      expect(switching.load, PayoutsLoad.loading);
      expect(switching.list!.unpaidTotal, 1250060000,
          reason: 'the totals stay while the other tab loads');
      final paid =
          await bloc.stream.firstWhere((s) => s.load == PayoutsLoad.loaded);
      expect(paid.list!.items.single.shareId, 23);
      expect(_repo.asked, [PayoutStatus.unpaid, PayoutStatus.paid]);

      bloc.add(PayoutsTabChanged(PayoutStatus.paid));
      await Future<void>.delayed(Duration.zero);
      expect(_repo.asked, hasLength(2), reason: 'already on that tab');
    });

    test('a failed read says so, and a retry recovers', () async {
      _repo.failLoad = true;
      final bloc = PayoutsBloc(_repo)..add(PayoutsLoadEvent());
      addTearDown(bloc.close);
      final failed =
          await bloc.stream.firstWhere((s) => s.load == PayoutsLoad.error);
      expect(failed.failure, isNotNull);
      expect(failed.list, isNull);

      _repo.failLoad = false;
      bloc.add(PayoutsLoadEvent());
      final loaded =
          await bloc.stream.firstWhere((s) => s.load == PayoutsLoad.loaded);
      expect(loaded.failure, isNull);
      expect(loaded.list!.items, hasLength(2));
    });
  });

  group('the screen', () {
    testWidgets(
        'a manager sees what is owed and paid, who is owed what, and each share',
        (tester) async {
      await _pumpScreen(tester);
      final totals = find.byKey(const Key('payouts-totals'));
      expect(
          find.descendant(
              of: totals, matching: find.text(formatPrice(1250060000))),
          findsOneWidget);
      expect(
          find.descendant(of: totals, matching: find.text(formatPrice(90000))),
          findsOneWidget);
      expect(find.text(en.payoutsUnpaidTotal), findsOneWidget);
      expect(find.text(en.payoutsPaidTotal), findsOneWidget);

      final owed = find.byKey(const Key('payouts-by-agent'));
      expect(find.descendant(of: owed, matching: find.text('Timur Aliev')),
          findsOneWidget);
      expect(
          find.descendant(
              of: owed, matching: find.text(formatPrice(1250000000))),
          findsOneWidget);
      expect(find.text(en.payoutsShareCount(3)), findsOneWidget);
      expect(
          find.text(
              '${en.splitsCoBrokerFrom('Etazhi Real Estate Group Almaty Branch')} · ${en.payoutsShareCount(1)}'),
          findsOneWidget);

      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('payout-22')), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Timur Aliev · 40%'), findsOneWidget);
      expect(find.text(en.payoutsNoAmount), findsOneWidget,
          reason: 'a deal with no price or rate yet');
      expect(find.text(en.payoutsWonOn(formatFullDate(_wonAt, 'en'))),
          findsNWidgets(2));
      expect(find.text(en.payoutsUnpaid), findsWidgets);
    });

    testWidgets('the paid tab names who marked each payout, and the note',
        (tester) async {
      await _pumpScreen(tester);
      await _tap(tester, _tab(en.payoutsPaid));
      expect(_repo.asked.last, PayoutStatus.paid);
      expect(find.byKey(const Key('payouts-by-agent')), findsNothing,
          reason: 'what is still owed belongs on the unpaid tab');
      expect(find.byKey(const ValueKey('payout-23')), findsOneWidget);
      expect(find.text(en.payoutsPaidOn(formatFullDate(_paidAt, 'en'))),
          findsOneWidget);
      expect(find.text(en.payoutsMarkedBy('Asel Nurlanovna Bekmukhambetova')),
          findsOneWidget);
      expect(find.textContaining('Transfer 4411'), findsOneWidget);
      expect(find.byKey(const ValueKey('payout-21')), findsNothing);
    });

    testWidgets('an agent sees what is owed to them, and nobody else\'s',
        (tester) async {
      _with(_agent);
      await _pumpScreen(tester);
      expect(find.text(en.payoutsOwedToYou), findsOneWidget);
      expect(find.text(en.payoutsPaidToYou), findsOneWidget);
      expect(find.byKey(const Key('payouts-by-agent')), findsNothing);
      expect(find.text(en.payoutsScopeNote), findsNothing);
      expect(find.text('40%'), findsOneWidget,
          reason: 'their own share needs no name');
      expect(find.textContaining('Timur Aliev'), findsNothing);

      await _tap(tester, _tab(en.payoutsPaid));
      expect(find.byKey(const Key('payouts-empty')), findsOneWidget);
      expect(find.text(en.payoutsEmptyPaid), findsOneWidget);
    });

    testWidgets('nothing owed says so', (tester) async {
      _with((s) => PayoutList(status: s, wholeTeam: true));
      await _pumpScreen(tester);
      expect(find.text(en.payoutsEmptyUnpaid), findsOneWidget);
      expect(find.byKey(const Key('payouts-by-agent')), findsNothing);
    });

    testWidgets('a list that will not load says so and retries',
        (tester) async {
      _repo.failLoad = true;
      await _pumpScreen(tester);
      expect(find.text(en.payoutsLoadFailed), findsOneWidget);
      _repo.failLoad = false;
      await _tap(tester, find.byKey(const Key('payouts-retry')));
      expect(find.byKey(const ValueKey('payout-21')), findsOneWidget);
    });

    testWidgets('a share opens its deal, and the list reads again on return',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/payouts',
        routes: [
          GoRoute(path: '/payouts', builder: (_, __) => const PayoutsScreen()),
          GoRoute(
              path: '/deals/:id',
              builder: (_, s) => Scaffold(
                  body: Text('deal ${s.pathParameters['id']}',
                      maxLines: 1, overflow: TextOverflow.ellipsis))),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ));
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const ValueKey('payout-21')));
      expect(find.text('deal 7'), findsOneWidget);
      expect(_repo.asked, hasLength(1));

      router.pop();
      await tester.pumpAndSettle();
      expect(_repo.asked, hasLength(2));
      expect(find.byKey(const ValueKey('payout-21')), findsOneWidget);
    });
  });

  group('layout', () {
    forEachAcceptanceCase('payouts for a manager',
        (tester, size, brightness, scale) async {
      for (final locale in kAcceptanceLocales) {
        await _pumpScreen(tester,
            size: size, brightness: brightness, scale: scale, locale: locale);
        expect(tester.takeException(), isNull,
            reason: 'manager, ${locale.languageCode}');
        expect(find.byKey(const Key('payouts-totals')), findsOneWidget);
      }
    });

    forEachAcceptanceCase('paid payouts for a manager',
        (tester, size, brightness, scale) async {
      for (final locale in kAcceptanceLocales) {
        await _pumpScreen(tester,
            size: size, brightness: brightness, scale: scale, locale: locale);
        await tester.tap(_tab(lookupAppLocalizations(locale).payoutsPaid));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'paid, ${locale.languageCode}');
        expect(find.byKey(const ValueKey('payout-23')), findsOneWidget);
      }
    });

    forEachAcceptanceCase('payouts for an agent',
        (tester, size, brightness, scale) async {
      _with(_agent);
      for (final locale in kAcceptanceLocales) {
        await _pumpScreen(tester,
            size: size, brightness: brightness, scale: scale, locale: locale);
        expect(tester.takeException(), isNull,
            reason: 'agent, ${locale.languageCode}');
        expect(find.byKey(const ValueKey('payout-21')), findsOneWidget);
      }
    });
  });
}
