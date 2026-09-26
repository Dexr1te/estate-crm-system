import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/contact_follow_up.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_history_card.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/log_contact_sheet.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Contact that records itself.
///
/// A call started from the card is offered for logging on coming back to the
/// app, once, and only if the agent really left; the log sheet takes a time
/// other than now; and listings sent from the send sheet are written down
/// with the listings named, so the history and the match list both say what
/// went out.

final _now = DateTime(2026, 9, 25, 15, 30);

const _buyer = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  email: 'sokolova@mail.ru',
  type: ClientType.BUYER,
  wantedCity: 'Almaty',
  budgetMax: 30000000,
  agentName: 'Maria Kim-Doroshenko',
);

const _severny = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
  areaSqm: 62,
);

const _tverskaya = PropertyResponse(
  id: 8,
  title: 'Tverskaya 12, apartment 5 with a very long name for the row',
  address: 'Tverskaya 12',
  city: 'Almaty',
  price: 29500000,
  rooms: 2,
  areaSqm: 58,
);

const _agent = AuthResponse(
    userId: 5, fullName: 'Maria Kim-Doroshenko', role: Role.AGENT, teamId: 1);

final _sent = ClientActivity(
  id: 11,
  clientId: 1,
  type: ActivityType.MESSAGE,
  occurredAt: _now.subtract(const Duration(days: 2)),
  authorId: 5,
  authorName: 'Maria Kim-Doroshenko',
  properties: [
    ActivityProperty(id: 7, title: _severny.title),
    ActivityProperty(id: 8, title: _tverskaya.title),
  ],
);

late FakeClientsRepository _clients;
late FakeShareGateway _share;
late List<Uri> _opened;

void _install({List<PropertyMatch>? matches, List<ClientActivity>? history}) {
  _clients = FakeClientsRepository(
    clients: const [_buyer],
    matches: matches ??
        const [
          PropertyMatch(property: _severny),
          PropertyMatch(property: _tverskaya),
        ],
    activities: history ?? const [],
  );
  Injector.clientsRepository = _clients;
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.propertiesRepository =
      FakePropertiesRepository(const [_severny, _tverskaya]);
  _share = FakeShareGateway();
  Injector.shareGateway = _share;
  _opened = [];
  ContactActions.opener = (uri, _) async {
    _opened.add(uri);
    return true;
  };
}

Future<void> _pumpDetail(WidgetTester tester) async {
  final auth = AuthBloc(FakeAuthRepository(user: _agent))
    ..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  await expectNoOverflow(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
      ],
      child: const ClientDetailScreen(id: 1),
    ),
    size: const Size(390, 844),
    brightness: Brightness.light,
    textScale: 1.0,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _lifecycle(WidgetTester tester, List<AppLifecycleState> states) {
  for (final state in states) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

Widget _card(List<ClientActivity> activities, {ValueChanged<int>? onOpen}) =>
    Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClientHistoryCard(
            activities: activities,
            onLog: () {},
            onRetry: () {},
            onDelete: (_) {},
            canDelete: (a) => a.authorId == 5,
            onEdit: (_) {},
            onOpenProperty: onOpen ?? (_) {},
          ),
        ],
      ),
    );

Widget _form(LogContactSave onSave, {DateTime? at}) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AppSheetShell(
          title: 'Log this call?',
          subtitle: 'One tap puts it in the history. A note is optional.',
          child: LogContactForm(onSave: onSave, initialOccurredAt: at),
        ),
      ),
    );

