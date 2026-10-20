import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/notifications/push_gateway.dart';
import 'package:real_estate_crm/core/notifications/push_handler.dart';
import 'package:real_estate_crm/core/utils/launch_gate.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);

class _FakePushGateway implements PushGateway {
  final topics = <String>{};
  final log = <String>[];
  int permissionRequests = 0;
  bool offline = false;
  PushMessage? launch;
  final receivedMessages = StreamController<PushMessage>.broadcast();
  final openedMessages = StreamController<PushMessage>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<String?> token() async => 'token-1';

  @override
  Future<void> subscribe(String topic) async {
    if (offline) throw StateError('offline');
    topics.add(topic);
    log.add('+$topic');
  }

  @override
  Future<void> unsubscribe(String topic) async {
    if (offline) throw StateError('offline');
    topics.remove(topic);
    log.add('-$topic');
  }

  @override
  Stream<PushMessage> get received => receivedMessages.stream;

  @override
  Stream<PushMessage> get opened => openedMessages.stream;

  @override
  Future<PushMessage?> launchMessage() async => launch;
}

class _Gate extends ChangeNotifier implements LaunchGate {
  _Gate({bool open = true}) : _open = open;

  bool _open;

  @override
  bool get isOpen => _open;

  void unlock() {
    _open = true;
    notifyListeners();
  }
}

class _Harness {
  final gateway = _FakePushGateway();
  final routes = <String>[];
  final links = <Uri>[];
  final banners = <PushMessage>[];
  late final AuthBloc auth;
  late final PushHandler push;
}

