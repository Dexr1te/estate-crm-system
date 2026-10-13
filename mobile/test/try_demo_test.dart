import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/widgets/demo_banner.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _demoUser = AuthResponse(
  userId: 41,
  fullName: 'Demo Agent',
  email: 'demo-0123456789abcdef01234567@demo.estatecrm.app',
  role: Role.AGENT,
  teamId: 7,
  teamName: '[Demo] Agency',
);

DioException _status(int code) => DioException(
      requestOptions: RequestOptions(path: '/auth/demo', method: 'POST'),
      response: Response(
        requestOptions: RequestOptions(path: '/auth/demo', method: 'POST'),
        statusCode: code,
        data: {'code': 'DEMO', 'message': 'Server says no'},
      ),
    );

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

Future<AuthBloc> _pumpLogin(
    WidgetTester tester, FakeAuthRepository repo) async {
  final bloc = AuthBloc(repo);
  addTearDown(bloc.close);
  await tester.pumpWidget(_app(BlocProvider.value(
    value: bloc,
    child: const LoginScreen(),
  )));
  return bloc;
}

Future<void> _tapDemo(WidgetTester tester) async {
  final button = find.byKey(const Key('login-try-demo'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  await tester.pump();
}

Widget _dashboardUnderBanner() => MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => AuthBloc(FakeAuthRepository(user: _demoUser))
              ..add(AuthCheckEvent())),
        BlocProvider(
          create: (_) => DashboardBloc(
            FakeDashboardRepository(const DashboardSummary(
              totalDeals: 5,
              activeDeals: 3,
              closedDeals: 2,
              totalClients: 6,
              upcomingMeetings: 2,
              commissionThisMonth: 265000,
            )),
            FakeMeetingsRepository(const []),
            FakeDealsRepository(const []),
          ),
        ),
      ],
      child: DemoBanner(
        email: _demoUser.email,
        onCreateAccount: () {},
        child: const DashboardScreen(),
      ),
    );

