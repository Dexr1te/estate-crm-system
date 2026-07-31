import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';

import 'fakes.dart';

const _saved = AuthResponse(
    userId: 1, fullName: 'Sultan', email: 's@estate.crm', role: Role.AGENT);

class _SlowAuthRepository extends FakeAuthRepository {
  _SlowAuthRepository({this.saved});
  final AuthResponse? saved;
  final _gate = Completer<AuthResponse?>();

  void release() => _gate.complete(saved);

  @override
  Future<AuthResponse?> getSavedUser() => _gate.future;
  @override
  bool get isLoggedIn => saved != null;
}

String? _go(String location,
        {bool resolved = true, bool authed = true, Role? role = Role.AGENT}) =>
    resolveRedirect(
      location: location,
      sessionResolved: resolved,
      authenticated: authed,
      role: role,
    );

void main() {
  group('while the saved session is still being read', () {
    test('a protected route waits on the splash instead of going to login', () {
      expect(_go('/dashboard', resolved: false, authed: false), '/splash');
      expect(_go('/clients/12', resolved: false, authed: false), '/splash');
    });

    test('the splash itself is allowed to stay', () {
      expect(_go('/splash', resolved: false, authed: false), isNull);
    });

    test('even the login route waits, so it cannot flash either', () {
      expect(_go('/login', resolved: false, authed: false), '/splash');
    });
  });

  group('once the session is known', () {
    test('the splash hands over to the dashboard for a signed-in user', () {
      expect(_go('/splash', authed: true), '/dashboard');
    });

    test('the splash hands over to login for a signed-out user', () {
      expect(_go('/splash', authed: false, role: null), '/login');
    });

    test('nothing can strand a signed-in user on the splash', () {
      expect(_go('/splash'), isNot('/splash'));
    });
  });

  group('the existing rules still hold', () {
    test('a signed-out user is sent to login', () {
      expect(_go('/dashboard', authed: false, role: null), '/login');
    });

    test('invite acceptance is reachable while signed out', () {
      expect(_go('/accept-invite', authed: false, role: null), isNull);
    });

    test('a signed-in user is pushed off the auth screens', () {
      expect(_go('/login'), '/dashboard');
    });

    test('admin is gated to ADMIN', () {
      expect(_go('/admin', role: Role.AGENT), '/dashboard');
      expect(_go('/admin', role: Role.ADMIN), isNull);
    });

    test('the team console is gated to MANAGER', () {
      expect(_go('/team-console', role: Role.ADMIN), '/dashboard');
      expect(_go('/team-console', role: Role.MANAGER), isNull);
    });
  });

  test('AuthBloc reports the session unresolved until the check lands',
      () async {
    final repo = _SlowAuthRepository(saved: _saved);
    final bloc = AuthBloc(repo)..add(AuthCheckEvent());
    addTearDown(bloc.close);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.isSessionResolved, isFalse);
    expect(bloc.isAuthenticated, isFalse,
        reason: 'the two must not be conflated — this pair is the bug');

    repo.release();
    await Future<void>.delayed(Duration.zero);

    expect(bloc.isSessionResolved, isTrue);
    expect(bloc.isAuthenticated, isTrue);
  });
}
