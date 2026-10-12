import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
import 'package:real_estate_crm/features/auth/domain/email_verifier.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/create_team_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/register_form_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/register_role_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/waiting_for_team_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _agent = AuthResponse(
    userId: 4,
    fullName: 'Aigerim',
    email: 'aigerim@almaty.kz',
    role: Role.AGENT);

Widget _wrap(Widget child,
        {AuthResponse? user, AuthRepository? repo, EmailVerifier? verifier}) =>
    BlocProvider(
      // The saved session has to be read before anything can show who is in it.
      create: (_) => AuthBloc(repo ?? FakeAuthRepository(user: user),
          verifier: verifier ?? FakeEmailVerifier())
        ..add(AuthCheckEvent()),
      child: child,
    );

class _PendingAuthRepository extends FakeAuthRepository {
  @override
  Future<AuthResponse> verifyEmail(String idToken) async {
    verifiedWith = idToken;
    return _agent;
  }
}

final _request = TeamJoinRequestResponse(
  id: 3,
  teamId: 1,
  teamName: 'Almaty Realty',
  invitedByName: 'Nurlan Bekov',
  userId: 4,
  userFullName: 'Aigerim',
  userEmail: 'aigerim@almaty.kz',
  createdAt: DateTime(2026, 9, 1),
);

void main() {
  setUp(() {
    Injector.teamsRepository = FakeTeamsRepository(requests: [_request]);
  });

  forEachAcceptanceCase('sign-up role',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _wrap(const RegisterRoleScreen()),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('sign-up form',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
        tester, _wrap(const RegisterFormScreen(role: Role.MANAGER)),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('verify email',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
        tester, _wrap(const VerifyEmailScreen(email: 'boss@almaty.kz')),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('create team', (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _wrap(const CreateTeamScreen()),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('waiting for a team',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
        tester, _wrap(const WaitingForTeamScreen(), user: _agent),
        size: size, brightness: brightness, textScale: scale);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('sign-up renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(const RegisterFormScreen(role: Role.AGENT)),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.5,
        locale: locale,
      );
    });

    testWidgets('verify email renders in ${locale.languageCode}',
        (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(const VerifyEmailScreen(email: 'aigerim.nurlanovna@almaty.kz')),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.5,
        locale: locale,
      );
    });
  }

  group('the waiting screen', () {
    testWidgets('shows the address a manager has to be given', (tester) async {
      await expectNoOverflow(
          tester, _wrap(const WaitingForTeamScreen(), user: _agent),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();

      expect(find.text('aigerim@almaty.kz'), findsOneWidget);
    });

    testWidgets('accepting an invitation joins that team', (tester) async {
      final teams = FakeTeamsRepository(requests: [_request]);
      Injector.teamsRepository = teams;

      await expectNoOverflow(
          tester, _wrap(const WaitingForTeamScreen(), user: _agent),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();

      expect(find.textContaining('Almaty Realty'), findsWidgets);
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(teams.accepted, _request.id);
    });

    testWidgets('declining asks first, because it cannot be undone alone',
        (tester) async {
      final teams = FakeTeamsRepository(requests: [_request]);
      Injector.teamsRepository = teams;

      await expectNoOverflow(
          tester, _wrap(const WaitingForTeamScreen(), user: _agent),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();
      expect(teams.declined, isNull,
          reason: 'the dialog has not been answered');

      await tester.tap(find.widgetWithText(InkWell, 'Decline').last);
      await tester.pumpAndSettle();
      expect(teams.declined, _request.id);
    });
  });

  group('the verify-email screen', () {
    Future<void> open(WidgetTester tester,
        {AuthRepository? repo, EmailVerifier? verifier}) async {
      await expectNoOverflow(
          tester,
          _wrap(const VerifyEmailScreen(email: 'boss@almaty.kz'),
              repo: repo, verifier: verifier),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);
      await tester.pumpAndSettle();
    }

    testWidgets('says where the link went', (tester) async {
      await open(tester);

      expect(find.textContaining('boss@almaty.kz'), findsOneWidget);
    });

    testWidgets('a link not opened yet is said so, and the screen stays',
        (tester) async {
      final repo = FakeAuthRepository();
      await open(tester, repo: repo);

      await tester.tap(find.text("I've opened the link"));
      await tester.pumpAndSettle();

      expect(find.textContaining("hasn't been opened yet"), findsOneWidget);
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(repo.verifiedWith, isNull);
    });

    testWidgets('the link can be asked for again only after a minute',
        (tester) async {
      final verifier = FakeEmailVerifier();
      await open(tester, verifier: verifier);

      await tester.tap(find.text('Send again in 60s'));
      await tester.pump();
      expect(verifier.resent, 0, reason: 'one has only just gone out');

      await tester.pump(const Duration(seconds: 60));
      await tester.tap(find.text('Send the link again'));
      await tester.pumpAndSettle();
      expect(verifier.resent, 1);
      expect(find.text('Send again in 60s'), findsOneWidget,
          reason: 'and the wait starts over');
    });

    testWidgets('coming back from the mail app checks on its own',
        (tester) async {
      final repo = _PendingAuthRepository();
      final verifier = FakeEmailVerifier(idToken: 'id-token');
      await open(tester, repo: repo, verifier: verifier);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(repo.verifiedWith, 'id-token');
    });
  });

  group('creating the agency', () {
    testWidgets('sends the name the manager typed', (tester) async {
      final teams = FakeTeamsRepository();
      Injector.teamsRepository = teams;

      await expectNoOverflow(tester, _wrap(const CreateTeamScreen()),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);

      await tester.enterText(find.byType(TextFormField).first, 'Almaty Realty');
      await tester.tap(find.text('Create and continue'));
      await tester.pumpAndSettle();

      expect(teams.createdTeamName, 'Almaty Realty');
    });

    testWidgets('refuses an empty name rather than creating a nameless agency',
        (tester) async {
      final teams = FakeTeamsRepository();
      Injector.teamsRepository = teams;

      await expectNoOverflow(tester, _wrap(const CreateTeamScreen()),
          size: const Size(390, 844),
          brightness: Brightness.light,
          textScale: 1.0);

      await tester.tap(find.text('Create and continue'));
      await tester.pumpAndSettle();

      expect(teams.createdTeamName, isNull);
    });
  });
}
