import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/auth_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/domain/email_verifier.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

import 'fakes.dart';

const _confirmed = AuthResponse(
    userId: 9,
    fullName: 'Aigerim',
    email: 'aigerim@almaty.kz',
    role: Role.MANAGER);

const _ticket = VerificationTicket(
    email: 'aigerim@almaty.kz', firebaseToken: 'custom-token');

class _UnverifiedAuthRepository extends FakeAuthRepository {
  _UnverifiedAuthRepository() : super(user: _confirmed);

  @override
  Future<AuthResponse> login(String email, String password) async =>
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 403,
          data: const {
            'code': 'EMAIL_NOT_VERIFIED',
            'message': 'Confirm your email first.',
          },
        ),
      );
}

AuthRegisterEvent _signUp() => AuthRegisterEvent(
      fullName: 'Aigerim',
      email: 'aigerim@almaty.kz',
      password: 'long enough',
      role: Role.MANAGER,
    );

void main() {
  group('signing up', () {
    test('emails the link and waits, rather than signing in', () async {
      final repo =
          FakeAuthRepository(user: _confirmed, registerResult: _ticket);
      final verifier = FakeEmailVerifier();
      final bloc = AuthBloc(repo, verifier: verifier);
      addTearDown(bloc.close);

      bloc.add(_signUp());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthVerificationRequired>()
              .having((s) => s.email, 'email', 'aigerim@almaty.kz'),
        ]),
      );
      expect(repo.registered?.$4, Role.MANAGER);
      expect(verifier.sentWith, ['custom-token']);
      expect(bloc.isAuthenticated, isFalse,
          reason: 'an unconfirmed account must not hold a session');
    });

    test('signs straight in when the server does not ask for confirmation',
        () async {
      final verifier = FakeEmailVerifier();
      final bloc =
          AuthBloc(FakeAuthRepository(user: _confirmed), verifier: verifier);
      addTearDown(bloc.close);
      var routerTold = 0;
      bloc.addListener(() => routerTold++);

      bloc.add(_signUp());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthAuthenticated>()]),
      );
      expect(bloc.isAuthenticated, isTrue);
      expect(verifier.sentWith, isEmpty);
      expect(routerTold, 1,
          reason: 'the sign-up form does not navigate; the redirect does');
    });

    test('a link that could not go out still leaves the app waiting for one',
        () async {
      final bloc = AuthBloc(
          FakeAuthRepository(user: _confirmed, registerResult: _ticket),
          verifier: FakeEmailVerifier(
              failure: const EmailVerificationException(
                  EmailVerificationProblem.tooManyRequests)));
      addTearDown(bloc.close);

      bloc.add(_signUp());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthLinkFailed>().having((s) => s.problem, 'problem',
              EmailVerificationProblem.tooManyRequests),
        ]),
      );
    });

    test('signing in unconfirmed sends a fresh link instead of failing',
        () async {
      final repo = _UnverifiedAuthRepository();
      final verifier = FakeEmailVerifier();
      final bloc = AuthBloc(repo, verifier: verifier);
      addTearDown(bloc.close);

      bloc.add(AuthLoginEvent('aigerim@almaty.kz', 'long enough'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthVerificationRequired>()
              .having((s) => s.email, 'email', 'aigerim@almaty.kz'),
        ]),
      );
      expect(repo.verificationStartedFor, ('aigerim@almaty.kz', 'long enough'));
      expect(verifier.sentWith, ['fresh-token'],
          reason: 'the link goes out with the token the server just issued');
      expect(bloc.isAuthenticated, isFalse);
    });
  });

  group('confirming the email', () {
    test('checking before the link is opened starts no session', () async {
      final repo = FakeAuthRepository(user: _confirmed);
      final bloc = AuthBloc(repo, verifier: FakeEmailVerifier());
      addTearDown(bloc.close);

      bloc.add(AuthConfirmEmailEvent('aigerim@almaty.kz'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthVerificationChecking>(),
          isA<AuthEmailNotConfirmed>(),
        ]),
      );
      expect(repo.verifiedWith, isNull);
      expect(bloc.isAuthenticated, isFalse);
    });

    test('coming back to the app before opening the link says nothing',
        () async {
      final bloc = AuthBloc(FakeAuthRepository(user: _confirmed),
          verifier: FakeEmailVerifier());
      addTearDown(bloc.close);
      final states = <AuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(AuthConfirmEmailEvent('aigerim@almaty.kz', silent: true));
      await Future<void>.delayed(Duration.zero);
      expect(states, isEmpty);
    });

    test('once the link is opened the server starts the session', () async {
      final repo = FakeAuthRepository(user: _confirmed);
      final verifier = FakeEmailVerifier(idToken: 'id-token');
      final bloc = AuthBloc(repo, verifier: verifier);
      addTearDown(bloc.close);
      var routerTold = 0;
      bloc.addListener(() => routerTold++);

      bloc.add(AuthConfirmEmailEvent('aigerim@almaty.kz'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthVerificationChecking>(),
          isA<AuthAuthenticated>(),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      expect(repo.verifiedWith, 'id-token');
      expect(routerTold, 1);
      expect(verifier.signedOut, 1,
          reason: 'the app runs on its own session from here, not Firebase');
    });

    test('asking for the link again sends it', () async {
      final verifier = FakeEmailVerifier();
      final bloc =
          AuthBloc(FakeAuthRepository(user: _confirmed), verifier: verifier);
      addTearDown(bloc.close);

      bloc.add(AuthResendLinkEvent('aigerim@almaty.kz'));
      await expectLater(bloc.stream, emits(isA<AuthLinkResent>()));
      expect(verifier.resent, 1);
    });

    test('too many requests are explained rather than swallowed', () async {
      final bloc = AuthBloc(FakeAuthRepository(user: _confirmed),
          verifier: FakeEmailVerifier(
              failure: const EmailVerificationException(
                  EmailVerificationProblem.tooManyRequests)));
      addTearDown(bloc.close);

      bloc.add(AuthResendLinkEvent('aigerim@almaty.kz'));
      await expectLater(
        bloc.stream,
        emits(isA<AuthLinkFailed>().having((s) => s.problem, 'problem',
            EmailVerificationProblem.tooManyRequests)),
      );
    });
  });

  group('refreshing the session', () {
    test('picks up the team the account has just joined', () async {
      const joined = AuthResponse(
          userId: 9,
          fullName: 'Aigerim',
          email: 'aigerim@almaty.kz',
          role: Role.AGENT,
          teamId: 1,
          teamName: 'Almaty Realty');
      final bloc = AuthBloc(FakeAuthRepository(
          user: _confirmed.copyWith(role: Role.AGENT), refreshed: joined));
      addTearDown(bloc.close);

      bloc.add(AuthCheckEvent());
      await expectLater(bloc.stream, emits(isA<AuthAuthenticated>()));
      expect(bloc.currentUser?.teamId, isNull);

      bloc.add(AuthRefreshMeEvent());
      await expectLater(bloc.stream, emits(isA<AuthAuthenticated>()));
      expect(bloc.currentUser?.teamId, 1);
    });

    test('a refresh that fails leaves the session alone', () async {
      final bloc = AuthBloc(_FailingRefreshRepository());
      addTearDown(bloc.close);

      bloc.add(AuthCheckEvent());
      await expectLater(bloc.stream, emits(isA<AuthAuthenticated>()));

      bloc.add(AuthRefreshMeEvent());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.isAuthenticated, isTrue,
          reason: 'a failed refresh must not read as a lost session');
    });
  });

  group('where an account without a team is sent', () {
    String? go(Role role,
            {bool hasTeam = false, String location = '/clients'}) =>
        resolveRedirect(
          location: location,
          sessionResolved: true,
          authenticated: true,
          role: role,
          hasTeam: hasTeam,
        );

    test('a manager is asked to create one', () {
      expect(go(Role.MANAGER), '/onboarding/team');
    });

    test('an agent waits to be added to one', () {
      expect(go(Role.AGENT), '/onboarding/waiting');
    });

    test('the profile stays reachable, so they can sign out or leave', () {
      expect(go(Role.AGENT, location: '/profile'), isNull);
    });

    test('an admin runs the platform and has no agency to be in', () {
      expect(go(Role.ADMIN), isNull);
    });

    test('once in a team the onboarding screens are behind them', () {
      expect(go(Role.AGENT, hasTeam: true, location: '/onboarding/waiting'),
          '/dashboard');
      expect(go(Role.MANAGER, hasTeam: true), isNull);
    });

    test('the sign-up screens are reachable without a session', () {
      for (final location in [
        '/register',
        '/register/details',
        '/verify-email'
      ]) {
        expect(
          resolveRedirect(
              location: location,
              sessionResolved: true,
              authenticated: false,
              role: null,
              hasTeam: false),
          isNull,
          reason: 'somebody signing up has no session by definition',
        );
      }
    });
  });
}

/// Answers a refresh with a failure, the way a flaky connection would.
class _FailingRefreshRepository extends FakeAuthRepository {
  _FailingRefreshRepository() : super(user: _confirmed);

  @override
  Future<AuthResponse> refreshMe() async => throw DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        type: DioExceptionType.connectionError,
      );
}
