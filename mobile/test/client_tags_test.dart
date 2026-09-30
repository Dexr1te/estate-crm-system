import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/domain/client_tags.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_tag_chips.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_tag_editor.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_tag_filter_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Tags on clients: chips on the card and the list row, an editor on the form
/// that offers the agency's own tags, and a filter on the list.

const _aigerim = ClientResponse(
  id: 1,
  fullName: 'Aigerim Bekova',
  phone: '+7 916 220-84-11',
  tags: ['Investor', 'urgent', 'VIP'],
);

const _madina = ClientResponse(
  id: 2,
  fullName: 'Madina Seitkali',
  type: ClientType.SELLER,
  tags: ['VIP'],
);

const _untagged = ClientResponse(id: 3, fullName: 'Timur Aliev');

/// Long, Cyrillic and many: what a narrow screen at 1.5 has to hold.
const _crowded = ClientResponse(
  id: 4,
  fullName: 'Александра Константиновна Вишневская-Рождественская',
  phone: '+7 701 111-22-33',
  tags: [
    'Инвестор из Астаны',
    'Ипотека одобрена банком',
    'Срочно до конца месяца',
    'VIP',
    'Қала орталығы',
  ],
);

const _agencyTags = [
  ClientTagUsage(name: 'VIP', count: 12),
  ClientTagUsage(name: 'Investor', count: 7),
  ClientTagUsage(name: 'Ипотека одобрена банком', count: 3),
  ClientTagUsage(name: 'urgent', count: 2),
];

const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

late FakeClientsRepository _clients;

Widget _list() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => ClientsBloc(_clients)),
      ],
      child: const ClientsScreen(),
    );

Widget _editor({List<String> tags = const []}) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EditorHost(key: ValueKey(tags.join('|')), initial: tags),
        ],
      ),
    );

/// Holds the editor's tags the way the form does.
class _EditorHost extends StatefulWidget {
  final List<String> initial;
  const _EditorHost({super.key, required this.initial});

  @override
  State<_EditorHost> createState() => _EditorHostState();
}

class _EditorHostState extends State<_EditorHost> {
  late List<String> _tags = widget.initial;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClientTagEditor(
        tags: _tags,
        suggestions: _agencyTags,
        controller: _ctrl,
        onChanged: (t) => setState(() => _tags = t),
      );
}

Widget _sheet(List<({String name, int count})> available) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClientTagFilterForm(
              available: available, selected: const {'VIP'}, onDone: (_) {}),
        ],
      ),
    );

Widget _card(ClientResponse client) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClientCard(
              client: ClientSummary.join([client], const []).single,
              onTap: () {}),
        ],
      ),
    );

