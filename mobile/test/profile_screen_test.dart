import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/locale/bloc/locale_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/notifications/reminders_bloc.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/profile/presentation/screens/profile_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _user = AuthResponse(
  userId: 5,
  fullName: 'Sultan Assan-Doroshenko',
  email: 'asansultan25@gmail.com',
  role: Role.ADMIN,
);

/// An agent in a team — the only role that can walk out of one.
const _agentInTeam = AuthResponse(
  userId: 6,
  fullName: 'Aigerim Serikbaykyzy',
  email: 'aigerim@almaty.kz',
  role: Role.AGENT,
  teamId: 1,
  teamName: 'Almaty Realty',
);

FakeAuthRepository _authRepo = FakeAuthRepository(user: _user);

const _colleagues = [
  AgentOption(id: 5, fullName: 'Sultan Assan-Doroshenko', email: 'me@x.kz'),
  AgentOption(id: 9, fullName: 'Нурлан Беков', email: 'nurlan@estatecrm.kz'),
];

Widget _profile(
    {AuthResponse user = _user, List<AgentOption> colleagues = _colleagues}) {
  _authRepo = FakeAuthRepository(user: user);
  Injector.authRepository = _authRepo;
  Injector.agentsRepository = FakeAgentsRepository(colleagues);
  final auth = AuthBloc(_authRepo)..add(AuthCheckEvent());
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: auth),
      BlocProvider(create: (_) => ThemeBloc()),
      BlocProvider(create: (_) => LocaleBloc()),
      BlocProvider(create: (_) => RemindersBloc(FakeNotificationGateway())),
    ],
    child: const ProfileScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  forEachAcceptanceCase('profile', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('profile renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        _profile(),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.5,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  // App Store Review Guideline 5.1.1(v): an app holding an account has to let
  // the person holding it close it from inside the app.
  testWidgets('an account can be closed from the profile screen',
      (tester) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });

  testWidgets('closing an account hands the records to someone else first',
      (tester) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    // The action sits at the bottom of a scrolling settings page.
    await tester.scrollUntilVisible(find.text('Delete account'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    // The successor sheet comes first, and never offers you yourself.
    expect(find.text('Hand your records over to'), findsOneWidget);
    // Match on the addresses: the profile behind the sheet shows the signed-in
    // name twice already, so the name alone cannot tell the two apart.
    expect(find.text('nurlan@estatecrm.kz'), findsOneWidget);
    expect(find.text('me@x.kz'), findsNothing,
        reason: 'you cannot hand your own records to yourself');

    await tester.tap(find.text('Нурлан Беков'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Нурлан Беков'), findsWidgets,
        reason: 'the confirmation names who takes the records over');

    await tester.tap(find.widgetWithText(AppGhostButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(_authRepo.deletedWithReplacement, isNull,
        reason: 'backing out of the dialog must not delete anything');
  });

  // A reviewer signs up, then deletes the account they just made. Alone in
  // the agency they created there is nobody to pick, and an empty picker used
  // to be a dead end.
  group('closing an account with nobody to hand records to', () {
    Future<void> openDelete(WidgetTester tester) async {
      await expectNoOverflow(
        tester,
        _profile(colleagues: const [
          AgentOption(
              id: 5, fullName: 'Sultan Assan-Doroshenko', email: 'me@x.kz'),
        ]),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Delete account'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
    }

    testWidgets('goes straight to the confirmation and deletes',
        (tester) async {
      await openDelete(tester);

      expect(find.text('Hand your records over to'), findsNothing);
      expect(find.text('No one else to hand them to'), findsNothing);
      expect(
          find.text('Your account will be removed permanently. '
              'This cannot be undone.'),
          findsOneWidget);

      await tester.tap(find
          .widgetWithText(AppFilledButton, 'Delete account')
          .hitTestable()
          .last);
      await tester.pumpAndSettle();

      expect(_authRepo.deletes, 1);
      expect(_authRepo.deletedWithReplacement, isNull,
          reason: 'nobody was named to take the records over');
    });

    testWidgets('says why when the server still finds records to hand over',
        (tester) async {
      await openDelete(tester);
      _authRepo.deleteFailure = DioException(
        requestOptions: RequestOptions(path: '/auth/me', method: 'DELETE'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me', method: 'DELETE'),
          statusCode: 400,
          data: {'message': 'Sultan still holds 2 deal(s)'},
        ),
      );

      await tester.tap(find
          .widgetWithText(AppFilledButton, 'Delete account')
          .hitTestable()
          .last);
      await tester.pumpAndSettle();

      expect(find.textContaining('there is nobody else in your agency'),
          findsOneWidget);
      expect(find.text('Delete account'), findsWidgets,
          reason: 'the account is still there, and so is the button');
    });
  });

  testWidgets('appearance offers following the system, not just a dark switch',
      (tester) async {
    await expectNoOverflow(tester, _profile(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Follow system'));
    await tester.pumpAndSettle();

    expect(find.text('Follow system'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('you can correct your own name without asking an admin',
      (tester) async {
    await expectNoOverflow(tester, _profile(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sultan Assan-Doroshenko').last);
    await tester.pumpAndSettle();

    expect(find.text('Edit profile'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Sultan Assan-Doroshenko'),
        'Sultan Assan');
    await tester.tap(find.widgetWithText(AppFilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(_authRepo.updatedProfile?.$1, 'Sultan Assan');
    expect(_authRepo.updatedProfile?.$2, 'asansultan25@gmail.com',
        reason: 'the address is sent unchanged, not dropped');
  });

  testWidgets('meeting reminders can be turned on and given a lead time',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await expectNoOverflow(tester, _profile(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    // Off by default: a CRM that starts sending notifications before being
    // asked is one people turn off entirely.
    expect(find.text('Off'), findsOneWidget);

    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();

    expect(find.text('15 minutes before'), findsOneWidget);
    expect(find.text('1 hour before'), findsOneWidget);
    expect(find.text('1 day before'), findsOneWidget);

    await tester.tap(find.text('1 hour before'));
    await tester.pumpAndSettle();

    expect(find.text('1 hour before'), findsOneWidget,
        reason: 'the row now reports the chosen lead instead of Off');
  });

  testWidgets('the role renders localised, never as a raw enum value',
      (tester) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: const Locale('ru'),
    );
    await tester.pumpAndSettle();

    expect(find.text('АДМИН'), findsOneWidget);
    expect(find.text('ADMIN'), findsNothing);
  });

  test('the legal links keep the API prefix the backend is mounted under', () {
    // The backend runs under a servlet context path. A link built from the bare
    // origin — which is what these used to be — reaches Tomcat outside that
    // context and comes back 404, so the privacy policy App Store Connect wants
    // to resolve, and the support page a reviewer taps, were both dead.
    for (final path in ['/privacy', '/support']) {
      final url = backendPageUrl(path);
      expect(url.toString(), startsWith(apiBaseUrl),
          reason: '$path must hang off the API base, not its origin');
      expect(url.path, endsWith(path));
      expect(Uri.parse(apiBaseUrl).path, isNotEmpty,
          reason:
              'if the base ever loses its path this test stops proving anything');
      expect(url.path, contains(Uri.parse(apiBaseUrl).path));
    }
  });

  group('the console a role runs, reached from the profile', () {
    Future<void> pump(WidgetTester tester, AuthResponse user) async {
      Injector.teamsRepository = FakeTeamsRepository();
      await expectNoOverflow(tester, _profile(user: user),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
    }

    final hub = find.byKey(const ValueKey('profile-hub'));

    testWidgets('a manager finds their team at the top', (tester) async {
      await pump(
          tester,
          _agentInTeam.copyWith(
              userId: 7, role: Role.MANAGER, fullName: 'Asel'));
      expect(hub, findsOneWidget);
      expect(find.descendant(of: hub, matching: find.text('Team')),
          findsOneWidget);
      expect(
          tester.getTopLeft(hub).dy,
          lessThan(tester
              .getTopLeft(find.byKey(const ValueKey('profile-time-off')))
              .dy));
    });

    testWidgets('the row opens the console', (tester) async {
      Injector.teamsRepository = FakeTeamsRepository();
      final manager = _agentInTeam.copyWith(userId: 7, role: Role.MANAGER);
      final router = GoRouter(initialLocation: '/profile', routes: [
        GoRoute(path: '/profile', builder: (_, __) => _profile(user: manager)),
        GoRoute(
            path: '/team-console', builder: (_, __) => const Text('console')),
      ]);
      addTearDown(router.dispose);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));
      await tester.pumpAndSettle();

      await tester.tap(hub);
      await tester.pumpAndSettle();
      expect(find.text('console'), findsOneWidget);
    });

    testWidgets('an admin finds the admin console', (tester) async {
      await pump(tester, _user);
      expect(find.descendant(of: hub, matching: find.text('Admin')),
          findsOneWidget);
    });

    testWidgets('an agent has no console to go to', (tester) async {
      await pump(tester, _agentInTeam);
      expect(hub, findsNothing);
    });

    testWidgets('a manager still forming a team has none yet', (tester) async {
      await pump(tester,
          const AuthResponse(userId: 7, fullName: 'Asel', role: Role.MANAGER));
      expect(hub, findsNothing);
    });
  });

  group('the team someone belongs to', () {
    testWidgets('is named, and an agent can leave it', (tester) async {
      final teams = FakeTeamsRepository();
      Injector.teamsRepository = teams;

      await expectNoOverflow(tester, _profile(user: _agentInTeam),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();

      expect(find.text('Almaty Realty'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Leave team'), 200);
      await tester.tap(find.text('Leave team'));
      await tester.pumpAndSettle();

      // Leaving hands the clients over, so it is confirmed before it happens.
      expect(teams.leftTeam, isFalse);
      await tester.tap(find.widgetWithText(InkWell, 'Leave team').last);
      await tester.pumpAndSettle();

      expect(teams.leftTeam, isTrue);
    });

    testWidgets(
        'an agent reads what they are owed here; a manager, on the console',
        (tester) async {
      Injector.teamsRepository = FakeTeamsRepository();
      await expectNoOverflow(tester, _profile(user: _agentInTeam),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('profile-payouts')), findsOneWidget);
      expect(find.text('Payouts'), findsOneWidget);

      await expectNoOverflow(
          tester,
          _profile(
              user: _agentInTeam.copyWith(
                  userId: 7, role: Role.MANAGER, fullName: 'Asel')),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('profile-payouts')), findsNothing);
    });

    testWidgets('an agent is not offered the agency currency', (tester) async {
      Injector.teamsRepository = FakeTeamsRepository();
      await expectNoOverflow(tester, _profile(user: _agentInTeam),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();

      // Only the manager's team screen carries it; the server refuses the
      // change from anyone else as well.
      expect(find.text('Agency currency'), findsNothing);
      expect(find.byKey(const Key('currency-row')), findsNothing);
    });

    testWidgets('an admin belongs to none, and has nothing to leave',
        (tester) async {
      Injector.teamsRepository = FakeTeamsRepository();

      await expectNoOverflow(tester, _profile(),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();

      expect(find.text('No team'), findsOneWidget);
      expect(find.text('Leave team'), findsNothing);
    });
  });
}