void main() {
  setUp(() => AppClock.freeze(_now));
  tearDown(() {
    AppClock.reset();
    ContactActions.resetOpener();
  });

  group('the follow-up itself', () {
    late DateTime clock;
    late List<PendingContact> offered;
    late ContactFollowUp followUp;

    setUp(() {
      clock = _now;
      offered = [];
      followUp = ContactFollowUp(onReturn: offered.add, now: () => clock);
    });

    test('leaving and coming back offers the contact, once', () {
      followUp.begin(1, ActivityType.CALL);
      followUp.didChangeAppLifecycleState(AppLifecycleState.inactive);
      followUp.didChangeAppLifecycleState(AppLifecycleState.hidden);
      followUp.didChangeAppLifecycleState(AppLifecycleState.paused);
      clock = clock.add(const Duration(minutes: 4));
      followUp.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(offered, hasLength(1));
      expect(offered.single.type, ActivityType.CALL);
      expect(offered.single.clientId, 1);
      expect(offered.single.startedAt, _now);

      followUp.didChangeAppLifecycleState(AppLifecycleState.paused);
      followUp.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(offered, hasLength(1), reason: 'the offer is spent once made');
    });

    test('a cancelled "Call?" alert only makes the app inactive: no offer', () {
      followUp.begin(1, ActivityType.CALL);
      followUp.didChangeAppLifecycleState(AppLifecycleState.inactive);
      followUp.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(offered, isEmpty);
    });

    test('an unrelated trip out of the app much later is not the call', () {
      followUp.begin(1, ActivityType.CALL);
      clock = clock.add(const Duration(minutes: 3));
      followUp.didChangeAppLifecycleState(AppLifecycleState.paused);
      followUp.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(offered, isEmpty);
      expect(followUp.pending, isNull);
    });

    test('coming back after the timeout offers nothing', () {
      followUp.begin(1, ActivityType.EMAIL);
      followUp.didChangeAppLifecycleState(AppLifecycleState.paused);
      clock = clock.add(const Duration(minutes: 31));
      followUp.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(offered, isEmpty);
      expect(followUp.pending, isNull);
    });

    test('a newer contact replaces one never followed up', () {
      followUp.begin(1, ActivityType.CALL);
      followUp.begin(1, ActivityType.EMAIL);
      followUp.didChangeAppLifecycleState(AppLifecycleState.paused);
      followUp.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(offered.single.type, ActivityType.EMAIL);
    });
  });

  group('on the client card', () {
    setUp(_install);

    testWidgets(
        'call, leave, come back: the call is offered and one tap logs it at '
        'the time it began', (tester) async {
      await _pumpDetail(tester);
      await _tapVisible(tester, find.widgetWithText(AppFilledButton, 'Call'));
      expect(_opened.single.scheme, 'tel');

      _lifecycle(tester, const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]);
      AppClock.freeze(_now.add(const Duration(minutes: 6)));
      _lifecycle(tester, const [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Log this call?'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(_clients.logCalls, hasLength(1));
      expect(_clients.logCalls.single.type, ActivityType.CALL);
      expect(_clients.logCalls.single.occurredAt, _now);
      expect(find.text('Contact logged'), findsOneWidget);
    });

    testWidgets('an email started here is offered as an email', (tester) async {
      await _pumpDetail(tester);
      await _tapVisible(tester, find.widgetWithText(AppGhostButton, 'Message'));
      expect(_opened.single.scheme, 'mailto');

      _lifecycle(tester, const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Log this email?'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(_clients.logCalls.single.type, ActivityType.EMAIL);
    });

    testWidgets('without leaving the app, nothing is offered', (tester) async {
      await _pumpDetail(tester);
      await _tapVisible(tester, find.widgetWithText(AppFilledButton, 'Call'));

      _lifecycle(tester,
          const [AppLifecycleState.inactive, AppLifecycleState.resumed]);
      await tester.pumpAndSettle();

      expect(find.text('Log this call?'), findsNothing);
      expect(_clients.logCalls, isEmpty);
    });

    testWidgets('dismissing the offer logs nothing', (tester) async {
      await _pumpDetail(tester);
      await _tapVisible(tester, find.widgetWithText(AppFilledButton, 'Call'));
      _lifecycle(tester, const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Log this call?'), findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Log this call?'), findsNothing);
      expect(_clients.logCalls, isEmpty);
    });
  });

  group('when it happened', () {
    Future<DateTime?> saveWith(WidgetTester tester, String chip) async {
      DateTime? saved;
      await expectNoOverflow(
        tester,
        _form((_, __, at) async => saved = at),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      if (chip.isNotEmpty) {
        await tester.tap(find.text(chip));
        await tester.pump();
      }
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      return saved;
    }

    testWidgets('the form starts at just now', (tester) async {
      expect(await saveWith(tester, ''), _now);
    });

    testWidgets('an hour ago', (tester) async {
      expect(await saveWith(tester, '1 hour ago'),
          _now.subtract(const Duration(hours: 1)));
    });

    testWidgets('yesterday', (tester) async {
      expect(await saveWith(tester, 'Yesterday'),
          _now.subtract(const Duration(days: 1)));
    });

    testWidgets('a picked date keeps the time of day', (tester) async {
      DateTime? saved;
      await expectNoOverflow(
        tester,
        _form((_, __, at) async => saved = at),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.tap(find.byKey(const ValueKey('contact-when-date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('21'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Sep 21'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, DateTime(2026, 9, 21, 15, 30));
    });

    testWidgets('a time that has not come yet is refused before saving',
        (tester) async {
      var calls = 0;
      await expectNoOverflow(
        tester,
        _form((_, __, ___) async => calls++,
            at: _now.add(const Duration(hours: 2))),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('That time has not come yet'), findsOneWidget);
      expect(calls, 0);
    });

    testWidgets('logging from the card sends the chosen time', (tester) async {
      _install();
      await _pumpDetail(tester);
      await _tapVisible(tester, find.text('Log the first contact'));
      await tester.tap(find.text('Yesterday'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(_clients.logCalls.single.occurredAt,
          _now.subtract(const Duration(days: 1)));
      expect(find.textContaining('Yesterday, 15:30'), findsOneWidget);
    });

    testWidgets('tapping an entry corrects it', (tester) async {
      _install(history: [
        ClientActivity(
          id: 3,
          clientId: 1,
          type: ActivityType.CALL,
          occurredAt: _now.subtract(const Duration(minutes: 10)),
          authorId: 5,
          authorName: 'Maria Kim-Doroshenko',
        ),
      ]);
      await _pumpDetail(tester);
      await _tapVisible(tester, find.textContaining('Today, 15:20'));
      expect(find.text('Edit entry'), findsOneWidget);

      await tester.tap(find.text('Email').last);
      await tester.tap(find.text('1 hour ago'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final updated = _clients.activities.single;
      expect(updated.type, ActivityType.EMAIL);
      expect(updated.occurredAt, _now.subtract(const Duration(hours: 1)));
      expect(find.text('Entry updated'), findsOneWidget);
    });
  });

  group('what was sent', () {
    Future<void> openSendSheet(WidgetTester tester) async {
      await _pumpDetail(tester);
      final button = find.widgetWithText(AppFilledButton, 'Send listings');
      await tester.scrollUntilVisible(button, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('a share that went through is logged with the listings sent',
        (tester) async {
      _install();
      await openSendSheet(tester);
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(_share.calls, 1);
      expect(_clients.logCalls, hasLength(1));
      expect(_clients.logCalls.single.type, ActivityType.MESSAGE);
      expect(_clients.logCalls.single.propertyIds, [7, 8]);
      expect(find.text("Saved to the client's history"), findsOneWidget);

      expect(find.text('Sent 2 listings'), findsOneWidget);
      expect(find.text('Sent Sep 25, 2026'), findsNWidgets(2),
          reason: 'each match row now says it went out today');
    });

    testWidgets('WhatsApp, once opened, is logged the same way',
        (tester) async {
      _install();
      await openSendSheet(tester);
      await tester.tap(find
          .text('Tverskaya 12, apartment 5 with a very long '
              'name for the row')
          .last);
      await tester.pump();
      await tester.tap(find.text('WhatsApp'));
      await tester.pumpAndSettle();

      expect(_opened.single.host, 'wa.me');
      expect(_clients.logCalls.single.propertyIds, [7]);
    });

    testWidgets('a dismissed share logs nothing', (tester) async {
      _install();
      _share.outcome = ShareOutcome.dismissed;
      await openSendSheet(tester);
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(_clients.logCalls, isEmpty);
    });

    testWidgets('failing to log after a good send shows no error',
        (tester) async {
      _install();
      _clients.logError = DioException(
          requestOptions: RequestOptions(path: '/clients/1/activities'));
      await openSendSheet(tester);
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(_clients.logCalls, hasLength(1));
      expect(find.text('Could not open sending'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Share'), findsNothing, reason: 'the sheet closed');
    });

    testWidgets('the history names what was sent, and opens it',
        (tester) async {
      final opened = <int>[];
      await expectNoOverflow(tester, _card([_sent], onOpen: opened.add),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);

      expect(find.text('Sent 2 listings'), findsOneWidget);
      expect(find.text(_severny.title), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sent-listing-8')));
      expect(opened, [8]);
    });

    testWidgets('a match row says when it was sent, beside when it was shown',
        (tester) async {
      _install(matches: [
        PropertyMatch(
          property: _severny,
          lastShownAt: DateTime(2026, 9, 12, 11),
          lastSentAt: DateTime(2026, 9, 20, 9),
        ),
        PropertyMatch(property: _tverskaya, lastSentAt: DateTime(2026, 9, 3)),
      ]);
      await _pumpDetail(tester);

      expect(
          find.text('Shown Sep 12, 2026 · Sent Sep 20, 2026'), findsOneWidget);
      expect(find.text('Sent Sep 3, 2026'), findsOneWidget);
    });
  });

  group('fits every screen', () {
    forEachAcceptanceCase('history card with sent listings',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, _card([_sent]),
          size: size, brightness: brightness, textScale: scale);
    });

    forEachAcceptanceCase('follow-up sheet with the when field',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(tester, _form((_, __, ___) async {}, at: _now),
          size: size, brightness: brightness, textScale: scale);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets(
          'sent listings, when field and match row in '
          '${locale.languageCode}', (tester) async {
        await expectNoOverflow(tester, _card([_sent]),
            size: const Size(320, 568),
            brightness: Brightness.dark,
            textScale: 1.5,
            locale: locale);
        await expectNoOverflow(tester, _form((_, __, ___) async {}),
            size: const Size(320, 568),
            brightness: Brightness.light,
            textScale: 1.5,
            locale: locale);

        _install(matches: [
          PropertyMatch(
            property: _tverskaya,
            overBudget: true,
            lastShownAt: DateTime(2026, 9, 12, 11),
            lastSentAt: DateTime(2026, 9, 20, 9),
          ),
        ], history: [
          _sent
        ]);
        final auth = AuthBloc(FakeAuthRepository(user: _agent))
          ..add(AuthCheckEvent());
        addTearDown(auth.close);
        await expectNoOverflow(
          tester,
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: auth),
              BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
            ],
            child: const ClientDetailScreen(id: 1),
          ),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.5,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
