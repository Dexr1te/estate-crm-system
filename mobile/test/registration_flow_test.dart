import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';

import 'fakes.dart';

const _confirmed = AuthResponse(
    userId: 9,
    fullName: 'Aigerim',
    email: 'aigerim@almaty.kz',
    role: Role.MANAGER);

/// Refuses to sign in the way the backend does for an unconfirmed account:
/// 403 with a code the app is expected to act on rather than display.
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

void main() {
  group('signing up', () {
    test('leaves the app waiting for the code rather than signed in', () async {
      final repo = FakeAuthRepository(user: _confirmed);
      final bloc = AuthBloc(repo);
      addTearDown(bloc.close);

      bloc.add(AuthRegisterEvent(
        fullName: 'Aigerim',
        email: 'aigerim@almaty.kz',
        password: 'long enough',
        role: Role.MANAGER,
      ));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthVerificationRequired>().having(
              (s) => s.email, 'email', 'aigerim@almaty.kz'),
        ]),
      );
      expect(repo.registered?.$4, Role.MANAGER);
      expect(bloc.isAuthenticated, isFalse,
          reason: 'an unconfirmed account must not hold a session');
    });

    test('the code is what starts the session', () async {
      final repo = FakeAuthRepository(user: _confirmed);
      final bloc = AuthBloc(repo);
      addTearDown(bloc.close);

      bloc.add(AuthVerifyEmailEvent('aigerim@almaty.kz', '123456'));
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthAuthenticated>()]),
      );
      expect(repo.verifiedWith, ('aigerim@almaty.kz', '123456'));
    });

    test('asking for another code leaves the screen where it is', () async {
      final repo = FakeAuthRepository(user: _confirmed);
      final bloc = AuthBloc(repo);
      addTearDown(bloc.close);

      bloc.add(AuthResendCodeEvent('aigerim@almaty.kz'));
      await expectLater(bloc.stream, emits(isA<AuthCodeResent>()));
      expect(repo.resentFor, 'aigerim@almaty.kz');
    });

    test('signing in unconfirmed asks for the code instead of failing',
        () async {
      final bloc = AuthBloc(_UnverifiedAuthRepository());
      addTearDown(bloc.close);

      bloc.add(AuthLoginEvent('aigerim@almaty.kz', 'long enough'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthVerificationRequired>().having(
              (s) => s.email, 'email', 'aigerim@almaty.kz'),
        ]),
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
    String? go(Role role, {bool hasTeam = false, String location = '/clients'}) =>
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

    test('the profile stays reachable, so they can sign out or leave',
        () {
      expect(go(Role.AGENT, location: '/profile'), isNull);
    });

    test('an admin runs the platform and has no agency to be in', () {
      expect(go(Role.ADMIN), isNull);
    });

    test('once in a team the onboarding screens are behind them', () {
      expect(
          go(Role.AGENT, hasTeam: true, location: '/onboarding/waiting'),
          '/dashboard');
      expect(go(Role.MANAGER, hasTeam: true), isNull);
    });

    test('the sign-up screens are reachable without a session', () {
      for (final location in ['/register', '/register/details', '/verify-email']) {
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
