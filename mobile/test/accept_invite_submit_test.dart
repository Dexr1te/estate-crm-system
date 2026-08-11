import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/accept_invite_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

const _accepted = AuthResponse(
    userId: 3, fullName: 'Sultan', email: 's@estate.crm', role: Role.AGENT);

/// Counts calls and holds the first one open, the way a real network call stays
/// open while the user can still press the button again.
class _CountingAuthRepository extends FakeAuthRepository {
  _CountingAuthRepository() : super(user: _accepted);

  int calls = 0;
  final _gate = Completer<void>();

  /// Idempotent, and always run from a tear-down: a handler parked on this gate
  /// would otherwise keep `bloc.close()` waiting forever whenever an
  /// expectation fails, turning a failed test into a hung suite.
  void release() {
    if (!_gate.isCompleted) _gate.complete();
  }

  @override
  Future<AuthResponse> acceptInvite(String token, String newPassword) async {
    calls++;
    await _gate.future;
    return _accepted;
  }
}

void main() {
  // The invite token is spent by the first request that reaches the backend, so
  // a second one is answered with "Invalid invite token" — telling the user the
  // invite failed at the exact moment it succeeded, and leaving them on the
  // form with a password that now works. Whatever the UI does, one request.
  test('a second accept while the first is in flight is dropped', () async {
    final repo = _CountingAuthRepository();
    final bloc = AuthBloc(repo);
    addTearDown(bloc.close);
    addTearDown(repo.release); // LIFO: released before close() waits on it

    bloc.add(AuthAcceptInviteEvent('tok-1', 'hunter22'));
    bloc.add(AuthAcceptInviteEvent('tok-1', 'hunter22'));
    await Future<void>.delayed(Duration.zero);

    expect(repo.calls, 1, reason: 'the token can only be spent once');
  });

  // Two taps inside one frame: the button disables itself on AuthLoading, but
  // that only takes effect on the next rebuild, so the guard cannot live there.
  testWidgets('double-tapping the button sends one request', (tester) async {
    final repo = _CountingAuthRepository();
    final bloc = AuthBloc(repo);
    addTearDown(bloc.close);
    addTearDown(repo.release);

    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AcceptInviteScreen(token: 'tok-1'),
      ),
    ));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), 'hunter22');
    await tester.enterText(fields.at(2), 'hunter22');
    await tester.pump();

    final button = find.text('Set password & sign in');
    await tester.tap(button, warnIfMissed: false);
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();

    expect(repo.calls, 1);

    // Land the request before the test ends: the button's spinner is an endless
    // animation, and a test cannot finish with one still running.
    repo.release();
    await tester.pump();
    await tester.pump();
  });
}
