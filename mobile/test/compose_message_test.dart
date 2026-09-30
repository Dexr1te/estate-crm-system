import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Writing to a client over WhatsApp or SMS from their card, from one of the
/// agency's templates: filled in for the client, the agent and a chosen
/// listing, edited freely, and written down as it was actually sent.

final _now = DateTime(2026, 9, 30, 11);

const _buyer = ClientResponse(
  id: 1,
  fullName: 'Irina Sokolova',
  phone: '+7 916 220-84-11',
  type: ClientType.BUYER,
  wantedCity: 'Almaty',
  budgetMax: 30000000,
  agentName: 'Somebody Else',
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

const _abay = PropertyResponse(
  id: 9,
  title: 'Flat on Abay',
  address: 'Abay 44',
  price: 19000000,
);

const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);

const _offer = MessageTemplate(
  id: 2,
  title: 'A listing for you',
  body: 'Hello, {client}! I have a property that may suit you:\n'
      '{listing}\n{address}\n{price}\n{link}\n{agent}',
);

const _intro = MessageTemplate(
  id: 1,
  title: 'Introduction',
  body: 'Hello, {client}! This is {agent}, your real estate agent.',
);

const _link = 'https://crm.test/l/severny';

late FakeClientsRepository _clients;
late FakeMessageTemplatesRepository _templates;
late List<Uri> _opened;
late bool _opens;

void _install({ClientResponse client = _buyer}) {
  _clients = FakeClientsRepository(
    clients: [client],
    matches: const [PropertyMatch(property: _severny)],
  );
  Injector.clientsRepository = _clients;
  Injector.dealsRepository = FakeDealsRepository(const []);
  final properties = FakePropertiesRepository(const [_abay, _severny]);
  properties.shareLinks[7] = const PropertyShareLink(url: _link);
  Injector.propertiesRepository = properties;
  _templates = FakeMessageTemplatesRepository(const [_intro, _offer]);
  Injector.messageTemplatesRepository = _templates;
  _opened = [];
  _opens = true;
  ContactActions.opener = (uri, _) async {
    _opened.add(uri);
    return _opens;
  };
}

