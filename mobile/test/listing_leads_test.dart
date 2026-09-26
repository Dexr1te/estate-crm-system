import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_card.dart';
import 'package:real_estate_crm/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_copy.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_share_link_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Buyers who say "I'm interested" on a listing's public page: a badge on
/// their card, a "New leads" chip that finds the last week's, a notification
/// that opens the client, and the count of enquiries on the listing's link.

final _now = DateTime(2026, 9, 26, 15, 30);

final _clients = [
  ClientResponse(
    id: 1,
    fullName: 'Dana Serikova-Abdrakhmanova from the public page',
    phone: '+7 701 222-33-44',
    source: ClientSource.publicLink,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  ClientResponse(
    id: 2,
    fullName: 'Erlan Old Lead',
    source: ClientSource.publicLink,
    createdAt: _now.subtract(const Duration(days: 30)),
  ),
  ClientResponse(
    id: 3,
    fullName: 'Алексей Петров',
    type: ClientType.SELLER,
    source: ClientSource.imported,
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
  ClientResponse(
    id: 4,
    fullName: 'Семья Дорошенко',
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
];

Widget _clientsScreen() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
          create: (_) => ClientsBloc(FakeClientsRepository(clients: _clients)),
        ),
      ],
      child: const ClientsScreen(),
    );

AppNotification _lead({int? target = 9}) => AppNotification(
      id: 1,
      type: NotificationType.listingLead,
      targetId: target,
      params: const {
        'clientName': 'Dana Serikova',
        'propertyTitle': 'Severny Residence, apt 84',
        'propertyId': 7,
        'phone': '+7 701 222-33-44',
      },
      createdAt: _now,
    );

const _flat = PropertyResponse(id: 7, title: 'Severny Residence, apt 84');

Widget _shareCard() => Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PropertyShareLinkCard(
            propertyId: _flat.id, title: _flat.title, canRevoke: true),
      ),
    );

void _installLink(int leads) {
  final repo = FakePropertiesRepository(const [_flat]);
  repo.shareLinks[_flat.id] = PropertyShareLink(
    url: FakePropertiesRepository.shareUrlFor(7),
    viewCount: 12,
    lastViewedAt: DateTime(2026, 9, 24, 18),
    createdAt: DateTime(2026, 9, 20),
    leadCount: leads,
  );
  Injector.propertiesRepository = repo;
  Injector.shareGateway = FakeShareGateway();
}

