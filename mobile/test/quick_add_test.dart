import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/quick_add/quick_add.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_button.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);
const _manager = AuthResponse(
    userId: 6, fullName: 'Aidos Sarsen', role: Role.MANAGER, teamId: 1);
const _admin =
    AuthResponse(userId: 7, fullName: 'Root Admin', role: Role.ADMIN);

const _aigerim = ClientResponse(
    id: 5, fullName: 'Aigerim Bekova', phone: '+7 701 111 22 33');
const _daniyar = ClientResponse(id: 6, fullName: 'Daniyar Ospan');
const _flat = PropertyResponse(id: 3, title: 'Flat on Abay');
const _deal = DealResponse(
  id: 7,
  title: 'Abay flat for Aigerim',
  clientId: 5,
  clientName: 'Aigerim Bekova',
  propertyId: 3,
  propertyTitle: 'Flat on Abay',
  agentId: 5,
);

late FakeClientsRepository _clients;

void _install() {
  _clients = FakeClientsRepository(clients: const [_aigerim, _daniyar]);
  Injector.clientsRepository = _clients;
  Injector.dealsRepository = FakeDealsRepository(const [_deal]);
  Injector.propertiesRepository = FakePropertiesRepository(const [_flat]);
  Injector.tasksRepository = FakeTasksRepository();
}

