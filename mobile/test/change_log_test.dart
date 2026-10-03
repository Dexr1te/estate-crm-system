import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/change_log/domain/change_entry.dart';
import 'package:real_estate_crm/features/change_log/domain/repositories/change_log_repository.dart';
import 'package:real_estate_crm/features/change_log/presentation/screens/change_history_screen.dart';
import 'package:real_estate_crm/features/change_log/presentation/screens/team_change_log_screen.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';
import 'package:real_estate_crm/l10n/app_localizations_ru.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The change log: a record's history of changes, read as saves (who, when,
/// and each field from what to what in words, never the server's names),
/// and the agency's feed for its manager with its filters.

final _now = DateTime(2026, 10, 3, 18, 0);
final _save = DateTime(2026, 10, 3, 14, 5);
final _earlier = DateTime(2026, 9, 20, 9, 30);

RecordChange _line(
  int id, {
  ChangeEntityType type = ChangeEntityType.property,
  int entityId = 7,
  String label = 'Severny Residence, apartment 84 on the twelfth floor',
  ChangeAction action = ChangeAction.updated,
  String? field,
  String? oldValue,
  String? newValue,
  int? actorId = 5,
  String? actorName = 'Aigul Nurlanovna Bekova-Abdrakhmanova',
  DateTime? at,
}) =>
    RecordChange(
      id: id,
      entityType: type,
      entityId: entityId,
      entityLabel: label,
      action: action,
      field: field,
      oldValue: oldValue,
      newValue: newValue,
      actorId: actorId,
      actorName: actorName,
      changedAt: at ?? _save,
    );

/// Newest first, as the server sends them: one save that moved the price and
/// the rooms, a status change by a colleague who has since left, the agent
/// handed over, and the listing's creation. Then a deal and a deleted client
/// for the agency's feed.
List<RecordChange> _changes() => [
      _line(10,
          action: ChangeAction.priceChanged,
          field: 'price',
          oldValue: '45000000',
          newValue: '42000000'),
      _line(11, field: 'rooms', oldValue: '2', newValue: '3'),
      _line(12, field: 'description', oldValue: 'Old', newValue: 'New'),
      _line(9,
          action: ChangeAction.statusChanged,
          field: 'status',
          oldValue: 'AVAILABLE',
          newValue: 'RESERVED',
          actorId: null,
          actorName: 'Timur Aliev',
          at: _save.subtract(const Duration(hours: 1))),
      _line(8,
          action: ChangeAction.agentChanged,
          field: 'agent',
          oldValue: 'Timur Aliev',
          newValue: 'Aigul Bekova',
          actorName: null,
          actorId: null,
          at: _save.subtract(const Duration(hours: 2))),
      _line(1, action: ChangeAction.created, at: _earlier),
      _line(20,
          type: ChangeEntityType.deal,
          entityId: 5,
          label: 'Severny Residence for Saule',
          action: ChangeAction.statusChanged,
          field: 'status',
          oldValue: 'LEAD',
          newValue: 'NEGOTIATION',
          actorId: 6,
          actorName: 'Dana Seitova',
          at: _earlier.subtract(const Duration(days: 1))),
      _line(19,
          type: ChangeEntityType.client,
          entityId: 3,
          label: 'Saule Nurlanova',
          action: ChangeAction.deleted,
          actorId: 6,
          actorName: 'Dana Seitova',
          at: _earlier.subtract(const Duration(days: 2))),
    ];

late FakeChangeLogRepository _repo;

final AppLocalizations _en = AppLocalizationsEn();

String _label(RecordChange c, [AppLocalizations? l10n]) =>
    changeLineLabel(l10n ?? _en, c, 'en');

Future<void> _pump(WidgetTester tester, Widget child) async {
  await expectNoOverflow(tester, child,
      size: const Size(390, 844), brightness: Brightness.light, textScale: 1.0);
  await tester.pumpAndSettle();
}

/// The feed inside a router, so a record in it can be opened.
Widget _routed(Widget home) => MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => home),
        GoRoute(
            path: '/deals/:id',
            builder: (_, s) => Text('deal ${s.pathParameters['id']}')),
        GoRoute(
            path: '/clients/:id',
            builder: (_, s) => Text('client ${s.pathParameters['id']}')),
      ]),
    );

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = FakeChangeLogRepository(changes: _changes());
    Injector.changeLogRepository = _repo;
    Injector.agentsRepository = const FakeAgentsRepository([
      AgentOption(id: 5, fullName: 'Aigul Bekova'),
      AgentOption(id: 6, fullName: 'Dana Seitova'),
    ]);
  });
  tearDown(() {
    AppClock.reset();
    Injector.agentsRepository = const FakeAgentsRepository([]);
  });

  const history = ChangeHistoryScreen(type: ChangeEntityType.property, id: 7);

  group('layout', () {
    forEachAcceptanceCase('history of changes',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, history,
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('agency change log',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, const TeamChangeLogScreen(),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('everything renders in ${locale.languageCode}',
          (tester) async {
        for (final child in [history, const TeamChangeLogScreen()]) {
          await expectNoOverflow(tester, child,
              size: const Size(320, 568),
              brightness: Brightness.dark,
              textScale: 1.5,
              locale: locale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  group('lines in words', () {
    test('a price, a status, a type and a reason are put into words', () {
      expect(_label(_changes()[0]), r'Price: $45,000,000 → $42,000,000');
      expect(_label(_changes()[3]), 'Status: Available → Reserved');
      expect(
          _label(_line(1,
              type: ChangeEntityType.deal,
              field: 'status',
              oldValue: 'LEAD',
              newValue: 'NEGOTIATION')),
          'Status: Lead → Negotiation');
      expect(
          _label(_line(1,
              type: ChangeEntityType.deal,
              field: 'lostReason',
              oldValue: null,
              newValue: 'PRICE')),
          'Why it was lost: — → Price');
      expect(
          _label(_line(1,
              field: 'mandateType', oldValue: 'OPEN', newValue: 'EXCLUSIVE')),
          'Agreement with the seller: Open → Exclusive');
      expect(
          _label(_line(1,
              type: ChangeEntityType.client,
              field: 'type',
              oldValue: 'BUYER',
              newValue: 'SELLER')),
          'Type: Buyer → Seller');
    });

    test('a rent\'s kind, rent, lease days and reminder are put into words',
        () {
      RecordChange line(String field, String? from, String? to) => _line(1,
          type: ChangeEntityType.deal,
          field: field,
          oldValue: from,
          newValue: to);
      expect(_label(line('kind', 'SALE', 'RENT')), 'Sale or rent: Sale → Rent');
      expect(_label(line('monthlyRent', '300000', '320000')),
          r'Rent per month: $300,000 → $320,000');
      expect(_label(line('leaseReminderDays', null, '14')),
          'Reminder: — → 14 days before the end');
      expect(
          _label(line('leaseEnd', '2026-10-11', '2027-10-11')),
          allOf(startsWith('Lease ends: '), contains('2026'), contains('2027'),
              isNot(contains('2027-10-11'))));
      expect(_label(line('landlord', null, 'Dana Seitova')),
          'Landlord: — → Dana Seitova');
      expect(_label(line('kind', 'SALE', 'BARTER')), isNot(contains('BARTER')));
    });

    test('never the server\'s own name, even for a value the app does not know',
        () {
      final line = _label(_line(1,
          field: 'status', oldValue: 'AVAILABLE', newValue: 'ARCHIVED'));
      expect(line, 'Status: Available → another value');
      expect(line, isNot(contains('ARCHIVED')));
      expect(_label(_line(1, field: 'somethingNew', newValue: 'X')),
          'Other details edited');
    });

    test('creation, deletion, a hand-over and long text', () {
      expect(_label(_changes()[5]), 'Created');
      expect(_label(_changes()[7]), 'Deleted');
      expect(_label(_changes()[4]), 'Agent: Timur Aliev → Aigul Bekova');
      expect(_label(_changes()[2]), 'Description edited');
      expect(
          _label(_line(1,
              type: ChangeEntityType.client,
              field: 'birthday',
              oldValue: null,
              newValue: '--05-14')),
          'Birthday: — → May 14');
      expect(
          _label(_line(1,
              type: ChangeEntityType.deal,
              field: 'commissionPercent',
              oldValue: '2.5',
              newValue: '3')),
          'Commission: 2.5% → 3%');
    });

    test('in Russian too', () {
      expect(_label(_changes()[3], AppLocalizationsRu()),
          'Статус: Доступен → Забронирован');
    });

    test('lines of one save are one entry, in the order they were written', () {
      final entries = groupChanges(_changes());
      expect(entries.map((e) => e.lines.map((l) => l.id).toList()), [
        [10, 11, 12],
        [9],
        [8],
        [1],
        [20],
        [19],
      ]);
      expect(entries.last.isDeletion, isTrue);
    });
  });

  group('a record\'s history', () {
    testWidgets('who, when, and each field that moved', (tester) async {
      await _pump(tester, history);

      expect(find.text('History of changes'), findsOneWidget);
      expect(find.text('Aigul Nurlanovna Bekova-Abdrakhmanova'), findsWidgets);
      expect(find.text('Today, 14:05'), findsOneWidget);
      expect(find.text(r'Price: $45,000,000 → $42,000,000'), findsOneWidget);
      expect(find.text('Rooms: 2 → 3'), findsOneWidget);
      expect(find.text('Status: Available → Reserved'), findsOneWidget);
      expect(find.text('Timur Aliev'), findsOneWidget,
          reason: 'someone who left is still named');
      expect(find.text('Automatically'), findsOneWidget,
          reason: 'a change nobody made by hand');
      expect(find.text('Created'), findsOneWidget);
      expect(find.textContaining('AVAILABLE'), findsNothing);
      expect(find.text('Saule Nurlanova'), findsNothing,
          reason: "another record's lines are not this one's");
    });

    testWidgets('nothing yet says so', (tester) async {
      _repo.changes.clear();
      await _pump(tester, history);
      expect(find.text('No changes yet'), findsOneWidget);
    });

    testWidgets('a failure says so and can be retried', (tester) async {
      _repo.failWith = Exception('offline');
      await _pump(tester, history);
      expect(find.text('Could not load the history'), findsOneWidget);

      _repo.failWith = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Created'), findsOneWidget);
    });

    testWidgets('the next page is read near the end', (tester) async {
      _repo = FakeChangeLogRepository(
        pageSize: 4,
        changes: [
          for (var i = 0; i < 10; i++)
            _line(100 - i,
                field: 'title',
                oldValue: 'Title ${i + 1}',
                newValue: 'Title $i',
                at: _save.subtract(Duration(hours: i))),
        ],
      );
      Injector.changeLogRepository = _repo;
      await _pump(tester, history);
      expect(_repo.pagesRead, [0]);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(_repo.pagesRead, containsAllInOrder([0, 1, 2]));
      expect(find.text('Title: Title 10 → Title 9'), findsOneWidget);
    });
  });

  group('the agency\'s change log', () {
    testWidgets('names each record and opens it', (tester) async {
      await tester.pumpWidget(_routed(const TeamChangeLogScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Change log'), findsOneWidget);
      expect(find.text('Deal: Severny Residence for Saule'), findsOneWidget);
      expect(find.text('Status: Lead → Negotiation'), findsOneWidget);

      final deal = find.text('Deal: Severny Residence for Saule');
      await tester.scrollUntilVisible(deal, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(deal);
      await tester.pumpAndSettle();
      expect(find.text('deal 5'), findsOneWidget);
    });

    testWidgets('a deleted record is named but does not open', (tester) async {
      await tester.pumpWidget(_routed(const TeamChangeLogScreen()));
      await tester.pumpAndSettle();

      final deleted = find.text('Client: Saule Nurlanova');
      await tester.scrollUntilVisible(deleted, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(deleted);
      await tester.pumpAndSettle();
      expect(find.text('client 3'), findsNothing);
    });

    testWidgets('narrows by kind of record, by person, and clears',
        (tester) async {
      await _pump(tester, const TeamChangeLogScreen());

      await tester.tap(find.byKey(const ValueKey('change-type-deal')));
      await tester.pumpAndSettle();
      expect(_repo.feedRequests.last.entityType, ChangeEntityType.deal);
      expect(find.text('Status: Lead → Negotiation'), findsOneWidget);
      expect(find.text('Created'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('change-type-all')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('change-actor')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('change-actor-6')));
      await tester.pumpAndSettle();
      expect(_repo.feedRequests.last, const ChangeLogFilter(actorId: 6));
      expect(find.text('Dana Seitova'), findsWidgets);
      expect(find.text('Created'), findsNothing);

      await tester.ensureVisible(find.byKey(const ValueKey('change-clear')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('change-clear')));
      await tester.pumpAndSettle();
      expect(_repo.feedRequests.last, const ChangeLogFilter());
      expect(find.byKey(const ValueKey('change-clear')), findsNothing);
    });

    testWidgets('a filter that matches nothing says so', (tester) async {
      _repo.changes.removeWhere((c) => c.entityType == ChangeEntityType.deal);
      await _pump(tester, const TeamChangeLogScreen());
      await tester.tap(find.byKey(const ValueKey('change-type-deal')));
      await tester.pumpAndSettle();
      expect(find.text('Nothing matches these filters.'), findsOneWidget);
    });
  });

  test("only a manager or an admin reaches the agency's change log", () {
    String? redirect(Role role) => resolveRedirect(
          location: '/audit',
          sessionResolved: true,
          authenticated: true,
          role: role,
          hasTeam: true,
        );
    expect(redirect(Role.MANAGER), isNull);
    expect(redirect(Role.ADMIN), isNull);
    expect(redirect(Role.AGENT), '/dashboard');
  });
}