Future<void> _show(WidgetTester tester, Widget child,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, child,
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _tapLeads(WidgetTester tester) async {
  final pill = find.byKey(const ValueKey('clients-filter-leads'));
  await tester.ensureVisible(pill);
  await tester.pumpAndSettle();
  await tester.tap(pill);
}

void main() {
  setUp(() => AppClock.freeze(_now));
  tearDown(AppClock.reset);

  group('the client list', () {
    testWidgets('marks public-page and imported cards, and nothing else',
        (tester) async {
      await _show(tester, _clientsScreen());

      expect(find.byKey(const ValueKey('client-source-public-link')),
          findsNWidgets(2));
      expect(
          find.byKey(const ValueKey('client-source-import')), findsOneWidget);
      expect(find.text('From the public link'), findsNWidgets(2));
      expect(find.text('Imported'), findsOneWidget);
      expect(find.textContaining('PUBLIC_LINK'), findsNothing);
    });

    testWidgets('"New leads" keeps public-page buyers from the last week',
        (tester) async {
      await _show(tester, _clientsScreen());
      expect(find.byType(ClientCard), findsNWidgets(4));

      await _tapLeads(tester);
      await tester.pumpAndSettle();
      expect(find.byType(ClientCard), findsOneWidget);
      expect(find.textContaining('Dana Serikova'), findsOneWidget);

      await tester.ensureVisible(find.text('All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.byType(ClientCard), findsNWidgets(4));
    });

    test('a new lead is a public-page card at most a week old', () {
      ClientSummary card(ClientSource source, int daysAgo) => ClientSummary(
          id: 1,
          fullName: 'x',
          type: ClientType.BUYER,
          source: source,
          createdAt: _now.subtract(Duration(days: daysAgo)));
      expect(card(ClientSource.publicLink, 0).isNewLead(_now), isTrue);
      expect(card(ClientSource.publicLink, 7).isNewLead(_now), isTrue);
      expect(card(ClientSource.publicLink, 8).isNewLead(_now), isFalse);
      expect(card(ClientSource.manual, 0).isNewLead(_now), isFalse);
      expect(card(ClientSource.imported, 0).isNewLead(_now), isFalse);
    });

    test('an unknown source from a newer server reads as typed in', () {
      final c = ClientResponse.fromJson(
          {'id': 1, 'fullName': 'x', 'source': 'CARRIER_PIGEON'});
      expect(c.source, ClientSource.manual);
      expect(ClientResponse.fromJson({'id': 1}).source, ClientSource.manual);
      expect(ClientResponse.fromJson({'id': 1, 'source': 'PUBLIC_LINK'}).source,
          ClientSource.publicLink);
    });
  });

  group('the notification', () {
    test('reads as a sentence in every language, with the phone below',
        () async {
      final expected = {
        'en': 'Dana Serikova is interested in Severny Residence, apt 84',
        'ru': 'Dana Serikova интересуется объектом Severny Residence, apt 84',
        'kk': 'Dana Serikova Severny Residence, apt 84 нысанына '
            'қызығушылық танытты',
      };
      for (final entry in expected.entries) {
        final l10n = await AppLocalizations.delegate.load(Locale(entry.key));
        final copy = notificationCopy(l10n, _lead());
        expect(copy.title, entry.value);
        expect(copy.detail, '+7 701 222-33-44');
      }
    });

    test('opens the client it is about', () {
      expect(notificationTarget(_lead())?.location, '/clients/9');
      expect(notificationTarget(_lead(target: null)), isNull);
    });

    testWidgets('a tap in the feed opens the client', (tester) async {
      final repo = FakeNotificationsRepository([_lead()]);
      Injector.notificationsRepository = repo;
      addTearDown(() =>
          Injector.notificationsRepository = FakeNotificationsRepository());
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(initialLocation: '/notifications', routes: [
          GoRoute(
              path: '/notifications',
              builder: (_, __) => const NotificationsScreen()),
          GoRoute(
              path: '/clients/:id',
              builder: (_, s) =>
                  Scaffold(body: Text('client ${s.pathParameters['id']}'))),
        ]),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('notification-1')));
      await tester.pumpAndSettle();
      expect(find.text('client 9'), findsOneWidget);
      expect(repo.markedRead, [1]);
    });
  });

  group('the listing\'s public link', () {
    testWidgets('says how many enquiries came through it', (tester) async {
      _installLink(3);
      await _show(tester, _shareCard());
      expect(
          find.byKey(const ValueKey('share-link-enquiries')), findsOneWidget);
      expect(find.text('3 enquiries from this link'), findsOneWidget);
    });

    testWidgets('says nothing about enquiries before the first one',
        (tester) async {
      _installLink(0);
      await _show(tester, _shareCard());
      expect(find.byKey(const ValueKey('share-link-enquiries')), findsNothing);
    });

    testWidgets('counts in Russian', (tester) async {
      _installLink(5);
      await _show(tester, _shareCard(), locale: const Locale('ru'));
      expect(find.text('5 заявок по ссылке'), findsOneWidget);
    });

    testWidgets('counts in Kazakh', (tester) async {
      _installLink(1);
      await _show(tester, _shareCard(), locale: const Locale('kk'));
      expect(find.text('Сілтеме арқылы 1 өтінім'), findsOneWidget);
    });
  });

  group('fits every screen', () {
    forEachAcceptanceCase('clients with leads',
        (tester, size, brightness, scale) async {
      await _show(tester, _clientsScreen(),
          size: size, brightness: brightness, textScale: scale);
      await _tapLeads(tester);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachAcceptanceCase('link card with enquiries',
        (tester, size, brightness, scale) async {
      _installLink(128);
      await _show(tester, _shareCard(),
          size: size, brightness: brightness, textScale: scale);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('leads in ${locale.languageCode} at 320, 1.5x',
          (tester) async {
        await _show(tester, _clientsScreen(),
            size: const Size(320, 568),
            brightness: Brightness.dark,
            textScale: 1.5,
            locale: locale);
        await _tapLeads(tester);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        _installLink(22);
        await _show(tester, _shareCard(),
            size: const Size(320, 568),
            brightness: Brightness.dark,
            textScale: 1.5,
            locale: locale);

        Injector.notificationsRepository =
            FakeNotificationsRepository([_lead()]);
        addTearDown(() =>
            Injector.notificationsRepository = FakeNotificationsRepository());
        await _show(tester, const NotificationsScreen(),
            size: const Size(320, 568),
            brightness: Brightness.light,
            textScale: 1.5,
            locale: locale);
      });
    }
  });
}
