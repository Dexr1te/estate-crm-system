import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/team_models.dart';
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

Widget _wrap(Widget child, {AuthResponse? user}) => BlocProvider(
      // The saved session has to be read before anything can show who is in it.
      create: (_) =>
          AuthBloc(FakeAuthRepository(user: user))..add(AuthCheckEvent()),
      child: child,
    );

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

  forEachAcceptanceCase('sign-up role', (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _wrap(const RegisterRoleScreen()),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('sign-up form', (tester, size, brightness, scale) async {
    await expectNoOverflow(
        tester, _wrap(const RegisterFormScreen(role: Role.MANAGER)),
        size: size, brightness: brightness, textScale: scale);
  });

  forEachAcceptanceCase('verify email', (tester, size, brightness, scale) async {
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
        textScale: 1.3,
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
      expect(teams.declined, isNull, reason: 'the dialog has not been answered');

      await tester.tap(find.widgetWithText(InkWell, 'Decline').last);
      await tester.pumpAndSettle();
      expect(teams.declined, _request.id);
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
