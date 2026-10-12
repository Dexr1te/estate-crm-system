import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/forms/draft_notice.dart';
import 'package:real_estate_crm/core/forms/form_draft.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/features/tasks/presentation/widgets/task_form.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _anna =
    ClientResponse(id: 42, fullName: 'Anna Petrova', phone: '+7 700 100 20 30');

class _OfflineClients extends FakeClientsRepository {
  _OfflineClients() : super(clients: const [_anna]);

  @override
  Future<ClientResponse> createClient(Map<String, dynamic> data) async =>
      throw DioException(
        requestOptions: RequestOptions(path: '/clients'),
        type: DioExceptionType.connectionError,
      );
}

late FakeClientsRepository _clients;

Future<Map<String, dynamic>?> _stored(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('${FormDraft.keyPrefix}-:$id');
  return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
}

Future<void> _pumpClientForm(WidgetTester tester, {int? clientId}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  Injector.clientsRepository = _clients;
  final bloc = ClientsBloc(_clients);
  addTearDown(bloc.close);
  await tester.pumpWidget(BlocProvider.value(
    value: bloc,
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation:
            clientId == null ? '/clients/new' : '/clients/$clientId/edit',
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
        ],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _leave(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
}

Finder get _nameField => find.byType(TextField).first;

String _text(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller!.text;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _clients = FakeClientsRepository(clients: const [_anna]);
  });

  group('FormDraft', () {
    testWidgets('waits for typing to pause, then writes', (tester) async {
      final draft = FormDraft('client:new');
      draft.schedule({'fullName': 'A'});
      await tester.pump(const Duration(milliseconds: 200));
      draft.schedule({'fullName': 'An'});
      await tester.pump(const Duration(milliseconds: 400));
      expect(await _stored('client:new'), isNull);

      await tester.pump(const Duration(milliseconds: 200));
      expect(await _stored('client:new'), {'fullName': 'An'});
      expect(await draft.read(), {'fullName': 'An'});

      draft.schedule(null);
      await draft.flush();
      expect(await _stored('client:new'), isNull);
    });

    testWidgets('is kept per signed-in user', (tester) async {
      final scope = FormDraft.scope;
      addTearDown(() => FormDraft.scope = scope);

      FormDraft.scope = () => 'u1:t1';
      final mine = FormDraft('client:new')..schedule({'fullName': 'Mine'});
      await mine.flush();

      FormDraft.scope = () => 'u2:t1';
      expect(await FormDraft('client:new').read(), isNull);

      FormDraft.scope = () => 'u1:t1';
      expect(await FormDraft('client:new').read(), {'fullName': 'Mine'});
    });

    test('every draft goes when the session ends', () async {
      final draft = FormDraft('client:new')..schedule({'fullName': 'A'});
      await draft.flush();
      final other = FormDraft('meeting:3')..schedule({'title': 'B'});
      await other.flush();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', 'dark');
      FlutterSecureStorage.setMockInitialValues({});

      await Injector.session.clear();

      expect(await _stored('client:new'), isNull);
      expect(await _stored('meeting:3'), isNull);
      expect(prefs.getString('theme_mode'), 'dark');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('a picked record compares by id alone', () {
      expect(
          sameDraft({
            'client': draftRef(const PickerItem(id: 3, title: '')),
          }, {
            'client': draftRef(const PickerItem(id: 3, title: 'Anna')),
          }),
          isTrue);
      expect(
          sameDraft({
            'client': draftRef(const PickerItem(id: 3, title: 'Anna')),
          }, {
            'client': draftRef(const PickerItem(id: 4, title: 'Anna')),
          }),
          isFalse);
      expect(sameDraft({'a': 1, 'b': null}, {'a': 1}), isTrue);
      expect(
          sameDraft({
            'tags': ['x']
          }, {
            'tags': <String>[]
          }),
          isFalse);
    });
  });

  group('the client form', () {
    testWidgets('brings back what was typed after it is closed',
        (tester) async {
      await _pumpClientForm(tester);
      await tester.enterText(_nameField, 'Bolat Seitkali');
      await tester.tap(find.text('Seller'));
      await tester.pump(const Duration(milliseconds: 600));
      expect((await _stored('client:new'))?['fullName'], 'Bolat Seitkali');

      await _leave(tester);
      await _pumpClientForm(tester);

      expect(_text(tester, _nameField), 'Bolat Seitkali');
      expect(find.text('We restored what you typed last time'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Budget from'), findsNothing,
          reason: 'the seller type came back too, so no buyer card');
    });

    testWidgets('a closed form keeps what was typed even inside the pause',
        (tester) async {
      await _pumpClientForm(tester);
      await tester.enterText(_nameField, 'Quick leaver');
      await _leave(tester);

      expect((await _stored('client:new'))?['fullName'], 'Quick leaver');
    });

    testWidgets('discard puts the form back and forgets the draft',
        (tester) async {
      await _pumpClientForm(tester);
      await tester.enterText(_nameField, 'Bolat Seitkali');
      await tester.pump(const Duration(milliseconds: 600));
      await _leave(tester);
      await _pumpClientForm(tester);
      expect(_text(tester, _nameField), 'Bolat Seitkali');

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(_text(tester, _nameField), isEmpty);
      expect(await _stored('client:new'), isNull);

      await _leave(tester);
      await _pumpClientForm(tester);
      expect(_text(tester, _nameField), isEmpty);
      expect(find.text('We restored what you typed last time'), findsNothing);
    });

    testWidgets('a successful save clears the draft', (tester) async {
      await _pumpClientForm(tester);
      await tester.enterText(_nameField, 'Bolat Seitkali');
      await tester.pump(const Duration(milliseconds: 600));
      expect(await _stored('client:new'), isNotNull);

      await tester.tap(find.text('Create client'));
      await tester.pumpAndSettle();

      expect(find.text('client list'), findsOneWidget);
      expect(_clients.created.single['fullName'], 'Bolat Seitkali');
      expect(await _stored('client:new'), isNull);
    });

    testWidgets('a save that fails offline keeps everything typed',
        (tester) async {
      _clients = _OfflineClients();
      await _pumpClientForm(tester);
      await tester.enterText(_nameField, 'Bolat Seitkali');
      await tester.tap(find.text('Create client'));
      await tester.pumpAndSettle();

      expect(find.text('client list'), findsNothing);
      expect(_text(tester, _nameField), 'Bolat Seitkali');
      expect((await _stored('client:new'))?['fullName'], 'Bolat Seitkali');
    });

    testWidgets('an edit that is saved clears that record\'s draft',
        (tester) async {
      await _pumpClientForm(tester, clientId: 42);
      expect(_text(tester, _nameField), 'Anna Petrova');
      await tester.enterText(_nameField, 'Anna Petrova-Kim');
      await tester.pump(const Duration(milliseconds: 600));
      expect((await _stored('client:42'))?['fullName'], 'Anna Petrova-Kim');

      await tester.tap(find.text('Update client'));
      await tester.pumpAndSettle();

      expect(_clients.updated.single.$2['fullName'], 'Anna Petrova-Kim');
      expect(await _stored('client:42'), isNull);
    });

    testWidgets('a draft is never restored into another record',
        (tester) async {
      await _pumpClientForm(tester);
      await tester.enterText(_nameField, 'Someone new');
      await tester.pump(const Duration(milliseconds: 600));
      await _leave(tester);

      await _pumpClientForm(tester, clientId: 42);
      expect(_text(tester, _nameField), 'Anna Petrova');
      expect(find.text('We restored what you typed last time'), findsNothing);
      expect(await _stored('client:42'), isNull);
      expect((await _stored('client:new'))?['fullName'], 'Someone new');
    });

    testWidgets('cancel and back on an unchanged form leave no draft',
        (tester) async {
      await _pumpClientForm(tester);
      await tester.enterText(_nameField, 'Not wanted');
      await tester.pump(const Duration(milliseconds: 600));
      expect(await _stored('client:new'), isNotNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('client list'), findsOneWidget);
      expect(await _stored('client:new'), isNull);

      await _leave(tester);
      await _pumpClientForm(tester, clientId: 42);
      await tester.enterText(_nameField, 'Anna Petrova');
      await _leave(tester);
      expect(await _stored('client:42'), isNull);
    });

    testWidgets('the pinned save is on screen without scrolling',
        (tester) async {
      await _pumpClientForm(tester);
      final save = tester.getRect(find.text('Create client'));
      expect(save.bottom, lessThanOrEqualTo(844));
      expect(find.byType(PinnedActionBar), findsOneWidget);
    });
  });

  group('every form keeps a draft', () {
    Future<void> pump(WidgetTester tester, Widget form) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
                  PropertiesBloc(FakePropertiesRepository(const []))),
          BlocProvider(create: (_) => DealsBloc(FakeDealsRepository(const []))),
          BlocProvider(
              create: (_) => MeetingsBloc(FakeMeetingsRepository(const []))),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: form,
        ),
      ));
      await tester.pumpAndSettle();
    }

    final forms = <String, Widget Function()>{
      'property:new': () => const PropertyFormScreen(),
      'deal:new:client-3': () => const DealFormScreen(initialClientId: 3),
      'meeting:new': () => const MeetingFormScreen(),
    };

    for (final entry in forms.entries) {
      testWidgets('${entry.key} comes back after the form is rebuilt',
          (tester) async {
        await pump(tester, entry.value());
        await tester.enterText(find.byType(TextField).first, 'Draft title');
        await tester.pump(const Duration(milliseconds: 600));
        expect((await _stored(entry.key))?['title'], 'Draft title');

        await _leave(tester);
        await pump(tester, entry.value());

        expect(_text(tester, find.byType(TextField).first), 'Draft title');
        expect(
            find.text('We restored what you typed last time'), findsOneWidget);
        expect(find.byType(PinnedActionBar), findsOneWidget);

        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
        expect(_text(tester, find.byType(TextField).first), isEmpty);
        expect(await _stored(entry.key), isNull);
      });
    }

    testWidgets('a new deal from one client does not take another\'s draft',
        (tester) async {
      await pump(tester, const DealFormScreen(initialClientId: 3));
      await tester.enterText(find.byType(TextField).first, 'For client 3');
      await _leave(tester);

      await pump(tester, const DealFormScreen(initialClientId: 4));
      expect(_text(tester, find.byType(TextField).first), isEmpty);
    });

    testWidgets('the task sheet says so inline and can discard',
        (tester) async {
      var saves = 0;
      Widget sheet() => Scaffold(
            body: SingleChildScrollView(
              child: TaskForm(onSave: (_) async => saves++),
            ),
          );
      await pump(tester, sheet());
      await tester.enterText(find.byType(TextField).first, 'Call the bank');
      await tester.pump(const Duration(milliseconds: 600));
      await _leave(tester);

      await pump(tester, sheet());
      expect(_text(tester, find.byType(TextField).first), 'Call the bank');
      expect(find.byType(DraftRestoredNotice), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('draft-discard'))).height,
          greaterThanOrEqualTo(AppMetrics.minHitTarget));

      await tester.tap(find.byKey(const ValueKey('draft-discard')));
      await tester.pumpAndSettle();
      expect(_text(tester, find.byType(TextField).first), isEmpty);
      expect(find.byType(DraftRestoredNotice), findsNothing);
      expect(await _stored('task:new'), isNull);
      expect(saves, 0);
    });

    testWidgets('a saved task clears its draft', (tester) async {
      Widget sheet() => Scaffold(
            body: SingleChildScrollView(
              child: TaskForm(
                initialDueAt: DateTime(2030, 1, 1, 9),
                onSave: (_) async {},
              ),
            ),
          );
      await pump(tester, sheet());
      await tester.enterText(find.byType(TextField).first, 'Call the bank');
      await tester.pump(const Duration(milliseconds: 600));
      expect(await _stored('task:new'), isNotNull);

      final save = find.widgetWithText(AppFilledButton, 'Save task');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pump();
      await tester.pump();
      expect(await _stored('task:new'), isNull);
    });
  });

  for (final locale in kAcceptanceLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'the restored client form fits at 320 @1.5 in '
          '${locale.languageCode} ${brightness.name}', (tester) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            '${FormDraft.keyPrefix}-:client:new',
            jsonEncode({
              'fullName': 'Айгерим Серикбайқызы Нурланова',
              'type': 'BUYER',
              'tags': ['vip', 'ипотека'],
            }));
        Injector.clientsRepository = _clients;
        await expectNoOverflow(
          tester,
          BlocProvider(
            create: (_) => ClientsBloc(_clients),
            child: const ClientFormScreen(),
          ),
          size: const Size(320, 568),
          brightness: brightness,
          textScale: 1.5,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(PinnedActionBar), findsOneWidget);
        expect(find.byKey(const ValueKey('draft-restored')), findsOneWidget);
      });
    }
  }
}
