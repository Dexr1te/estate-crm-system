import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/keys/data/datasources/keys_remote_datasource.dart';
import 'package:real_estate_crm/features/keys/data/repositories/keys_repository_impl.dart';
import 'package:real_estate_crm/features/keys/presentation/bloc/keys_out_bloc.dart';
import 'package:real_estate_crm/features/keys/presentation/bloc/property_keys_bloc.dart';
import 'package:real_estate_crm/features/keys/presentation/screens/keys_out_screen.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/hand_over_keys_sheet.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/key_out_row.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/keys_out_card.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/property_keys_card.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'keys_fixtures.dart';
import 'responsive_harness.dart';

/// A listing's keys: what the server sends and is sent, the blocs behind the
/// card and the list, the card on the listing with its hand-over sheet and
/// its return, the keys-out list, and the dashboard card that leads to it.

/// The backend, answering every path with what [bodies] holds for it.
class _Backend implements HttpClientAdapter {
  final Map<String, Object?> bodies;
  final List<RequestOptions> requests = [];

  _Backend(this.bodies);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(jsonEncode(bodies[options.path]), 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _handoverJson(int id, {String? returnedAt}) => {
      'id': id,
      'propertyId': 7,
      'propertyTitle': 'Dostyk 5',
      'propertyAddress': 'Dostyk 5',
      'propertyCity': 'Almaty',
      'holderUserId': 3,
      'holderName': 'Timur Aliev',
      'note': 'Both keys',
      'handedOutAt': '2026-10-08T11:00:00',
      'dueBackAt': '2026-10-12',
      'returnedAt': returnedAt,
      'handedOutById': 2,
      'handedOutByName': 'Aigul Bekova',
      'returnedById': null,
      'returnedByName': null,
      'overdue': false,
    };

Widget _page(Widget child) => Scaffold(
      body: ListView(padding: const EdgeInsets.all(16), children: [child]),
    );

Widget _sheet(Widget form) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: AppSheetShell(title: 'Keys', child: form),
        ),
      ),
    );

Future<void> _pump(WidgetTester tester, Widget child) async {
  await expectNoOverflow(tester, child,
      size: const Size(390, 1400),
      brightness: Brightness.light,
      textScale: 1.0);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget _routed(String initial) => MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(initialLocation: initial, routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => BlocProvider(
            create: (_) =>
                KeysOutBloc(Injector.keysRepository)..add(KeysOutLoadEvent()),
            child: _page(KeysOutCard(onSeeAll: () {})),
          ),
        ),
        GoRoute(
            path: '/properties/keys',
            builder: (_, __) => const KeysOutScreen()),
        GoRoute(
          path: '/properties/:id',
          builder: (_, s) => Scaffold(
              body: Text('listing ${s.pathParameters['id']}',
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
        ),
      ]),
    );