void main() {
  group('reading the screen underneath', () {
    test('a record detail links the new one to it', () {
      expect(QuickAddScope.fromLocation('/clients/5'),
          const QuickAddScope(clientId: 5));
      expect(QuickAddScope.fromLocation('/deals/7'),
          const QuickAddScope(dealId: 7));
      expect(QuickAddScope.fromLocation('/properties/3'),
          const QuickAddScope(propertyId: 3));
    });

    test('a list tab leads with its own action', () {
      expect(QuickAddScope.fromLocation('/clients').tab, QuickAddAction.client);
      expect(QuickAddScope.fromLocation('/properties').tab,
          QuickAddAction.listing);
      expect(QuickAddScope.fromLocation('/deals?status=WON').tab,
          QuickAddAction.deal);
      expect(
          QuickAddScope.fromLocation('/meetings').tab, QuickAddAction.meeting);
    });

    test('anything else links nothing', () {
      for (final loc in [
        '/dashboard',
        '/clients/new',
        '/clients/5/edit',
        '/meetings/4',
        '/team-console',
        '/',
      ]) {
        expect(QuickAddScope.fromLocation(loc).hasRecord, isFalse, reason: loc);
      }
      expect(QuickAddScope.fromLocation('/dashboard').tab, isNull);
    });
  });

  group('ordering', () {
    const all = QuickAddAction.values;

    test('with nothing to go on, the fixed order', () {
      expect(orderQuickAdd(all), all);
    });

    test('the last used action comes first, the rest keep their order', () {
      expect(orderQuickAdd(all, lastUsed: QuickAddAction.task), [
        QuickAddAction.task,
        QuickAddAction.client,
        QuickAddAction.listing,
        QuickAddAction.deal,
        QuickAddAction.meeting,
        QuickAddAction.logContact,
      ]);
    });

    test('a tab outranks the last used one, which comes next', () {
      final ordered = orderQuickAdd(all,
          tab: QuickAddAction.deal, lastUsed: QuickAddAction.meeting);
      expect(ordered.take(2), [QuickAddAction.deal, QuickAddAction.meeting]);
      expect(ordered.toSet().length, all.length);
    });
  });

  test('no screen grows a "+" of its own beside the quick-add one', () {
    final plus = RegExp(r'AppHeaderAction\(|Icons\.add(_rounded)?\b');
    final offenders = [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.dart') &&
            !f.path.endsWith('quick_add_button.dart') &&
            !f.path.endsWith('app_buttons.dart') &&
            plus.hasMatch(f.readAsStringSync()))
          f.path,
    ];
    expect(offenders, isEmpty,
        reason: 'start a record from QuickAddButton, which opens one sheet '
            'for every screen, instead of a second "+"');
  });

  test('every signed-in role may start everything; nobody else anything', () {
    for (final role in Role.values) {
      expect(quickAddActionsFor(role), QuickAddAction.values, reason: '$role');
    }
    expect(quickAddActionsFor(null), isEmpty);
  });

  group('from the "+"', () {
    setUp(() {
      _install();
      SharedPreferences.setMockInitialValues({});
    });

    for (final me in [_agent, _manager, _admin]) {
      testWidgets('${me.role.name} is offered every action', (tester) async {
        await _pump(tester, '/dashboard', me: me);
        await _open(tester);
        expect(_rows(tester), QuickAddAction.values.map((a) => a.name));
        expect(find.text('New client'), findsOneWidget);
        expect(find.text('Log a contact'), findsOneWidget);
      });
    }

    testWidgets('from home each form opens unlinked', (tester) async {
      final expected = {
        QuickAddAction.client: '/clients/new',
        QuickAddAction.listing: '/properties/new',
        QuickAddAction.deal: '/deals/new',
        QuickAddAction.meeting: '/meetings/new',
      };
      for (final e in expected.entries) {
        await _pump(tester, '/dashboard');
        await _pick(tester, e.key);
        expect(_opened?.path, e.value, reason: e.key.name);
        expect(_opened?.queryParameters, isEmpty, reason: e.key.name);
      }
    });

    testWidgets('from a client: the deal and the meeting are theirs',
        (tester) async {
      await _pump(tester, '/clients/5');
      await _open(tester);
      expect(find.text('For Aigerim Bekova'), findsOneWidget);
      await _tapRow(tester, QuickAddAction.deal);
      expect(_opened?.path, '/deals/new');
      expect(_opened?.queryParameters, {'clientId': '5'});

      await _pump(tester, '/clients/5');
      await _pick(tester, QuickAddAction.meeting);
      expect(_opened?.path, '/meetings/new');
      expect(_opened?.queryParameters, {'clientId': '5'});
    });

    testWidgets('a client opened from the list is found under the push',
        (tester) async {
      await _pump(tester, '/clients');
      unawaited(_router.push<Object?>('/clients/5'));
      await tester.pumpAndSettle();
      await _pick(tester, QuickAddAction.deal);
      expect(_opened?.queryParameters, {'clientId': '5'});
    });

    testWidgets('from a client: the task is linked to them', (tester) async {
      await _pump(tester, '/clients/5');
      await _pick(tester, QuickAddAction.task);
      expect(find.text('New task'), findsOneWidget);
      expect(find.text('Aigerim Bekova'), findsOneWidget);
    });

    testWidgets('from a client: a contact is logged to them, no picker',
        (tester) async {
      await _pump(tester, '/clients/5');
      await _pick(tester, QuickAddAction.logContact);
      expect(find.text('Which client?'), findsNothing);
      expect(find.text('For Aigerim Bekova'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(_clients.activities.single.clientId, 5);
      expect(find.text('Contact logged'), findsOneWidget);
    });

    testWidgets('from a deal: its client and listing come along',
        (tester) async {
      await _pump(tester, '/deals/7');
      await _pick(tester, QuickAddAction.meeting);
      expect(_opened?.queryParameters, {'clientId': '5', 'propertyId': '3'});

      await _pump(tester, '/deals/7');
      await _pick(tester, QuickAddAction.task);
      expect(find.text('Abay flat for Aigerim'), findsOneWidget);
      expect(find.text('Aigerim Bekova'), findsOneWidget);
    });

    testWidgets('from a listing: the deal and the viewing are for it',
        (tester) async {
      await _pump(tester, '/properties/3');
      await _open(tester);
      expect(find.text('For Flat on Abay'), findsOneWidget);
      await _tapRow(tester, QuickAddAction.deal);
      expect(_opened?.queryParameters, {'propertyId': '3'});

      await _pump(tester, '/properties/3');
      await _pick(tester, QuickAddAction.meeting);
      expect(_opened?.queryParameters, {'propertyId': '3'});
    });

    testWidgets('from home, logging a contact asks whose first',
        (tester) async {
      await _pump(tester, '/dashboard');
      await _pick(tester, QuickAddAction.logContact);
      expect(find.text('Which client?'), findsOneWidget);
      await tester.tap(find.text('Daniyar Ospan'));
      await tester.pumpAndSettle();
      expect(find.text('For Daniyar Ospan'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(_clients.activities.single.clientId, 6);
    });

    testWidgets('a list tab leads with its own action', (tester) async {
      await _pump(tester, '/deals');
      await _open(tester);
      expect(_rows(tester).first, 'deal');
      expect(find.text('Last used'), findsNothing);
    });

    testWidgets('the last one used comes first next time, per person',
        (tester) async {
      await _pump(tester, '/dashboard');
      await _pick(tester, QuickAddAction.meeting);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('quick_add_last_5'), 'meeting');

      await _pump(tester, '/dashboard');
      await _open(tester);
      expect(_rows(tester).first, 'meeting');
      expect(find.text('Last used'), findsOneWidget);

      await _pump(tester, '/dashboard', me: _manager);
      await _open(tester);
      expect(_rows(tester).first, 'client',
          reason: 'someone else on this phone has their own habit');
    });

    testWidgets('an unreadable store just means the fixed order',
        (tester) async {
      SharedPreferences.setMockInitialValues({'quick_add_last_5': 'nonsense'});
      await _pump(tester, '/dashboard');
      await _open(tester);
      expect(_rows(tester), QuickAddAction.values.map((a) => a.name));
    });
  });
}

Uri? _opened;
late GoRouter _router;

Future<void> _pump(WidgetTester tester, String location,
    {AuthResponse me = _agent}) async {
  _opened = null;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final auth = AuthBloc(FakeAuthRepository(user: me))..add(AuthCheckEvent());
  addTearDown(auth.close);

  Widget host(BuildContext _, GoRouterState __) => const Scaffold(
        body: SafeArea(
          child: Align(alignment: Alignment.topRight, child: QuickAddButton()),
        ),
      );
  Widget form(BuildContext _, GoRouterState s) {
    _opened = s.uri;
    return Scaffold(body: Text('form ${s.uri.path}'));
  }

  List<RouteBase> record() => [
        GoRoute(path: 'new', builder: form),
        GoRoute(path: ':id', builder: host),
      ];

  final router = _router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/dashboard', builder: host),
      for (final tab in ['clients', 'properties', 'deals', 'meetings'])
        GoRoute(path: '/$tab', builder: host, routes: record()),
    ],
  );
  addTearDown(router.dispose);

  // A fresh tree each time: the previous router's pages must not linger.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(BlocProvider.value(
    value: auth,
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('quick-add')));
  await tester.pumpAndSettle();
}

Future<void> _tapRow(WidgetTester tester, QuickAddAction action) async {
  final row = find.byKey(ValueKey('quick-add-${action.name}'));
  await tester.ensureVisible(row);
  await tester.tap(row);
  await tester.pumpAndSettle();
}

Future<void> _pick(WidgetTester tester, QuickAddAction action) async {
  await _open(tester);
  await _tapRow(tester, action);
}

List<String> _rows(WidgetTester tester) {
  final rows = find.byWidgetPredicate((w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('quick-add-'));
  final found = rows.evaluate().map((e) {
    final key = (e.widget.key! as ValueKey<String>).value;
    return (
      key.substring('quick-add-'.length),
      tester.getTopLeft(find.byKey(ValueKey(key))).dy
    );
  }).toList()
    ..sort((a, b) => a.$2.compareTo(b.$2));
  return [for (final f in found) f.$1];
}
