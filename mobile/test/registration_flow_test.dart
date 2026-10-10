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

void main() {
  group('signing up', () {
    test('signs the new account straight in', () async {
      final repo = FakeAuthRepository(user: _confirmed);
      final bloc = AuthBloc(repo);
      addTearDown(bloc.close);
      var routerTold = 0;
      bloc.addListener(() => routerTold++);

      bloc.add(AuthRegisterEvent(
        fullName: 'Aigerim',
        email: 'aigerim@almaty.kz',
        password: 'long enough',
        role: Role.MANAGER,
      ));
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthAuthenticated>()]),
      );
      expect(repo.registered?.$4, Role.MANAGER);
      expect(bloc.isAuthenticated, isTrue);
      expect(routerTold, 1,
          reason: 'the sign-up form does not navigate; the redirect does');
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
      for (final location in ['/register', '/register/details']) {
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