/// The form and the card under a real router, for the taps that navigate.
Future<ClientsBloc> _pumpRouted(WidgetTester tester, String initial) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final auth = AuthBloc(FakeAuthRepository(user: _manager))
    ..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  final bloc = ClientsBloc(_clients);
  addTearDown(bloc.close);
  await tester.pumpWidget(MultiBlocProvider(
    providers: [
      BlocProvider.value(value: auth),
      BlocProvider.value(value: bloc),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: initial,
        routes: [
          GoRoute(
              path: '/clients',
              builder: (_, __) => const Scaffold(body: Text('client list'))),
          GoRoute(
              path: '/clients/new',
              builder: (_, __) => const ClientFormScreen()),
          GoRoute(
              path: '/clients/:id/edit',
              builder: (_, s) => ClientFormScreen(
                  clientId: int.parse(s.pathParameters['id']!))),
          GoRoute(
              path: '/clients/:id',
              builder: (_, s) =>
                  ClientDetailScreen(id: int.parse(s.pathParameters['id']!))),
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return bloc;
}

Future<void> _openTagFilter(WidgetTester tester) async {
  final pill = find.byKey(const ValueKey('clients-filter-tags'));
  await tester.ensureVisible(pill);
  await tester.pumpAndSettle();
  await tester.tap(pill);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const ValueKey('client-tag-field')), text);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _clients = FakeClientsRepository(
        clients: const [_aigerim, _madina, _untagged, _crowded]);
    _clients.tagUsage = _agencyTags;
    Injector.clientsRepository = _clients;
    Injector.dealsRepository = FakeDealsRepository(const []);
  });

  // The rules ---------------------------------------------------------------------------------

  group('ClientTags', () {
    test('trims, collapses spaces, drops a leading # and splits on commas', () {
      expect(ClientTags.split('  #new   build , vip;VIP ,, '),
          ['new build', 'vip']);
      expect(ClientTags.display('###'), isNull);
    });

    test('a typed tag takes the agency spelling and skips what is held', () {
      final r = addTypedTags(['VIP'], 'vip, investor, Срочно', _agencyTags);
      expect(r.tags, ['VIP', 'Investor', 'Срочно']);
      expect(r.problem, isNull);
    });

    test('a tag over 32 characters is refused, the rest still added', () {
      final r = addTypedTags(const [], '${'x' * 33}, ok', const []);
      expect(r.tags, ['ok']);
      expect(r.problem, TagProblem.tooLong);
      expect(addTypedTags(const [], 'ж' * 32, const []).tags, hasLength(1));
    });

    test('the eleventh tag is refused', () {
      final ten = [for (var i = 0; i < 10; i++) 't$i'];
      final r = addTypedTags(ten, 'one more', const []);
      expect(r.tags, ten);
      expect(r.problem, TagProblem.limit);
    });

    test('the list filter wants every tag picked, in any case', () {
      final all = ClientSummary.join(const [_aigerim, _madina, _untagged], []);
      bool shown(ClientSummary c, Set<String> tags) => c.hasAllTags(tags);
      expect(all.where((c) => shown(c, {'vip'})).map((c) => c.id), [1, 2]);
      expect(all.where((c) => shown(c, {'VIP', 'investor'})).map((c) => c.id),
          [1]);
      expect(all.where((c) => shown(c, {})).length, 3);
    });

    test('tags counted across the list, most carried first', () {
      final counts =
          tagCounts(ClientSummary.join(const [_aigerim, _madina], []));
      expect(counts.first, (name: 'VIP', count: 2));
      expect(counts.map((c) => c.name), ['VIP', 'Investor', 'urgent']);
    });

    test('an export narrows by the tags too, as one value', () {
      const filters = ExportFilters(tags: ['VIP', 'Investor']);
      expect(filters.toQuery(), {'tags': 'VIP,Investor'});
      expect(filters.isEmpty, isFalse);
      expect(const ExportFilters(type: 'BUYER'),
          const ExportFilters(type: 'BUYER', tags: []));
    });
  });

  // The list ----------------------------------------------------------------------------------

  testWidgets('a row shows three tags and counts the rest', (tester) async {
    await expectNoOverflow(tester, _card(_crowded),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    expect(find.byType(ClientTagChip), findsNWidgets(4));
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('Инвестор из Астаны'), findsOneWidget);
    expect(find.text('Қала орталығы'), findsNothing);
  });

  testWidgets('a client without tags has no chips', (tester) async {
    await expectNoOverflow(tester, _card(_untagged),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    expect(find.byType(ClientTagChips), findsNothing);
  });

  testWidgets('the tag filter narrows the list to clients with every tag',
      (tester) async {
    await expectNoOverflow(tester, _list(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();
    expect(find.byType(ClientCard), findsNWidgets(4));

    await _openTagFilter(tester);
    await tester.pumpAndSettle();
    expect(find.text('VIP · 3'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('client-tag-filter-VIP')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('client-tag-filter-done')));
    await tester.pumpAndSettle();

    expect(find.byType(ClientCard), findsNWidgets(3));
    expect(find.text('Timur Aliev'), findsNothing);
    expect(find.text('Tags · 1'), findsOneWidget);

    await _openTagFilter(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('client-tag-filter-Investor')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('client-tag-filter-done')));
    await tester.pumpAndSettle();
    expect(find.byType(ClientCard), findsOneWidget);
    expect(find.text('Aigerim Bekova'), findsOneWidget);

    await _openTagFilter(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('client-tag-filter-clear')));
    await tester.pumpAndSettle();
    expect(find.byType(ClientCard), findsNWidgets(4));
    expect(find.text('Tags'), findsOneWidget);
  });

  testWidgets('the tag filter says so when no client has a tag yet',
      (tester) async {
    _clients = FakeClientsRepository(clients: const [_untagged]);
    await expectNoOverflow(tester, _list(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();
    await _openTagFilter(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('No client has a tag yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('client-tag-filter-done')), findsNothing);
  });

  // The editor --------------------------------------------------------------------------------

  testWidgets('the editor offers the agency tags, most used first',
      (tester) async {
    await expectNoOverflow(tester, _editor(tags: const ['urgent']),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    final offered = tester
        .widgetList<FilterPill>(find.byType(FilterPill))
        .map((p) => p.label)
        .toList();
    expect(offered, ['VIP', 'Investor', 'Ипотека одобрена банком'],
        reason: 'what the client already carries is not offered');

    await _type(tester, 'ипо');
    expect(
        tester
            .widgetList<FilterPill>(find.byType(FilterPill))
            .map((p) => p.label),
        ['Ипотека одобрена банком']);

    await tester.tap(find.byKey(
        const ValueKey('client-tag-suggestion-Ипотека одобрена банком')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('client-tag-remove-Ипотека одобрена банком')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('client-tag-field')), findsOneWidget);
  });

  testWidgets('a comma adds what was typed, in the agency spelling',
      (tester) async {
    await expectNoOverflow(tester, _editor(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await _type(tester, 'vip, new   build,');
    expect(find.byKey(const ValueKey('client-tag-remove-VIP')), findsOneWidget);
    expect(find.byKey(const ValueKey('client-tag-remove-new build')),
        findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('client-tag-remove-VIP')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('client-tag-remove-VIP')), findsNothing);
  });

  testWidgets('a tag too long is named, and a full client takes no more',
      (tester) async {
    await expectNoOverflow(tester, _editor(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await _type(tester, '${'x' * 33},');
    expect(find.text('A tag can be at most 32 characters'), findsOneWidget);

    await expectNoOverflow(
        tester, _editor(tags: [for (var i = 0; i < 10; i++) 'tag $i']),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    expect(find.text('Up to 10 tags per client'), findsOneWidget);
    expect(find.byType(FilterPill), findsNothing);
  });

  testWidgets(
      'the form sends the tags, a typed one included, and keeps them on edit',
      (tester) async {
    await _pumpRouted(tester, '/clients/new');
    await tester.enterText(find.byType(TextField).first, 'Dana Omarova');
    await tester.ensureVisible(find.byKey(const ValueKey('client-tag-field')));
    await tester.tap(find.byKey(const ValueKey('client-tag-suggestion-VIP')));
    await tester.pumpAndSettle();
    await _type(tester, 'first home');
    await tester.ensureVisible(find.text('Create Client'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Client'));
    await tester.pumpAndSettle();

    expect(_clients.created.single['tags'], ['VIP', 'first home']);
  });

  testWidgets('editing loads the tags, and taking them all off sends none',
      (tester) async {
    await _pumpRouted(tester, '/clients/2/edit');
    final remove = find.byKey(const ValueKey('client-tag-remove-VIP'));
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Update Client'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Client'));
    await tester.pumpAndSettle();

    expect(_clients.updated.single.$1, 2);
    expect(_clients.updated.single.$2['tags'], isEmpty);
  });

  testWidgets('the client card shows every tag', (tester) async {
    await _pumpRouted(tester, '/clients/4');
    expect(find.byKey(const ValueKey('client-detail-tags')), findsOneWidget);
    for (final tag in _crowded.tags) {
      expect(find.text(tag), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  // Layout ------------------------------------------------------------------------------------

  forEachAcceptanceCase('tag editor', (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _editor(tags: _crowded.tags),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    final code = locale.languageCode;

    testWidgets('a tagged row renders in $code at 1.5', (tester) async {
      await expectNoOverflow(tester, _card(_crowded),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
    });

    testWidgets('the tag editor renders in $code at 1.5', (tester) async {
      await expectNoOverflow(tester, _editor(tags: _crowded.tags),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await _type(tester, 'x' * 40);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('client-tag-problem')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a full tag editor renders in $code at 1.5', (tester) async {
      await expectNoOverflow(
          tester, _editor(tags: [for (var i = 0; i < 10; i++) 'Тег номер $i']),
          size: const Size(320, 568),
          brightness: Brightness.light,
          textScale: 1.5,
          locale: locale);
    });

    testWidgets('the tag filter renders in $code at 1.5', (tester) async {
      await expectNoOverflow(
          tester,
          _sheet(tagCounts(ClientSummary.join(
              const [_aigerim, _madina, _crowded], const []))),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await expectNoOverflow(tester, _sheet(const []),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
    });

    testWidgets('the tagged list and its filter pill render in $code at 1.5',
        (tester) async {
      await expectNoOverflow(tester, _list(),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the tagged client form renders in $code at 1.5',
        (tester) async {
      await expectNoOverflow(
          tester,
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
              BlocProvider(create: (_) => ClientsBloc(_clients)),
            ],
            child: const ClientFormScreen(clientId: 4),
          ),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
