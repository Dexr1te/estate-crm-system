import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/shortcuts/app_shortcuts.dart';
import 'package:real_estate_crm/core/shortcuts/open_shortcut.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

const _agent =
    AuthResponse(userId: 5, fullName: 'Maria Kim', role: Role.AGENT, teamId: 1);
const _teamless =
    AuthResponse(userId: 8, fullName: 'New Agent', role: Role.AGENT);

/// Reads the saved session only when told to, so a test can hold the app on
/// the splash the way a slow phone does. With [signedIn] false nothing is
/// saved, but signing in still works.
class _GatedAuthRepository extends FakeAuthRepository {
  _GatedAuthRepository(AuthResponse user, {this.signedIn = true})
      : super(user: user);
  final bool signedIn;
  final _gate = Completer<void>();

  void release() => _gate.complete();

  @override
  Future<AuthResponse?> getSavedUser() async {
    await _gate.future;
    return signedIn ? user : null;
  }

  @override
  bool get isLoggedIn => signedIn;
}

class _App {
  _App(this.auth, this.router, this.shortcuts, this.actions);
  final AuthBloc auth;
  final GoRouter router;
  final ShortcutHandler shortcuts;
  final FakeQuickActions actions;

  String get location => currentLocationOf(router).path;
}

Future<_App> _start(
  WidgetTester tester,
  _GatedAuthRepository repo, {
  String? launchedWith,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final actions = FakeQuickActions(launchedWith: launchedWith);
  Injector.quickActions = actions;
  addTearDown(() => Injector.quickActions = const QuickActions());

  final auth = AuthBloc(repo)..add(AuthCheckEvent());
  addTearDown(auth.close);

  Widget page(String name) => Scaffold(body: Center(child: Text(name)));
  GoRoute stub(String path) =>
      GoRoute(path: path, builder: (_, __) => page('page $path'));

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: auth,
    redirect: (_, s) => resolveRedirect(
      location: s.matchedLocation,
      sessionResolved: auth.isSessionResolved,
      authenticated: auth.isAuthenticated,
      role: auth.currentUser?.role,
      hasTeam: auth.currentUser?.teamId != null,
    ),
    routes: [
      for (final p in [
        '/splash',
        '/login',
        '/onboarding/waiting',
        '/search',
        '/clients/new',
        '/meetings/new',
      ])
        stub(p),
      stub('/dashboard'),
    ],
  );
  addTearDown(router.dispose);

  final shortcuts = ShortcutHandler(
    actions: Injector.quickActions,
    auth: auth,
    open: (s) => unawaited(openAppShortcut(router, s)),
  );
  addTearDown(shortcuts.dispose);
  await shortcuts.start();

  await tester.pumpWidget(_host(auth, router, shortcuts, locale));
  await tester.pumpAndSettle();
  return _App(auth, router, shortcuts, actions);
}

