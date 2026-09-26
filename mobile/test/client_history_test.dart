import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_history_card.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/log_contact_sheet.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// A client's history of contact: every call, message, email and note.
///
/// The point of the card is that whoever opens the client next knows where
/// things stand, so what matters here is that the timeline reads newest first
/// with who and when, that an empty history asks for its first entry, that
/// logging and removing are explicit, and that only the author or someone
/// running the team is offered the removal at all.

final _now = DateTime(2026, 9, 25, 15, 30);

const _client = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  phone: '+7 916 220-84-11',
  email: 'sokolova@mail.ru',
  type: ClientType.SELLER,
  agentName: 'Maria Kim-Doroshenko',
);

final _history = [
  ClientActivity(
    id: 1,
    clientId: 1,
    type: ActivityType.CALL,
    note: 'Wants to see flats on the left bank before the end of the month, '
        'mortgage pre-approved, will bring her husband to the second viewing.',
    occurredAt: _now.subtract(const Duration(hours: 2)),
    authorId: 5,
    authorName: 'Maria Kim-Doroshenko',
  ),
  ClientActivity(
    id: 2,
    clientId: 1,
    type: ActivityType.MESSAGE,
    note: 'Sent the Severny Residence listing',
    occurredAt: _now.subtract(const Duration(days: 1)),
    authorId: 9,
    authorName: 'Aleksandr Konstantinovich Vishnevsky-Rozhdestvensky',
  ),
  ClientActivity(
    id: 3,
    clientId: 1,
    type: ActivityType.EMAIL,
    occurredAt: _now.subtract(const Duration(days: 40)),
  ),
];

const _agent = AuthResponse(
    userId: 5, fullName: 'Maria Kim-Doroshenko', role: Role.AGENT, teamId: 1);
const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

late FakeClientsRepository _clients;

Widget _detail({AuthBloc? auth}) => MultiBlocProvider(
      providers: [
        if (auth != null)
          BlocProvider.value(value: auth)
        else
          BlocProvider(
              create: (_) => AuthBloc(FakeAuthRepository(user: _agent))
                ..add(AuthCheckEvent())),
        BlocProvider(
            create: (_) =>
                ClientsBloc(FakeClientsRepository(clients: const []))),
      ],
      child: const ClientDetailScreen(id: 1),
    );

Widget _card(List<ClientActivity>? activities) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClientHistoryCard(
            activities: activities,
            onLog: () {},
            onRetry: () {},
            onDelete: (_) {},
            canDelete: (a) => a.authorId == 5,
          ),
        ],
      ),
    );

Widget _sheet() => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: AppSheetShell(
          title: 'Log contact',
          child: LogContactForm(onSave: (_, __, ___) async {}),
        ),
      ),
    );