Future<void> _pumpDetail(WidgetTester tester,
    {Size size = const Size(390, 844),
    double scale = 1.0,
    Locale locale = const Locale('en')}) async {
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
    size: size,
    brightness: Brightness.light,
    textScale: scale,
    locale: locale,
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openCompose(WidgetTester tester) =>
    _tap(tester, find.byKey(const ValueKey('client-compose')));

Future<void> _useTemplate(WidgetTester tester, String title) async {
  await _tap(tester, find.byKey(const Key('compose-use-template')));
  await _tap(tester, find.text(title).last);
}

Future<void> _chooseListing(WidgetTester tester, String title) async {
  await _tap(tester, find.byKey(const Key('compose-listing')));
  await _tap(tester, find.text(title).last);
}

String _text(WidgetTester tester) => tester
    .widget<EditableText>(find.descendant(
        of: find.byKey(const Key('compose-text')),
        matching: find.byType(EditableText)))
    .controller
    .text;

void main() {
  setUp(() => AppClock.freeze(_now));
  tearDown(() {
    AppClock.reset();
    ContactActions.resetOpener();
  });

  testWidgets('a template fills in the client and the agent signed in',
      (tester) async {
    _install();
    await _pumpDetail(tester);
    await _openCompose(tester);
    expect(find.text('Write to the client'), findsOneWidget);

    await _useTemplate(tester, 'Introduction');
    expect(_text(tester),
        'Hello, Irina Sokolova! This is Maria Kim, your real estate agent.');
  });

  testWidgets('without a listing its lines drop out; choosing one fills them',
      (tester) async {
    _install();
    await _pumpDetail(tester);
    await _openCompose(tester);
    await _useTemplate(tester, 'A listing for you');
    expect(_text(tester),
        'Hello, Irina Sokolova! I have a property that may suit you:\nMaria Kim');

    await _chooseListing(tester, 'Severny Residence, apartment 84');
    expect(
        _text(tester),
        [
          'Hello, Irina Sokolova! I have a property that may suit you:',
          'Severny Residence, apartment 84',
          'Severny Residence 12, Almaty',
          r'$28.0M',
          _link,
          'Maria Kim',
        ].join('\n'));
  });

  testWidgets('a listing with no public link sends no link, and none is made',
      (tester) async {
    _install();
    final repo = Injector.propertiesRepository as FakePropertiesRepository;
    await _pumpDetail(tester);
    await _openCompose(tester);
    await _useTemplate(tester, 'A listing for you');
    await _chooseListing(tester, 'Flat on Abay');

    expect(_text(tester), isNot(contains('https://')));
    expect(_text(tester), contains('Abay 44\n\$19.0M\nMaria Kim'));
    expect(repo.shareLinkRequests, isEmpty,
        reason: 'the picker reads the link a listing has; it never makes one');
  });

  testWidgets('what the agent typed is not overwritten by a later listing',
      (tester) async {
    _install();
    await _pumpDetail(tester);
    await _openCompose(tester);
    await _useTemplate(tester, 'A listing for you');
    await tester.enterText(
        find.byKey(const Key('compose-text')), 'My own words, {client}.');
    await tester.pump();

    await _chooseListing(tester, 'Severny Residence, apartment 84');
    expect(_text(tester), 'My own words, {client}.');
  });

  testWidgets('WhatsApp sends the edited text and the history records it',
      (tester) async {
    _install();
    await _pumpDetail(tester);
    await _openCompose(tester);
    await _useTemplate(tester, 'A listing for you');
    await _chooseListing(tester, 'Severny Residence, apartment 84');
    await tester.enterText(find.byKey(const Key('compose-text')),
        '${_text(tester)}\nP.S. Viewings on {day} too.');
    await tester.pump();
    await _tap(tester, find.byKey(const Key('compose-whatsapp')));

    final sent = _opened.single;
    expect(sent.host, 'wa.me');
    expect(sent.path, '/79162208411');
    final text = sent.queryParameters['text']!;
    expect(text, startsWith('Hello, Irina Sokolova!'));
    expect(text, contains(_link));
    expect(text, endsWith('P.S. Viewings on too.'));
    expect(text, isNot(contains('{')),
        reason: 'no placeholder reaches a client');

    final logged = _clients.logCalls.single;
    expect(logged.type, ActivityType.MESSAGE);
    expect(logged.note, text, reason: 'the history keeps what was sent');
    expect(logged.propertyIds, [7]);
    expect(find.text('Write to the client'), findsNothing,
        reason: 'a send that went through closes the sheet');
    expect(find.text("Saved to the client's history"), findsOneWidget);
  });

  testWidgets('SMS opens the messages app with the text, placeholders filled',
      (tester) async {
    _install();
    await _pumpDetail(tester);
    await _openCompose(tester);
    await tester.enterText(find.byKey(const Key('compose-text')),
        'Hi {client}, it is {agent}. See {listing} soon.');
    await tester.pump();
    await _tap(tester, find.byKey(const Key('compose-sms')));

    final sent = _opened.single;
    expect(sent.scheme, 'sms');
    expect(sent.path, '+79162208411');
    expect(sent.query, isNot(contains('+')),
        reason: 'spaces are %20, which iOS reads as spaces');
    expect(Uri.decodeComponent(sent.query.substring('body='.length)),
        'Hi Irina Sokolova, it is Maria Kim. See soon.');
    expect(_clients.logCalls.single.note,
        'Hi Irina Sokolova, it is Maria Kim. See soon.');
    expect(_clients.logCalls.single.propertyIds, isEmpty);
  });

  testWidgets('a send that does not open keeps the sheet and logs nothing',
      (tester) async {
    _install();
    _opens = false;
    await _pumpDetail(tester);
    await _openCompose(tester);
    await _useTemplate(tester, 'Introduction');
    await _tap(tester, find.byKey(const Key('compose-whatsapp')));

    expect(_clients.logCalls, isEmpty);
    expect(find.text('Write to the client'), findsOneWidget);
    expect(find.text('Could not open sending'), findsOneWidget);
  });

  testWidgets('with nothing written there is nothing to send', (tester) async {
    _install();
    await _pumpDetail(tester);
    await _openCompose(tester);
    await _tap(tester, find.byKey(const Key('compose-sms')));
    expect(_opened, isEmpty);
  });

  testWidgets('with no phone on the card the sheet does not open',
      (tester) async {
    _install(
        client: const ClientResponse(
            id: 1, fullName: 'Irina Sokolova', type: ClientType.BUYER));
    await _pumpDetail(tester);
    await _openCompose(tester);
    expect(find.text('Write to the client'), findsNothing);
    expect(find.text('No phone number on file'), findsOneWidget);
  });

  testWidgets('templates that will not load say so and leave the text alone',
      (tester) async {
    _install();
    _templates.readError = Exception('offline');
    await _pumpDetail(tester);
    await _openCompose(tester);
    await tester.enterText(find.byKey(const Key('compose-text')), 'Draft');
    await _tap(tester, find.byKey(const Key('compose-use-template')));

    expect(find.text('Could not load templates'), findsOneWidget);
    expect(_text(tester), 'Draft');
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the compose sheet in ${locale.languageCode} at 1.5x',
        (tester) async {
      _install();
      await _pumpDetail(tester,
          size: const Size(320, 568), scale: 1.5, locale: locale);
      await _openCompose(tester);
      expect(tester.takeException(), isNull);
      await _useTemplate(tester, 'A listing for you');
      await _chooseListing(tester, 'Severny Residence, apartment 84');
      expect(tester.takeException(), isNull);
    });
  }
}
