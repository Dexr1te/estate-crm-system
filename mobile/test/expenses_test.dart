import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/expense_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/expenses/data/datasources/expenses_remote_datasource.dart';
import 'package:real_estate_crm/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:real_estate_crm/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:real_estate_crm/features/expenses/presentation/bloc/expense_summary_bloc.dart';
import 'package:real_estate_crm/features/expenses/presentation/bloc/property_expenses_bloc.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/expense_labels.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/expense_sheet.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/marketing_spend_card.dart';
import 'package:real_estate_crm/features/expenses/presentation/widgets/property_expenses_card.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'expenses_fixtures.dart';
import 'fakes.dart';
import 'responsive_harness.dart';

/// Listing expenses: the models and how they read the server, the repository
/// against a recorded host, the two blocs, the card on a listing with its add
/// sheet and delete, and the marketing spend card on the analytics screen.

/// The backend, answering from [bodies] by path and remembering every request.
class _Host implements HttpClientAdapter {
  final Map<String, Object?> bodies;
  final requests = <RequestOptions>[];
  _Host(this.bodies);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final body = bodies['${options.method} ${options.path}'];
    return ResponseBody.fromString(
        body == null ? '' : jsonEncode(body), body == null ? 204 : 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

/// Answers each summary only when the test says so, to show that a slow
/// answer to an older period never replaces the newer one.
class _GatedSummaries extends FakeExpensesRepository {
  final gates = <Completer<ExpenseSummary>>[];

  @override
  Future<ExpenseSummary> getSummary(
      {required DateTime from, required DateTime to}) {
    summaryRequests.add((from: from, to: to));
    final gate = Completer<ExpenseSummary>();
    gates.add(gate);
    return gate.future;
  }
}

Future<AuthBloc> _signedIn(AuthResponse user) async {
  final auth = AuthBloc(FakeAuthRepository(user: user))..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  return auth;
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _showCard(WidgetTester tester,
    {Locale locale = const Locale('en')}) async {
  await expectNoOverflow(
    tester,
    Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PropertyExpensesCard(key: ValueKey(locale), propertyId: 7),
      ),
    ),
    size: const Size(390, 844),
    brightness: Brightness.light,
    textScale: 1.0,
    locale: locale,
  );
  await tester.pumpAndSettle();
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final kk = lookupAppLocalizations(const Locale('kk'));
  late FakeExpensesRepository repo;

  setUpAll(initializeDateFormatting);

  setUp(() {
    AppClock.freeze(expensesNow);
    repo = FakeExpensesRepository(
      byProperty: {7: expenseFixtures()},
      summary: summaryFixture,
    );
    Injector.expensesRepository = repo;
  });
  tearDown(() {
    AppClock.reset();
    Injector.expensesRepository = FakeExpensesRepository();
  });

  group('the models', () {
    test('a listing\'s expenses read the server, money and days included', () {
      final read = PropertyExpenses.fromJson({
        'items': [
          {
            'id': 3,
            'propertyId': 7,
            'category': 'ADVERTISING',
            'amount': 30000.5,
            'spentOn': '2026-09-24',
            'note': 'Krisha.kz, top for a week',
            'createdById': 5,
            'createdByName': 'Maria Kim',
            'createdAt': '2026-09-24T10:15:00',
            'canDelete': true,
          },
          {
            'id': 1,
            'propertyId': 7,
            'category': 'SOMETHING_NEW',
            'amount': 100,
            'spentOn': '2026-09-01',
          },
        ],
        'total': 30100.5,
        'byCategory': [
          {'category': 'ADVERTISING', 'total': 30000.5},
          {'category': 'OTHER', 'total': 100},
        ],
      });

      final ad = read.items.first;
      expect(ad.category, ExpenseCategory.advertising);
      expect(ad.amount, 30000.5);
      expect(ad.spentOn, DateTime(2026, 9, 24));
      expect(ad.createdByName, 'Maria Kim');
      expect(ad.canDelete, isTrue);
      expect(read.items.last.category, ExpenseCategory.other,
          reason: 'a category the app does not know yet reads as other');
      expect(read.items.last.canDelete, isFalse);
      expect(read.total, 30100.5);
      expect(read.byCategory.map((c) => c.category),
          [ExpenseCategory.advertising, ExpenseCategory.other]);
    });

    test('a summary reads its period, categories and top listings', () {
      final s = ExpenseSummary.fromJson({
        'from': '2026-09-01',
        'to': '2026-09-30',
        'total': 125000,
        'byCategory': [
          {'category': 'PHOTO', 'total': 125000}
        ],
        'topListings': [
          {'propertyId': 12, 'title': 'Esentai City, apt 12', 'total': 125000}
        ],
      });
      expect(s.from, DateTime(2026, 9));
      expect(s.to, DateTime(2026, 9, 30));
      expect(s.total, 125000);
      expect(s.topListings.single.propertyId, 12);
      expect(s.topListings.single.title, 'Esentai City, apt 12');
    });

    test('worked out again from the items, the way the server does', () {
      final list = PropertyExpenses.of(expenseFixtures());
      expect(list.items.map((e) => e.id), [4, 3, 2, 1],
          reason: 'the latest paid first, the later id first on one day');
      expect(list.total, 120500);
      expect(list.byCategory.map((c) => (c.category, c.total)), [
        (ExpenseCategory.staging, 60000.0),
        (ExpenseCategory.photo, 45000.0),
        (ExpenseCategory.advertising, 15500.0),
      ]);

      final fewer = list.removing(4);
      expect(fewer.total, 60500);
      expect(fewer.byCategory.first.category, ExpenseCategory.photo);
    });

    test('a draft says what the server takes, trimmed', () {
      final draft = ExpenseDraft(
          category: ExpenseCategory.legal,
          amount: 25000,
          spentOn: DateTime(2026, 9, 25, 18, 30),
          note: '  Notary  ');
      expect(draft.toJson(), {
        'category': 'LEGAL',
        'amount': 25000.0,
        'spentOn': '2026-09-25',
        'note': 'Notary',
      });
      expect(
          ExpenseDraft(
                  category: ExpenseCategory.other,
                  amount: 1,
                  spentOn: DateTime(2026, 9, 25),
                  note: '   ')
              .toJson()
              .containsKey('note'),
          isFalse);

      final today = DateTime(2026, 9, 25, 9);
      expect(draft.isValidOn(today), isTrue, reason: 'paid today is fine');
      ExpenseDraft with_({double amount = 1, DateTime? on, String? note}) =>
          ExpenseDraft(
              category: ExpenseCategory.photo,
              amount: amount,
              spentOn: on ?? DateTime(2026, 9, 1),
              note: note);
      expect(with_(amount: 0).isValidOn(today), isFalse);
      expect(with_(on: DateTime(2026, 9, 26)).isValidOn(today), isFalse);
      expect(with_(note: 'x' * 500).isValidOn(today), isTrue);
      expect(with_(note: 'x' * 501).isValidOn(today), isFalse);
    });

    test('an amount reads as typed, thousands and decimal commas alike', () {
      expect(parseExpenseAmount('45000'), 45000);
      expect(parseExpenseAmount('45 000'), 45000);
      expect(parseExpenseAmount('45 000'), 45000);
      expect(parseExpenseAmount('45,000'), 45000);
      expect(parseExpenseAmount('1,234,567.89'), 1234567.89);
      expect(parseExpenseAmount('45,5'), 45.5);
      expect(parseExpenseAmount('45 000,50'), 45000.5);
      expect(parseExpenseAmount('12.346'), 12.35);
      expect(parseExpenseAmount(''), 0);
      expect(parseExpenseAmount('many'), 0);
    });

    test('every category is named in all three languages, never raw', () {
      for (final l10n in [en, ru, kk]) {
        final labels =
            ExpenseCategory.values.map((c) => expenseCategoryLabel(l10n, c));
        expect(labels.toSet(), hasLength(ExpenseCategory.values.length));
        for (final c in ExpenseCategory.values) {
          expect(expenseCategoryLabel(l10n, c), isNot(c.wire));
        }
      }
      expect(expenseCategoryLabel(ru, ExpenseCategory.cleaning), 'Уборка');
      expect(expenseCategoryLabel(kk, ExpenseCategory.advertising), 'Жарнама');
    });
  });

  group('the repository', () {
    late _Host host;
    late ExpensesRepository remote;

    setUp(() {
      host = _Host({
        'GET /properties/7/expenses': {
          'items': [
            {
              'id': 3,
              'propertyId': 7,
              'category': 'PHOTO',
              'amount': 45000,
              'spentOn': '2026-09-20',
              'canDelete': true,
            }
          ],
          'total': 45000,
          'byCategory': [
            {'category': 'PHOTO', 'total': 45000}
          ],
        },
        'POST /properties/7/expenses': {
          'id': 9,
          'propertyId': 7,
          'category': 'STAGING',
          'amount': 60000,
          'spentOn': '2026-09-25',
          'canDelete': true,
        },
        'GET /expenses/summary': {'total': 0},
      });
      remote = ExpensesRepositoryImpl(
          ExpensesRemoteDataSource(ApiClient(SessionStore(), adapter: host)));
    });

    test('reads a listing\'s expenses from its own address', () async {
      final read = await remote.getForProperty(7);
      expect(host.requests.single.method, 'GET');
      expect(host.requests.single.path, '/properties/7/expenses');
      expect(read.items.single.category, ExpenseCategory.photo);
      expect(read.total, 45000);
    });

    test('records one with the server\'s names and a plain date', () async {
      final saved = await remote.create(
          7,
          ExpenseDraft(
              category: ExpenseCategory.staging,
              amount: 60000,
              spentOn: DateTime(2026, 9, 25)));
      final sent = host.requests.single;
      expect(sent.method, 'POST');
      expect(sent.data, {
        'category': 'STAGING',
        'amount': 60000.0,
        'spentOn': '2026-09-25',
      });
      expect(saved.id, 9);
    });

    test('deletes one through its listing', () async {
      await remote.delete(7, 3);
      expect(host.requests.single.method, 'DELETE');
      expect(host.requests.single.path, '/properties/7/expenses/3');
    });

    test('asks the summary for both days of the period', () async {
      await remote.getSummary(
          from: DateTime(2026, 7), to: DateTime(2026, 9, 30));
      expect(host.requests.single.path, '/expenses/summary');
      expect(host.requests.single.queryParameters,
          {'from': '2026-07-01', 'to': '2026-09-30'});
    });
  });

  group('the listing bloc', () {
    test('loads, then applies what it records and deletes, totals and all',
        () async {
      final bloc = PropertyExpensesBloc(repo, propertyId: 7)
        ..add(PropertyExpensesLoadEvent());
      addTearDown(bloc.close);
      await bloc.stream
          .firstWhere((s) => s.status == PropertyExpensesStatus.loaded);
      expect(bloc.state.expenses.total, 120500);

      bloc.add(PropertyExpensesAddEvent(ExpenseDraft(
          category: ExpenseCategory.cleaning,
          amount: 9500,
          spentOn: DateTime(2026, 9, 25))));
      await bloc.stream.firstWhere((s) => s.saved == 1);
      expect(repo.created.single.$1, 7);
      expect(bloc.state.expenses.total, 130000);
      expect(
          bloc.state.expenses.items.first.category, ExpenseCategory.cleaning);

      bloc.add(PropertyExpensesDeleteEvent(4));
      await bloc.stream.firstWhere((s) => s.saved == 2);
      expect(repo.deleted.single, (7, 4));
      expect(bloc.state.expenses.total, 70000);
      expect(bloc.state.expenses.items.any((e) => e.id == 4), isFalse);
    });

    test('a refused write says so and leaves the list as it was', () async {
      final bloc = PropertyExpensesBloc(repo, propertyId: 7)
        ..add(PropertyExpensesLoadEvent());
      addTearDown(bloc.close);
      await bloc.stream
          .firstWhere((s) => s.status == PropertyExpensesStatus.loaded);

      repo.writeError = DioException(
          requestOptions: RequestOptions(path: '/properties/7/expenses/4'),
          response: Response<dynamic>(
              requestOptions: RequestOptions(), statusCode: 403));
      bloc.add(PropertyExpensesDeleteEvent(4));
      final failed = await bloc.stream.firstWhere((s) => s.outcome != null);
      expect(failed.outcome!.isFailure, isTrue);
      expect(failed.saving, isFalse);
      expect(failed.expenses.total, 120500);
    });

    test('a failed first read is an error the card can retry', () async {
      repo.failLoad = true;
      final bloc = PropertyExpensesBloc(repo, propertyId: 7)
        ..add(PropertyExpensesLoadEvent());
      addTearDown(bloc.close);
      await bloc.stream
          .firstWhere((s) => s.status == PropertyExpensesStatus.error);

      repo.failLoad = false;
      bloc.add(PropertyExpensesLoadEvent());
      await bloc.stream
          .firstWhere((s) => s.status == PropertyExpensesStatus.loaded);
      expect(bloc.state.expenses.items, hasLength(4));
    });
  });

  group('the summary bloc', () {
    test('only the latest period asked for is shown', () async {
      final gated = _GatedSummaries();
      final bloc = ExpenseSummaryBloc(gated);
      addTearDown(bloc.close);

      bloc.add(ExpenseSummaryLoadEvent(
          from: DateTime(2026, 9), to: DateTime(2026, 9, 30)));
      bloc.add(ExpenseSummaryLoadEvent(
          from: DateTime(2026), to: DateTime(2026, 12, 31)));
      await pumpEventQueue();
      expect(gated.gates, hasLength(2));

      gated.gates[1].complete(const ExpenseSummary(total: 900));
      await bloc.stream.firstWhere((s) => s is ExpenseSummaryLoaded);
      gated.gates[0].complete(const ExpenseSummary(total: 1));
      await pumpEventQueue();

      final shown = bloc.state as ExpenseSummaryLoaded;
      expect(shown.summary.total, 900);
    });

    test('a failure is shown, and retry asks for the same period again',
        () async {
      repo.summaryError = Exception('offline');
      final bloc = ExpenseSummaryBloc(repo)
        ..add(ExpenseSummaryLoadEvent(
            from: DateTime(2026, 7), to: DateTime(2026, 9, 30)));
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((s) => s is ExpenseSummaryError);

      repo.summaryError = null;
      bloc.add(ExpenseSummaryRetryEvent());
      await bloc.stream.firstWhere((s) => s is ExpenseSummaryLoaded);
      expect(repo.summaryRequests.map((r) => (r.from, r.to)).toSet(),
          {(DateTime(2026, 7), DateTime(2026, 9, 30))});
    });
  });

  group('the card on a listing', () {
    testWidgets('the total, each category by name and the latest three',
        (tester) async {
      await _showCard(tester);

      expect(find.text('EXPENSES'), findsOneWidget);
      expect(find.text(r'$120,500'), findsOneWidget);
      expect(find.text('Staging'), findsWidgets);
      expect(find.text('Photography'), findsWidgets);
      expect(find.text('Advertising'), findsWidgets);
      expect(find.text('STAGING'), findsNothing);
      expect(find.byType(ExpenseRow), findsNWidgets(expensesRecentShown));

      await _tap(
          tester, find.byKey(const ValueKey('property-expenses-show-all')));
      expect(find.byType(ExpenseRow), findsNWidgets(4));
      expect(find.text('Sep 20 · Maria Kim · 40 shots, two drone'),
          findsOneWidget);
    });

    testWidgets('delete shows only where it is allowed, and asks first',
        (tester) async {
      await _showCard(tester);

      expect(find.byKey(const ValueKey('expense-delete-4')), findsOneWidget);
      expect(find.byKey(const ValueKey('expense-delete-3')), findsNothing,
          reason: 'a colleague\'s expense is theirs or a manager\'s to delete');

      await _tap(tester, find.byKey(const ValueKey('expense-delete-4')));
      expect(find.text('Delete this expense?'), findsOneWidget);
      expect(
          find.text(
              r'Staging, $60,000: it will no longer count towards this listing.'),
          findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.deleted, isEmpty);

      await _tap(tester, find.byKey(const ValueKey('expense-delete-4')));
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(repo.deleted.single, (7, 4));
      expect(find.text(r'$60,500'), findsOneWidget);
    });

    testWidgets('the add sheet records a category, an amount and a day',
        (tester) async {
      await _showCard(tester);

      await _tap(tester, find.byKey(const ValueKey('property-expenses-add')));
      expect(find.text('New expense'), findsOneWidget);
      final save = find.byKey(const Key('expense-save'));
      await _tap(tester, save);
      expect(repo.created, isEmpty, reason: 'nothing chosen yet');
      expect(find.text('New expense'), findsOneWidget);

      await _tap(tester, find.byKey(const Key('expense-category-cleaning')));
      await tester.enterText(find.byKey(const Key('expense-amount')), '9 500');
      await tester.enterText(
          find.byKey(const Key('expense-note')), ' After the tenants ');
      await tester.pumpAndSettle();
      await _tap(tester, save);

      final (propertyId, draft) = repo.created.single;
      expect(propertyId, 7);
      expect(draft.category, ExpenseCategory.cleaning);
      expect(draft.amount, 9500);
      expect(draft.spentOn, DateTime(2026, 9, 25));
      expect(draft.toJson()['note'], 'After the tenants');
      expect(find.text(r'$130,000'), findsOneWidget);
    });

    testWidgets('a note longer than the server keeps holds the save back',
        (tester) async {
      await _showCard(tester);
      await _tap(tester, find.byKey(const ValueKey('property-expenses-add')));
      await _tap(tester, find.byKey(const Key('expense-category-photo')));
      await tester.enterText(find.byKey(const Key('expense-amount')), '100');
      await tester.enterText(find.byKey(const Key('expense-note')), 'x' * 501);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('expense-note-too-long')), findsOneWidget);
      await tester.tap(find.byKey(const Key('expense-save')),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(repo.created, isEmpty);
    });

    testWidgets('nothing spent reads as such, with the way to record one',
        (tester) async {
      repo.byProperty = {};
      await _showCard(tester, locale: const Locale('ru'));
      expect(
          find.byKey(const ValueKey('property-expenses-none')), findsOneWidget);
      expect(find.text('Добавить расход'), findsOneWidget);
      expect(find.byType(ExpenseRow), findsNothing);
    });

    testWidgets('a failed read offers a retry', (tester) async {
      repo.failLoad = true;
      await _showCard(tester);
      expect(find.text('Could not load the expenses'), findsOneWidget);

      repo.failLoad = false;
      await _tap(tester, find.byKey(const ValueKey('property-expenses-retry')));
      expect(find.text(r'$120,500'), findsOneWidget);
    });

    testWidgets('the listing\'s detail screen carries the card',
        (tester) async {
      Injector.propertiesRepository = FakePropertiesRepository(const [
        PropertyResponse(id: 7, title: 'Severny Residence, apt 84', price: 1),
      ]);
      addTearDown(() =>
          Injector.propertiesRepository = FakePropertiesRepository(const []));
      await expectNoOverflow(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
            BlocProvider(
                create: (_) =>
                    PropertiesBloc(FakePropertiesRepository(const []))),
          ],
          child: const PropertyDetailScreen(id: 7),
        ),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.pumpAndSettle();
      final card = find.byKey(const ValueKey('property-expenses'));
      await tester.scrollUntilVisible(card, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);
      expect(find.text(r'$120,500'), findsOneWidget);
    });
  });

  group('marketing spend on the analytics screen', () {
    const manager = AuthResponse(
        userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

    setUp(() {
      Injector.analyticsRepository = FakeAnalyticsRepository(const DealFunnel(
          created: 3, won: 1, wonValue: 1000000, avgDaysToWin: 4));
    });

    Future<void> showAnalytics(WidgetTester tester) async {
      final auth = await _signedIn(manager);
      await expectNoOverflow(
        tester,
        BlocProvider.value(value: auth, child: const AnalyticsScreen()),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the total, each category and the costliest listings',
        (tester) async {
      await showAnalytics(tester);
      final card = find.byKey(const ValueKey('marketing-spend'));
      await tester.scrollUntilVisible(card, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      expect(find.text('MARKETING SPEND'), findsOneWidget);
      expect(find.text(r'$185,000'), findsOneWidget);
      expect(find.byKey(const ValueKey('marketing-spend-advertising')),
          findsOneWidget);
      expect(find.text('Costliest listings'), findsOneWidget);
      expect(find.text('Esentai City, apt 12'), findsOneWidget);
      expect(find.text('ADVERTISING'), findsNothing);
    });

    testWidgets('it follows the period tabs, both days of each included',
        (tester) async {
      await showAnalytics(tester);
      expect(repo.summaryRequests.last,
          (from: DateTime(2026, 9), to: DateTime(2026, 9, 30)));

      await tester.tap(find.text('Quarter'));
      await tester.pumpAndSettle();
      expect(repo.summaryRequests.last,
          (from: DateTime(2026, 7), to: DateTime(2026, 9, 30)));

      await tester.tap(find.text('Year'));
      await tester.pumpAndSettle();
      expect(repo.summaryRequests.last,
          (from: DateTime(2026), to: DateTime(2026, 12, 31)));
    });

    testWidgets('a period with deals and nothing spent says so',
        (tester) async {
      repo.summary = const ExpenseSummary();
      await showAnalytics(tester);
      final none = find.byKey(const ValueKey('marketing-spend-none'));
      await tester.scrollUntilVisible(none, 300,
          scrollable: find.byType(Scrollable).first);
      expect(none, findsOneWidget);
    });

    testWidgets('a listing opens on tap', (tester) async {
      final opened = <int>[];
      final bloc = ExpenseSummaryBloc(repo)
        ..add(ExpenseSummaryLoadEvent(
            from: DateTime(2026, 9), to: DateTime(2026, 9, 30)));
      addTearDown(bloc.close);
      await expectNoOverflow(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BlocProvider.value(
              value: bloc,
              child: MarketingSpendCard(onOpenListing: opened.add),
            ),
          ),
        ),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.pumpAndSettle();
      await _tap(
          tester, find.byKey(const ValueKey('marketing-spend-listing-12')));
      expect(opened, [12]);
    });

    testWidgets('a failed read offers its own retry', (tester) async {
      repo.summaryError = Exception('offline');
      await showAnalytics(tester);
      final retry = find.byKey(const ValueKey('marketing-spend-retry'));
      await tester.scrollUntilVisible(retry, 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Could not load marketing spend'), findsOneWidget);

      repo.summaryError = null;
      await _tap(tester, retry);
      expect(find.text(r'$185,000'), findsOneWidget);
    });
  });
}
