import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/goal/goal_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/deep_links.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/accept_invite_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:real_estate_crm/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

const _signedIn = AuthResponse(
    userId: 7,
    fullName: 'Sultan',
    email: 'sultan@estate.crm',
    role: Role.AGENT);

/// Holds the saved-session read open so a link can arrive mid-splash, which is
/// exactly what a cold start from an invite email does.
class _SlowAuthRepository extends FakeAuthRepository {
  final _gate = Completer<AuthResponse?>();

  /// Lands the read on "nobody is signed in" — the state an invited person is
  /// in when the email brings them here.
  void release() => _gate.complete(null);

  @override
  Future<AuthResponse?> getSavedUser() => _gate.future;
}

void main() {
  group('resolveDeepLink', () {
    test('the custom scheme the landing page offers carries the token over',
        () {
      expect(
        resolveDeepLink(Uri.parse('estatecrm://accept-invite?token=abc-123')),
        '/accept-invite?token=abc-123',
      );
    });

    test('the landing URL itself resolves the same way, for App Links later',
        () {
      expect(
        resolveDeepLink(
            Uri.parse('https://crm.example.com/api/invite?token=abc-123')),
        '/accept-invite?token=abc-123',
      );
    });

    test('a token with URL-unsafe characters survives the round trip', () {
      final location = resolveDeepLink(
          Uri.parse('estatecrm://accept-invite?token=a%2Bb%2Fc'));
      expect(Uri.parse(location!).queryParameters['token'], 'a+b/c');
    });

    test('a link with no token still opens the screen to paste one by hand',
        () {
      expect(resolveDeepLink(Uri.parse('estatecrm://accept-invite')),
          '/accept-invite');
      expect(resolveDeepLink(Uri.parse('estatecrm://accept-invite?token=%20')),
          '/accept-invite');
    });

    test('links this app does not claim are ignored', () {
      expect(resolveDeepLink(Uri.parse('estatecrm://dashboard')), isNull);
      expect(resolveDeepLink(Uri.parse('https://crm.example.com/')), isNull);
      expect(resolveDeepLink(Uri.parse('https://crm.example.com/pricing')),
          isNull);
    });
  });

  group('DeepLinkHandler', () {
    late StreamController<Uri> links;

    setUp(() => links = StreamController<Uri>.broadcast());
    tearDown(() => links.close());

    /// The dashboard is a live destination here — a signed-in session starts
    /// there — so it gets the blocs it reads, not just [AuthBloc].
    Future<AuthBloc> pumpApp(
      WidgetTester tester,
      AuthBloc auth, {
      Future<bool> Function()? confirmSignOut,
    }) async {
      final router = createRouter(auth);
      final handler = DeepLinkHandler(
        router: router,
        auth: auth,
        links: links.stream,
        confirmSignOut: confirmSignOut,
      )..start();
      addTearDown(handler.dispose);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider.value(value: auth),
          BlocProvider(create: (_) => GoalBloc()..add(GoalChangedEvent(null))),
          BlocProvider(
            create: (_) => DashboardBloc(
              FakeDashboardRepository(const DashboardSummary()),
              FakeMeetingsRepository(const []),
              FakeDealsRepository(const []),
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ));
      return auth;
    }

    testWidgets(
        'a link that arrives mid-splash is replayed once the session '
        'resolves, instead of being swallowed by the redirect', (tester) async {
      final repo = _SlowAuthRepository();
      final auth = AuthBloc(repo)..add(AuthCheckEvent());
      addTearDown(auth.close);
      await pumpApp(tester, auth);

      links.add(Uri.parse('estatecrm://accept-invite?token=abc-123'));
      await tester.pumpAndSettle();
      expect(find.text('abc-123'), findsNothing,
          reason: 'the splash still owns the screen while the session is read');

      repo.release();
      await tester.pumpAndSettle();

      expect(find.text('abc-123'), findsOneWidget,
          reason: 'the invite code lands in the field, prefilled');
    });

    testWidgets('a link that arrives while signed out navigates straight away',
        (tester) async {
      final auth = AuthBloc(FakeAuthRepository())..add(AuthCheckEvent());
      addTearDown(auth.close);
      await pumpApp(tester, auth);
      await tester.pumpAndSettle();

      links.add(Uri.parse('estatecrm://accept-invite?token=xyz-789'));
      await tester.pumpAndSettle();

      expect(find.text('xyz-789'), findsOneWidget);
    });

    testWidgets(
        'an invite that arrives during a live session is taken up once the '
        'sign-out is confirmed', (tester) async {
      var asked = 0;
      final auth = AuthBloc(FakeAuthRepository(user: _signedIn))
        ..add(AuthCheckEvent());
      addTearDown(auth.close);
      await pumpApp(tester, auth, confirmSignOut: () async {
        asked++;
        return true;
      });
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);

      links.add(Uri.parse('estatecrm://accept-invite?token=xyz-789'));
      await tester.pumpAndSettle();

      expect(asked, 1, reason: 'asked once, not once per router refresh');
      expect(auth.isAuthenticated, isFalse);
      expect(find.text('xyz-789'), findsOneWidget,
          reason: 'the redirect that guards the auth screens no longer '
              'swallows the link, because the session is gone');
    });

    testWidgets('declining keeps the session and drops the link for good',
        (tester) async {
      final auth = AuthBloc(FakeAuthRepository(user: _signedIn))
        ..add(AuthCheckEvent());
      addTearDown(auth.close);
      await pumpApp(tester, auth, confirmSignOut: () async => false);
      await tester.pumpAndSettle();

      links.add(Uri.parse('estatecrm://accept-invite?token=xyz-789'));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isTrue);
      expect(find.byType(DashboardScreen), findsOneWidget);

      // A held link would be replayed by the next sign-out, dropping someone
      // who simply logged out onto an invite they had already turned down.
      auth.add(AuthLogoutEvent());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AcceptInviteScreen), findsNothing);
    });

    testWidgets('an unrelated link leaves the current screen alone',
        (tester) async {
      final auth = AuthBloc(FakeAuthRepository())..add(AuthCheckEvent());
      addTearDown(auth.close);
      await pumpApp(tester, auth);
      await tester.pumpAndSettle();

      links.add(Uri.parse('https://crm.example.com/pricing'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AcceptInviteScreen), findsNothing);
    });
  });
}