Future<void> _pumpDetail(WidgetTester tester,
    {AuthResponse me = _agent}) async {
  // Signed in before the screen reads who may remove what, as it is in the app.
  final auth = AuthBloc(FakeAuthRepository(user: me))..add(AuthCheckEvent());
  addTearDown(auth.close);
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  await expectNoOverflow(
    tester,
    _detail(auth: auth),
    size: const Size(390, 844),
    brightness: Brightness.light,
    textScale: 1.0,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _clients = FakeClientsRepository(
        clients: const [_client], activities: List.of(_history));
    Injector.clientsRepository = _clients;
    Injector.dealsRepository = FakeDealsRepository(const []);
  });
  tearDown(AppClock.reset);

  forEachAcceptanceCase('history card — entries',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _card(_history),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('history card — empty',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _card(const []),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('log contact sheet',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _sheet(),
        size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('history card and sheet render in ${locale.languageCode}',
        (tester) async {
      for (final child in [_card(_history), _card(const []), _card(null)]) {
        await expectNoOverflow(tester, child,
            size: const Size(320, 568),
            brightness: Brightness.dark,
            textScale: 1.5,
            locale: locale);
      }
      await expectNoOverflow(tester, _sheet(),
          size: const Size(320, 568),
          brightness: Brightness.light,
          textScale: 1.5,
          locale: locale);
    });

    testWidgets('client detail with history renders in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(tester, _detail(),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the timeline reads newest first, with when and who',
      (tester) async {
    await _pumpDetail(tester);

    final call = find.text('Call');
    final message = find.text('Message');
    final email = find.text('Email');
    await tester.ensureVisible(email.last);
    expect(tester.getTopLeft(call.last).dy,
        lessThan(tester.getTopLeft(message.last).dy));
    expect(tester.getTopLeft(message.last).dy,
        lessThan(tester.getTopLeft(email.last).dy));

    expect(find.text('Today, 13:30 · Maria Kim-Doroshenko'), findsOneWidget);
    expect(find.textContaining('Yesterday, 15:30 · Aleksandr'), findsOneWidget);
    expect(find.textContaining('Former member'), findsOneWidget,
        reason: 'an entry whose author left still says someone wrote it');
  });

  testWidgets('an empty history invites the first entry', (tester) async {
    _clients.activities = const [];
    await _pumpDetail(tester);

    expect(find.text('No contact logged yet'), findsOneWidget);
    expect(find.text('Log the first contact'), findsOneWidget);
  });

  testWidgets('a history that fails to load says so and can be retried',
      (tester) async {
    _clients.activitiesError = Exception('offline');
    await _pumpDetail(tester);

    expect(find.text("Couldn't load the history"), findsOneWidget);
    expect(find.text('Irina Alexandrovna Sokolova'), findsWidgets,
        reason: 'the rest of the client still shows');

    _clients.activitiesError = null;
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Sent the Severny Residence listing'), findsOneWidget);
  });

  testWidgets('logging a note: text is required, then it lands on top',
      (tester) async {
    await _pumpDetail(tester);

    await tester.ensureVisible(find.text('Log contact'));
    await tester.tap(find.text('Log contact'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterPill, 'Note'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('A note needs some text'), findsOneWidget);
    expect(_clients.activities, hasLength(3));

    await tester.enterText(
        find.byType(TextFormField).last, 'Prefers WhatsApp after 18:00');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(_clients.activities.first.type, ActivityType.NOTE);
    expect(_clients.activities.first.note, 'Prefers WhatsApp after 18:00');
    expect(find.text('Contact logged'), findsOneWidget);
    expect(find.text('Prefers WhatsApp after 18:00'), findsOneWidget);
    expect(find.text('4'), findsOneWidget, reason: 'the count moved');
  });

  testWidgets('a call needs no note', (tester) async {
    await _pumpDetail(tester);
    await tester.ensureVisible(find.text('Log contact'));
    await tester.tap(find.text('Log contact'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(_clients.activities.first.type, ActivityType.CALL);
    expect(_clients.activities.first.note, isNull);
  });

  testWidgets('a failed save keeps the sheet open with what was typed',
      (tester) async {
    _clients.logError = DioException(
      requestOptions: RequestOptions(path: '/clients/1/activities'),
      response: Response(
        requestOptions: RequestOptions(path: '/clients/1/activities'),
        statusCode: 400,
        data: {'message': 'Note must be at most 2000 characters'},
      ),
    );
    await _pumpDetail(tester);
    await tester.ensureVisible(find.text('Log contact'));
    await tester.tap(find.text('Log contact'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'Long story');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Note must be at most 2000 characters'), findsOneWidget);
    expect(find.text('Long story'), findsOneWidget);
    expect(find.byType(LogContactForm), findsOneWidget);
  });

  testWidgets('the author removes their own entry after confirming',
      (tester) async {
    await _pumpDetail(tester);

    final remove = find.byTooltip('Remove entry');
    expect(remove, findsOneWidget,
        reason: 'an agent is offered only the entry they wrote');

    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(find.text('Remove this entry?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(_clients.activities.map((a) => a.id), [2, 3]);
    expect(find.textContaining('Wants to see flats'), findsNothing);
  });

  testWidgets('a long press also offers removal, and cancelling keeps it',
      (tester) async {
    await _pumpDetail(tester);

    final entry = find.textContaining('Wants to see flats');
    await tester.ensureVisible(entry);
    await tester.longPress(entry);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_clients.activities, hasLength(3));
  });

  testWidgets('a manager may remove anyone\'s entry', (tester) async {
    await _pumpDetail(tester, me: _manager);

    expect(find.byTooltip('Remove entry'), findsNWidgets(3));
  });

  testWidgets('the client list shows when someone last got in touch',
      (tester) async {
    await expectNoOverflow(
      tester,
      Scaffold(
        body: ListView(children: [
          ClientCard(
            client: ClientSummary(
              id: 1,
              fullName: 'Irina Alexandrovna Sokolova',
              type: ClientType.BUYER,
              lastContactAt: _now.subtract(const Duration(days: 1)),
            ),
            onTap: () {},
          ),
          ClientCard(
            client: ClientSummary(
              id: 2,
              fullName: 'Daniyar',
              type: ClientType.BUYER,
              lastContactAt: _now.subtract(const Duration(days: 4)),
            ),
            onTap: () {},
          ),
          const ClientCard(
            client: ClientSummary(
                id: 3, fullName: 'Madina', type: ClientType.SELLER),
            onTap: _noop,
          ),
        ]),
      ),
      size: const Size(320, 568),
      brightness: Brightness.light,
      textScale: 1.5,
    );

    expect(find.textContaining('Contacted yesterday'), findsOneWidget);
    expect(find.textContaining('Contacted 4 days ago'), findsOneWidget);
    expect(find.textContaining('Contacted'), findsNWidgets(2));
  });

  test('the list keeps the latest contact across a client\'s deal rows', () {
    final joined = ClientSummary.join(const [
      ClientResponse(id: 1, fullName: 'Irina'),
    ], [
      ClientListItem(id: 1, lastContactAt: DateTime(2026, 9, 20)),
      ClientListItem(id: 1, lastContactAt: DateTime(2026, 9, 24)),
      const ClientListItem(id: 1),
    ]);
    expect(joined.single.lastContactAt, DateTime(2026, 9, 24));
  });
}

void _noop() {}