void main() {
  late FakeKeysRepository repo;

  setUp(() {
    AppClock.freeze(keysNow);
    repo = FakeKeysRepository(
      byProperty: {1: overdueKeys(), 2: keysInOffice()},
      names: {for (final a in keysAgents) a.id: a.fullName},
      out: keysOutList,
    );
    Injector.keysRepository = repo;
    Injector.agentsRepository = const FakeAgentsRepository(keysAgents);
  });
  tearDown(() {
    AppClock.reset();
    Injector.keysRepository = FakeKeysRepository();
    Injector.agentsRepository = const FakeAgentsRepository([]);
  });

  group('what goes over the wire', () {
    test('a handover reads with its holder, its days and who gave it', () {
      final h = KeyHandover.fromJson(
          _handoverJson(5, returnedAt: '2026-10-09T09:30:00'));
      expect(h.holderName, 'Timur Aliev');
      expect(h.withColleague, isTrue);
      expect(h.dueBackAt, DateTime(2026, 10, 12));
      expect(h.returnedAt, DateTime(2026, 10, 9, 9, 30));
      expect(h.isOut, isFalse);

      final keys = PropertyKeys.fromJson({'current': null, 'history': []});
      expect(keys.current, isNull);
      expect(keys.history, isEmpty);
    });

    test('a draft sends one holder, the day as a date, and a trimmed note', () {
      expect(
        KeyHandoverDraft(
          holderUserId: 3,
          holderName: 'ignored',
          dueBackAt: DateTime(2026, 10, 12, 18, 40),
          note: '  Both keys  ',
        ).toJson(),
        {'holderUserId': 3, 'dueBackAt': '2026-10-12', 'note': 'Both keys'},
      );
      expect(
          const KeyHandoverDraft(holderName: '  Saule  ', note: '  ').toJson(),
          {'holderName': 'Saule'});
    });

    test('the repository reads and writes where the server answers', () async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({'access_token': 'TOKEN'});
      final session = SessionStore();
      await session.load();
      final keysBody = {
        'current': _handoverJson(5),
        'history': [_handoverJson(4, returnedAt: '2026-10-01T12:00:00')],
      };
      final backend = _Backend({
        '/properties/7/keys': keysBody,
        '/properties/7/keys/handover': keysBody,
        '/properties/7/keys/return': {'current': null, 'history': []},
        '/keys/out': [_handoverJson(5)],
      });
      final repository = KeysRepositoryImpl(
          KeysRemoteDataSource(ApiClient(session, adapter: backend)));

      final read = await repository.getForProperty(7);
      expect(read.current?.id, 5);
      expect(read.history.single.id, 4);

      await repository.handOver(
          7, KeyHandoverDraft(holderName: 'Saule', dueBackAt: keyDay(3)));
      final back = await repository.returnKeys(7);
      expect(back.current, isNull);
      final out = await repository.getKeysOut();
      expect(out.single.propertyTitle, 'Dostyk 5');

      expect(
          backend.requests.map((r) => '${r.method} ${r.path}'),
          containsAllInOrder([
            'GET /properties/7/keys',
            'POST /properties/7/keys/handover',
            'POST /properties/7/keys/return',
            'GET /keys/out',
          ]));
      final handover = backend.requests
          .firstWhere((r) => r.path == '/properties/7/keys/handover');
      expect(handover.data, {'holderName': 'Saule', 'dueBackAt': '2026-10-12'});
    });
  });

  group('the blocs', () {
    test('the keys out load, and a failure is kept to say so', () async {
      final bloc = KeysOutBloc(repo)..add(KeysOutLoadEvent());
      final loaded = await bloc.stream.firstWhere((s) => s is KeysOutLoaded)
          as KeysOutLoaded;
      expect(loaded.keys.map((k) => k.id), [21, 22, 23, 24]);
      expect(loaded.overdueCount, 1);
      await bloc.close();

      repo.readError = Exception('offline');
      final failing = KeysOutBloc(repo)..add(KeysOutLoadEvent());
      await failing.stream.firstWhere((s) => s is KeysOutError);
      await failing.close();
    });

    test('handing out and taking back answer with the keys as they are now',
        () async {
      final bloc = PropertyKeysBloc(repo, propertyId: 2)
        ..add(PropertyKeysLoadEvent());
      await bloc.stream
          .firstWhere((s) => s.status == PropertyKeysStatus.loaded);
      expect(bloc.state.keys.current, isNull);

      bloc.add(PropertyKeysHandOverEvent(
          const KeyHandoverDraft(holderUserId: 3, note: 'Fob too')));
      await bloc.stream.firstWhere((s) => s.saved == 1);
      expect(bloc.state.keys.current?.holderName, 'Timur Aliev');
      expect(bloc.state.keys.current?.note, 'Fob too');

      bloc.add(PropertyKeysReturnEvent());
      await bloc.stream.firstWhere((s) => s.saved == 2);
      expect(bloc.state.keys.current, isNull);
      expect(bloc.state.keys.history.first.holderName, 'Timur Aliev');
      expect(bloc.state.keys.history, hasLength(3));
      await bloc.close();
    });

    test('a refusal is reported once, and the keys are read again', () async {
      final bloc = PropertyKeysBloc(repo, propertyId: 1)
        ..add(PropertyKeysLoadEvent());
      await bloc.stream
          .firstWhere((s) => s.status == PropertyKeysStatus.loaded);
      final readsBefore = repo.reads;

      bloc.add(PropertyKeysHandOverEvent(
          const KeyHandoverDraft(holderName: 'Saule')));
      final refused =
          await bloc.stream.firstWhere((s) => s.writeFailure != null);
      expect(refused.writeFailure!.failure.serverCode, 'KEY_ALREADY_OUT');
      final reloaded =
          await bloc.stream.firstWhere((s) => s.writeFailure == null);
      expect(reloaded.keys.current?.id, 10);
      expect(repo.reads, readsBefore + 1);
      await bloc.close();
    });

    test('a listing that cannot be read says so', () async {
      repo.readError = Exception('offline');
      final bloc = PropertyKeysBloc(repo, propertyId: 1)
        ..add(PropertyKeysLoadEvent());
      final failed = await bloc.stream
          .firstWhere((s) => s.status == PropertyKeysStatus.error);
      expect(failed.loadFailure, isNotNull);
      await bloc.close();
    });
  });

  group('the card on a listing', () {
    testWidgets('keys in the office can be handed to somebody by name',
        (tester) async {
      await _pump(tester, _page(const PropertyKeysCard(propertyId: 2)));
      expect(find.text('In the office'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.byKey(const ValueKey('property-keys-return')), findsNothing);

      await _tap(tester, find.byKey(const ValueKey('property-keys-hand-over')));
      final save = find.byKey(const ValueKey('keys-save'));
      expect(tester.widget<AppFilledButton>(save).onPressed, isNull,
          reason: 'it waits for somebody to take them');

      await _tap(tester, find.byKey(const ValueKey('keys-to-someone-else')));
      await tester.enterText(find.byKey(const ValueKey('keys-holder-name')),
          '  Saule, the owner ');
      await tester.enterText(find.byKey(const ValueKey('keys-note')), 'Fob');
      await tester.pumpAndSettle();
      await _tap(tester, save);

      final (propertyId, draft) = repo.handedOver.single;
      expect(propertyId, 2);
      expect(draft.toJson(), {'holderName': 'Saule, the owner', 'note': 'Fob'});
      expect(find.text('With Saule, the owner'), findsOneWidget);
      expect(find.text('Handed out Oct 9 by Aigul Bekova'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('property-keys-return')), findsOneWidget);
    });

    testWidgets('a colleague comes from the agency picker, with a due day',
        (tester) async {
      await _pump(tester, _page(const PropertyKeysCard(propertyId: 2)));
      await _tap(tester, find.byKey(const ValueKey('property-keys-hand-over')));

      await _tap(tester, find.byKey(const ValueKey('keys-colleague')));
      expect(find.text('Asel Nurlanovna'), findsOneWidget);
      // The card's own past names Timur too; the picker sits on top of it.
      await _tap(tester, find.text('Timur Aliev').last);
      await _tap(tester, find.byKey(const ValueKey('keys-due-back')));
      await _tap(tester, find.text('OK'));
      expect(find.text('Oct 10'), findsOneWidget,
          reason: 'the picker opens on tomorrow');
      await _tap(tester, find.byKey(const ValueKey('keys-save')));

      final (_, draft) = repo.handedOver.single;
      expect(draft.toJson(), {'holderUserId': 3, 'dueBackAt': '2026-10-10'});
      expect(find.text('With Timur Aliev · until Oct 10'), findsOneWidget);
    });

    testWidgets('a note too long for the server is caught before sending',
        (tester) async {
      await _pump(tester, _sheet(const HandOverKeysForm()));
      await _tap(tester, find.byKey(const ValueKey('keys-to-someone-else')));
      await tester.enterText(
          find.byKey(const ValueKey('keys-holder-name')), 'Saule');
      await tester.enterText(find.byKey(const ValueKey('keys-note')),
          'x' * (kKeyNoteMaxLength + 1));
      await tester.pumpAndSettle();
      expect(find.text('A note is at most 500 characters'), findsOneWidget);
      expect(
          tester
              .widget<AppFilledButton>(find.byKey(const ValueKey('keys-save')))
              .onPressed,
          isNull);
    });

    testWidgets('overdue keys say so in the danger hue, and come back',
        (tester) async {
      await _pump(tester, _page(const PropertyKeysCard(propertyId: 1)));

      final holder = find.byKey(const ValueKey('property-keys-holder'));
      expect(
          tester.widget<Text>(holder).data,
          'With Gulnara Serikbaykyzy-Nurmukhambetova, cleaning company'
          ' · until Oct 8');
      final context = tester.element(holder);
      expect(
          tester.widget<Text>(holder).style?.color, context.tokens.dangerText);
      expect(
          find.byKey(const ValueKey('property-keys-overdue')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('property-keys-history-103')), findsNothing,
          reason: 'three past handovers until asked for more');
      await _tap(tester, find.byKey(const ValueKey('property-keys-show-all')));
      expect(find.byKey(const ValueKey('property-keys-history-104')),
          findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('property-keys-return')));
      expect(find.text('Return the keys to the office?'), findsOneWidget);
      await _tap(tester, find.text('Return'));

      expect(repo.returned, [1]);
      expect(find.text('In the office'), findsOneWidget);
      expect(find.byKey(const ValueKey('property-keys-overdue')), findsNothing);
      expect(find.byKey(const ValueKey('property-keys-history-10')),
          findsOneWidget);
    });

    testWidgets('cancelling the question takes nothing back', (tester) async {
      await _pump(tester, _page(const PropertyKeysCard(propertyId: 1)));
      await _tap(tester, find.byKey(const ValueKey('property-keys-return')));
      await _tap(tester, find.text('Cancel'));
      expect(repo.returned, isEmpty);
      expect(
          find.byKey(const ValueKey('property-keys-return')), findsOneWidget);
    });

    testWidgets('keys somebody else handed out first are refused in words',
        (tester) async {
      await _pump(tester, _page(const PropertyKeysCard(propertyId: 2)));
      repo.byProperty[2] = overdueKeys();
      await _tap(tester, find.byKey(const ValueKey('property-keys-hand-over')));
      await _tap(tester, find.byKey(const ValueKey('keys-to-someone-else')));
      await tester.enterText(
          find.byKey(const ValueKey('keys-holder-name')), 'Saule');
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const ValueKey('keys-save')));

      expect(
          find.text(
              'These keys are already out. The card now shows who has them.'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('property-keys-return')), findsOneWidget,
          reason: 'the card reads the keys again and shows who has them');
    });

    testWidgets('a failure to load says so and can be retried', (tester) async {
      repo.readError = Exception('offline');
      await _pump(tester, _page(const PropertyKeysCard(propertyId: 2)));
      expect(find.text("Couldn't load the keys"), findsOneWidget);

      repo.readError = null;
      await _tap(tester, find.byKey(const ValueKey('property-keys-retry')));
      expect(find.text('In the office'), findsOneWidget);
    });

    testWidgets("the listing's detail screen carries it", (tester) async {
      const listing = PropertyResponse(
          id: 1, title: 'Dostyk 5', address: 'Dostyk 5', price: 41000000);
      Injector.propertiesRepository = FakePropertiesRepository(const [listing]);
      addTearDown(() =>
          Injector.propertiesRepository = FakePropertiesRepository(const []));
      await _pump(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
            BlocProvider(
                create: (_) =>
                    PropertiesBloc(FakePropertiesRepository(const [listing]))),
          ],
          child: const PropertyDetailScreen(id: 1),
        ),
      );
      final card = find.byKey(const ValueKey('property-keys'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('property-keys-overdue')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('property-keys-return')), findsOneWidget);
    });
  });

  group('keys out', () {
    testWidgets('overdue first, each opening its listing', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_routed('/properties/keys'));
      await tester.pumpAndSettle();

      final rows = find.byType(KeyOutRow);
      expect(rows, findsNWidgets(4));
      expect(tester.widgetList<KeyOutRow>(rows).map((r) => r.handover.id),
          [21, 22, 23, 24]);
      expect(find.text('With Timur Aliev · until Oct 9'), findsOneWidget);
      expect(find.text('With Saule, the owner · until Jan 20, 2027'),
          findsOneWidget);
      expect(find.text('With Arman Ospanov'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('key-out-row-22')));
      expect(find.text('listing 12'), findsOneWidget);
    });

    testWidgets('with every key in the office, the list says so',
        (tester) async {
      repo.out = const [];
      await _pump(tester, const KeysOutScreen());
      expect(find.text('All keys are in the office'), findsOneWidget);
    });

    testWidgets('the dashboard shows the first few and how many are late',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_routed('/home'));
      await tester.pumpAndSettle();

      expect(find.byType(KeyOutRow), findsNWidgets(kKeysOutPreview));
      expect(find.text('1 overdue'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('key-out-row-21')));
      expect(find.text('listing 11'), findsOneWidget);
    });

    testWidgets('the dashboard card is not there when no key is out',
        (tester) async {
      repo.out = const [];
      final bloc = KeysOutBloc(repo)..add(KeysOutLoadEvent());
      addTearDown(bloc.close);
      await _pump(
          tester,
          BlocProvider.value(
              value: bloc, child: _page(KeysOutCard(onSeeAll: () {}))));
      expect(find.byKey(const ValueKey('keys-out-hidden'), skipOffstage: false),
          findsOneWidget);
      expect(find.byKey(const ValueKey('keys-out-card')), findsNothing);
    });
  });
}