void main() {
  group('login', () {
    testWidgets('offers the demo below sign-in, as a calm 44pt+ button',
        (tester) async {
      await _pumpLogin(tester, FakeAuthRepository());

      final button = find.byKey(const Key('login-try-demo'));
      expect(button, findsOneWidget);
      expect(find.text('Try the demo'), findsOneWidget);
      expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
      expect(
        tester.getTopLeft(button).dy,
        greaterThan(tester.getBottomLeft(find.text('Sign in')).dy),
      );
    });

    testWidgets('a demo signs straight in', (tester) async {
      final repo = FakeAuthRepository(user: null)..demo = _demoUser;
      final bloc = await _pumpLogin(tester, repo);

      await _tapDemo(tester);

      expect(repo.demosStarted, 1);
      expect(bloc.state, isA<AuthAuthenticated>());
      expect(bloc.currentUser?.email, _demoUser.email);
    });

    for (final code in [404, 429]) {
      testWidgets('a $code says the demo is unavailable', (tester) async {
        final repo = FakeAuthRepository()..demoFailure = _status(code);
        final bloc = await _pumpLogin(tester, repo);

        await _tapDemo(tester);

        expect(bloc.state, isA<AuthDemoFailed>());
        expect(
            find.text("The demo isn't available right now. Try again later."),
            findsOneWidget);
        expect(find.text('Server says no'), findsNothing);
        expect(bloc.isAuthenticated, isFalse);
      });
    }

    testWidgets('any other failure says what went wrong', (tester) async {
      final repo = FakeAuthRepository()
        ..demoFailure = DioException(
          requestOptions: RequestOptions(path: '/auth/demo', method: 'GET'),
          type: DioExceptionType.connectionError,
        );
      await _pumpLogin(tester, repo);

      await _tapDemo(tester);

      expect(find.text("The demo isn't available right now. Try again later."),
          findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('bloc', () {
    test('starting a demo shows its own progress, then the session', () async {
      final repo = FakeAuthRepository(user: null)..demo = _demoUser;
      final bloc = AuthBloc(repo);
      addTearDown(bloc.close);

      bloc.add(AuthStartDemoEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthDemoStarting>(), isA<AuthAuthenticated>()]),
      );
    });

    test('a server error is not mistaken for the demo being switched off',
        () async {
      final repo = FakeAuthRepository()..demoFailure = _status(500);
      final bloc = AuthBloc(repo);
      addTearDown(bloc.close);

      bloc.add(AuthStartDemoEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthDemoStarting>(),
          isA<AuthDemoFailed>()
              .having((s) => s.unavailable, 'unavailable', false),
        ]),
      );
    });
  });

  group('banner', () {
    test('only a demo address counts as a demo', () {
      expect(isDemoEmail(_demoUser.email), isTrue);
      expect(isDemoEmail('Demo-ab12@Demo.EstateCRM.app '), isTrue);
      expect(isDemoEmail('reviewer@demo.estatecrm.app'), isFalse);
      expect(isDemoEmail('agent@almaty.kz'), isFalse);
      expect(isDemoEmail('demo.estatecrm.app@gmail.com'), isFalse);
      expect(isDemoEmail(null), isFalse);
    });

    testWidgets('shows for a demo account and offers a real one',
        (tester) async {
      var created = 0;
      await tester.pumpWidget(_app(DemoBanner(
        email: _demoUser.email,
        onCreateAccount: () => created++,
        child: const Scaffold(body: SafeArea(child: Text('dashboard'))),
      )));

      expect(find.byKey(const Key('demo-banner')), findsOneWidget);
      expect(find.text('This is a demo agency. It is wiped within a day.'),
          findsOneWidget);
      expect(find.text('dashboard'), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const Key('demo-banner-create-account')))
            .height,
        greaterThanOrEqualTo(44),
      );

      await tester.tap(find.text('Create an account'));
      expect(created, 1);
    });

    testWidgets('stays away from everyone else', (tester) async {
      for (final email in ['agent@almaty.kz', null]) {
        await tester.pumpWidget(_app(DemoBanner(
          email: email,
          onCreateAccount: () {},
          child: const Scaffold(body: Text('dashboard')),
        )));
        expect(find.byKey(const Key('demo-banner')), findsNothing);
        expect(find.text('dashboard'), findsOneWidget);
      }
    });

    testWidgets('the screen under it keeps its state as it comes and goes',
        (tester) async {
      final email = ValueNotifier<String?>(null);
      await tester.pumpWidget(_app(ValueListenableBuilder<String?>(
        valueListenable: email,
        builder: (_, value, child) => DemoBanner(
          email: value,
          onCreateAccount: () {},
          child: child!,
        ),
        child: const Scaffold(body: TextField()),
      )));
      await tester.enterText(find.byType(TextField), 'half-typed note');

      email.value = _demoUser.email;
      await tester.pump();
      expect(find.byKey(const Key('demo-banner')), findsOneWidget);
      expect(find.text('half-typed note'), findsOneWidget);

      email.value = null;
      await tester.pump();
      expect(find.text('half-typed note'), findsOneWidget);
    });
  });

  group('dashboard under the banner', () {
    setUp(() {
      AppClock.freeze(DateTime(2026, 3, 12, 9, 0));
      addTearDown(AppClock.reset);
    });

    forEachAcceptanceCase('demo dashboard',
        (tester, size, brightness, scale) async {
      await expectNoOverflow(
        tester,
        _dashboardUnderBanner(),
        size: size,
        brightness: brightness,
        textScale: scale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final banner = find.byKey(const Key('demo-banner'));
      expect(banner, findsOneWidget);
      expect(
        tester.getBottomLeft(banner).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(DashboardScreen)).dy),
        reason: 'the banner sits above the screen, never over it',
      );
    });

    for (final locale in kAcceptanceLocales) {
      for (final (size, scale) in const [
        (Size(390, 844), 1.0),
        (Size(320, 568), 1.5),
      ]) {
        testWidgets(
            'demo dashboard renders in ${locale.languageCode} at '
            '${size.width.toInt()} ${scale}x', (tester) async {
          await expectNoOverflow(
            tester,
            _dashboardUnderBanner(),
            size: size,
            brightness: Brightness.light,
            textScale: scale,
            locale: locale,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('banner in every language', () {
    for (final locale in kAcceptanceLocales) {
      forEachAcceptanceCase('demo banner ${locale.languageCode}',
          (tester, size, brightness, scale) async {
        await expectNoOverflow(
          tester,
          DemoBanner(
            email: _demoUser.email,
            onCreateAccount: () {},
            child: const Scaffold(body: SafeArea(child: Text('dashboard'))),
          ),
          size: size,
          brightness: brightness,
          textScale: scale,
          locale: locale,
        );
        expect(find.byKey(const Key('demo-banner')), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const Key('demo-banner'))).height,
          lessThan(size.height / 4),
          reason: 'a slim strip, not a wall over the screen',
        );
      });
    }
  });
}