void main() {
  setUp(() {
    Injector.tasksRepository = FakeTasksRepository();
    Injector.clientsRepository = FakeClientsRepository();
  });

  test('every shortcut type reads back, and nothing else does', () {
    for (final s in AppShortcut.values) {
      expect(AppShortcut.parse(s.type), s);
    }
    expect(AppShortcut.parse('new_listing'), isNull);
    expect(AppShortcut.parse(null), isNull);
  });

  group('cold start', () {
    testWidgets('signed in: waits on the splash, then opens the form',
        (tester) async {
      final repo = _GatedAuthRepository(_agent);
      final app = await _start(tester, repo, launchedWith: 'new_client');
      expect(app.location, '/splash');
      expect(find.text('page /clients/new'), findsNothing);

      repo.release();
      await tester.pumpAndSettle();
      expect(app.location, '/clients/new');
      expect(find.text('page /clients/new'), findsOneWidget);

      app.router.pop();
      await tester.pumpAndSettle();
      expect(app.location, '/dashboard',
          reason: 'backing out of the form lands on home');
    });

    testWidgets('signed out: login, and the shortcut is dropped',
        (tester) async {
      final repo = _GatedAuthRepository(_agent, signedIn: false);
      final app = await _start(tester, repo, launchedWith: 'new_meeting');
      repo.release();
      await tester.pumpAndSettle();
      expect(app.location, '/login');

      app.auth.add(AuthLoginEvent('m@estate.crm', 'secret'));
      await tester.pumpAndSettle();
      expect(app.location, '/dashboard',
          reason: 'signing in later must not replay a stale shortcut');
    });

    testWidgets('no team yet: onboarding, and the shortcut is dropped',
        (tester) async {
      final repo = _GatedAuthRepository(_teamless);
      final app = await _start(tester, repo, launchedWith: 'new_client');
      repo.release();
      await tester.pumpAndSettle();
      expect(app.location, '/onboarding/waiting');
    });
  });

  group('warm start', () {
    Future<_App> signedIn(WidgetTester tester) async {
      final repo = _GatedAuthRepository(_agent)..release();
      final app = await _start(tester, repo);
      expect(app.location, '/dashboard');
      return app;
    }

    testWidgets('new meeting opens the meeting form', (tester) async {
      final app = await signedIn(tester);
      app.actions.tap('new_meeting');
      await tester.pumpAndSettle();
      expect(app.location, '/meetings/new');
    });

    testWidgets('search opens search over home', (tester) async {
      final app = await signedIn(tester);
      app.actions.tap('search');
      await tester.pumpAndSettle();
      expect(app.location, '/search');
      app.router.pop();
      await tester.pumpAndSettle();
      expect(app.location, '/dashboard');
    });

    testWidgets('new task opens the task sheet over home', (tester) async {
      final app = await signedIn(tester);
      app.actions.tap('new_task');
      await tester.pumpAndSettle();
      expect(app.location, '/dashboard');
      expect(find.text('New task'), findsOneWidget);
    });

    testWidgets('an unknown shortcut does nothing', (tester) async {
      final app = await signedIn(tester);
      app.actions.tap('launch_rockets');
      await tester.pumpAndSettle();
      expect(app.location, '/dashboard');
    });
  });

  group('titles on the icon', () {
    List<String> titles(List<ShortcutItem> items) =>
        [for (final i in items) i.localizedTitle];

    testWidgets('are set in the app language and follow it when it changes',
        (tester) async {
      final repo = _GatedAuthRepository(_agent)..release();
      final app = await _start(tester, repo);
      expect(app.actions.sets, hasLength(1));
      expect(titles(app.actions.sets.last),
          ['New client', 'New task', 'New meeting', 'Search']);
      expect([for (final i in app.actions.sets.last) i.type],
          ['new_client', 'new_task', 'new_meeting', 'search']);

      await tester.pumpWidget(
          _host(app.auth, app.router, app.shortcuts, const Locale('ru')));
      await tester.pumpAndSettle();
      expect(titles(app.actions.sets.last),
          ['Новый клиент', 'Новая задача', 'Новая встреча', 'Поиск']);

      await tester.pumpWidget(
          _host(app.auth, app.router, app.shortcuts, const Locale('kk')));
      await tester.pumpAndSettle();
      expect(titles(app.actions.sets.last),
          ['Жаңа клиент', 'Жаңа тапсырма', 'Жаңа кездесу', 'Іздеу']);

      final sent = app.actions.sets.length;
      await tester.pumpWidget(
          _host(app.auth, app.router, app.shortcuts, const Locale('kk')));
      await tester.pumpAndSettle();
      expect(app.actions.sets, hasLength(sent),
          reason: 'the same language is not sent to the platform again');
    });
  });
}

Widget _host(AuthBloc auth, GoRouter router, ShortcutHandler shortcuts,
        Locale locale) =>
    BlocProvider.value(
      value: auth,
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (_, child) =>
            ShortcutTitles(handler: shortcuts, child: child!),
      ),
    );