Future<_Harness> _start({
  AuthResponse? user,
  LaunchGate? gate,
  PushMessage? launch,
  bool offline = false,
}) async {
  final h = _Harness();
  h.gateway
    ..launch = launch
    ..offline = offline;
  h.auth = AuthBloc(FakeAuthRepository(user: user))..add(AuthCheckEvent());
  addTearDown(h.auth.close);
  h.push = PushHandler(
    gateway: h.gateway,
    auth: h.auth,
    gate: gate,
    openRoute: h.routes.add,
    openLink: h.links.add,
    showInApp: h.banners.add,
  );
  addTearDown(h.push.dispose);
  h.push.setLanguage('ru');
  await h.push.start();
  await pumpEventQueue();
  return h;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PushMessage', () {
    test('a route must be a path inside the app', () {
      PushMessage routed(String value) => PushMessage(data: {'route': value});

      expect(routed('/deals/7').route, '/deals/7');
      expect(routed(' /tasks ').route, '/tasks');
      expect(routed('deals/7').route, isNull);
      expect(routed('//evil.example').route, isNull);
      expect(routed('https://evil.example').route, isNull);
      expect(const PushMessage().route, isNull);
    });

    test('a link must be https', () {
      PushMessage linked(String value) => PushMessage(data: {'url': value});

      expect(linked('https://example.com/update').link,
          Uri.parse('https://example.com/update'));
      expect(linked('http://example.com').link, isNull);
      expect(linked('estatecrm://accept-invite').link, isNull);
      expect(linked('not a url').link, isNull);
    });

    test('text is a title or a body that is not blank', () {
      expect(const PushMessage(title: 'Hi').hasText, isTrue);
      expect(const PushMessage(body: 'Hi').hasText, isTrue);
      expect(const PushMessage(title: ' ', body: '').hasText, isFalse);
    });
  });

  group('topics', () {
    test(
        'a signed-in agent is asked once and joins everyone, their language '
        'and their role', () async {
      final h = await _start(user: _agent);

      expect(h.gateway.permissionRequests, 1);
      expect(h.gateway.topics, {'all', 'lang_ru', 'role_agent'});
    });

    test('signing out leaves the role topic and keeps the broadcasts',
        () async {
      final h = await _start(user: _agent);

      h.auth.add(AuthLogoutEvent());
      await pumpEventQueue();

      expect(h.gateway.topics, {'all', 'lang_ru'});
      expect(h.gateway.log.last, '-role_agent');
      expect(h.gateway.permissionRequests, 1);
    });

    test('nobody signed in is not asked, yet still hears the broadcasts',
        () async {
      final h = await _start();

      expect(h.gateway.permissionRequests, 0);
      expect(h.gateway.topics, {'all', 'lang_ru'});
    });

    test('changing the language moves the language topic', () async {
      final h = await _start(user: _agent);

      h.push.setLanguage('kk');
      await pumpEventQueue();

      expect(h.gateway.topics, {'all', 'lang_kk', 'role_agent'});
      expect(h.gateway.log, containsAllInOrder(['-lang_ru']));
    });

    test('topics joined on an earlier run are tidied, not joined again',
        () async {
      SharedPreferences.setMockInitialValues({
        PushHandler.topicsKey: ['all', 'lang_en', 'role_manager'],
      });

      final h = await _start(user: _agent);

      expect(
          h.gateway.log,
          unorderedEquals(
              ['+lang_ru', '+role_agent', '-lang_en', '-role_manager']));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(PushHandler.topicsKey),
          ['all', 'lang_ru', 'role_agent']);
    });

    test('a subscription that failed offline is tried again on the next change',
        () async {
      final h = await _start(user: _agent, offline: true);
      expect(h.gateway.topics, isEmpty);

      h.gateway.offline = false;
      h.push.setLanguage('en');
      await pumpEventQueue();

      expect(h.gateway.topics, {'all', 'lang_en', 'role_agent'});
    });
  });

  group('opening a push', () {
    test(
        'the push the app was launched with waits for the lock, then opens '
        'its route', () async {
      final gate = _Gate(open: false);
      final h = await _start(
        user: _agent,
        gate: gate,
        launch: const PushMessage(data: {'route': '/deals/7'}),
      );
      expect(h.routes, isEmpty);

      gate.unlock();

      expect(h.routes, ['/deals/7']);
    });

    test('a tapped push opens its route once', () async {
      final h = await _start(user: _agent);

      h.gateway.openedMessages
          .add(const PushMessage(data: {'route': '/tasks'}));
      await pumpEventQueue();
      h.auth.add(AuthRefreshMeEvent());
      await pumpEventQueue();

      expect(h.routes, ['/tasks']);
    });

    test('nobody signed in is not taken into the CRM', () async {
      final h = await _start();

      h.gateway.openedMessages
          .add(const PushMessage(data: {'route': '/deals/7'}));
      await pumpEventQueue();

      expect(h.routes, isEmpty);
    });

    test(
        'a link opens outside the app, signed in or not, and wins over a '
        'route', () async {
      final h = await _start();

      h.gateway.openedMessages.add(const PushMessage(data: {
        'url': 'https://example.com/update',
        'route': '/deals/7',
      }));
      await pumpEventQueue();

      expect(h.links, [Uri.parse('https://example.com/update')]);
      expect(h.routes, isEmpty);
    });

    test('a push with nowhere to go does nothing', () async {
      final h = await _start(user: _agent);

      h.gateway.openedMessages.add(const PushMessage(title: 'Hello'));
      await pumpEventQueue();

      expect(h.routes, isEmpty);
      expect(h.links, isEmpty);
    });
  });

  group('while the app is open', () {
    test('a push with text shows in the app, one without does not', () async {
      final h = await _start(user: _agent);

      h.gateway.receivedMessages
        ..add(const PushMessage(title: 'New feature', body: 'Try it'))
        ..add(const PushMessage(data: {'route': '/tasks'}));
      await pumpEventQueue();

      expect(h.banners.map((m) => m.title), ['New feature']);
      expect(h.routes, isEmpty);
    });

    test('opening the banner goes where the push points', () async {
      final h = await _start(user: _agent);

      h.push.open(
          const PushMessage(title: 'Deal moved', data: {'route': '/deals/7'}));

      expect(h.routes, ['/deals/7']);
    });
  });

  group('on screen', () {
    GoRouter router() {
      Widget page(String name) => Scaffold(body: Center(child: Text(name)));
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/tasks',
        routes: [
          GoRoute(path: '/tasks', builder: (_, __) => page('tasks')),
          GoRoute(path: '/dashboard', builder: (_, __) => page('dashboard')),
          GoRoute(
            path: '/deals',
            builder: (_, __) => page('deals'),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) => page('deal ${s.pathParameters['id']}'),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      return router;
    }

    Future<void> host(WidgetTester tester, GoRouter router) async {
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('a tab is switched to, anything else goes on top',
        (tester) async {
      final r = router();
      await host(tester, r);

      final toDeal = openPushRoute(r, '/deals/7');
      await tester.pumpAndSettle();
      await toDeal;
      await tester.pumpAndSettle();
      expect(find.text('deal 7'), findsOneWidget);
      expect(r.canPop(), isTrue);

      final toTab = openPushRoute(r, '/dashboard');
      await tester.pumpAndSettle();
      await toTab;
      await tester.pumpAndSettle();
      expect(find.text('dashboard'), findsOneWidget);
      expect(r.canPop(), isFalse);
    });

    testWidgets('the banner shows the push and opens it on Open',
        (tester) async {
      await host(tester, router());
      var opened = 0;

      showPushBanner(
        const PushMessage(title: 'Deal moved', body: 'Dostyk flat is won'),
        onOpen: () => opened++,
      );
      await tester.pumpAndSettle();

      expect(find.text('Deal moved'), findsOneWidget);
      expect(find.text('Dostyk flat is won'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('push-banner-open')));
      expect(opened, 1);
    });

    testWidgets('a banner with nowhere to go has no Open', (tester) async {
      await host(tester, router());

      showPushBanner(const PushMessage(title: 'Maintenance tonight'));
      await tester.pump();

      expect(find.text('Maintenance tonight'), findsOneWidget);
      expect(find.byKey(const ValueKey('push-banner-open')), findsNothing);
    });
  });
}
