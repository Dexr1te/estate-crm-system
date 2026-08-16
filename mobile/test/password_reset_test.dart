import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/deep_links.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/reset_password_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

late FakeAuthRepository _repo;

Widget _forgot() {
  _repo = FakeAuthRepository();
  Injector.authRepository = _repo;
  return const ForgotPasswordScreen();
}

Widget _reset({String? token}) => BlocProvider(
      create: (_) => AuthBloc(FakeAuthRepository(
          user: const AuthResponse(
              userId: 1, fullName: 'A', email: 'a@b.c', role: Role.AGENT))),
      child: ResetPasswordScreen(token: token),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('a link from the reset email knows where to go', () {
    test('the custom scheme the landing page offers', () {
      expect(resolveDeepLink(Uri.parse('estatecrm://reset-password?token=abc')),
          '/reset-password?token=abc');
    });

    test('the landing URL itself, for when Universal Links are live', () {
      expect(
          resolveDeepLink(
              Uri.parse('https://host.example/api/reset?token=abc')),
          '/reset-password?token=abc');
    });

    test('a code-less link still opens the screen', () {
      expect(resolveDeepLink(Uri.parse('estatecrm://reset-password')),
          '/reset-password');
    });

    test('an invite link is still an invite link', () {
      expect(resolveDeepLink(Uri.parse('estatecrm://accept-invite?token=xyz')),
          '/accept-invite?token=xyz');
    });
  });

  group('the reset screens are reachable without a session', () {
    for (final location in ['/forgot-password', '/reset-password']) {
      test('$location is not bounced to sign-in', () {
        expect(
          resolveRedirect(
              location: location,
              sessionResolved: true,
              authenticated: false,
              role: null),
          isNull,
          reason: 'someone resetting a password has no session by definition',
        );
      });
    }
  });

  forEachAcceptanceCase('forgot password',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _forgot(),
        size: size, brightness: brightness, textScale: scale);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('reset password',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(tester, _reset(token: 'abc'),
        size: size, brightness: brightness, textScale: scale);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the code from the link arrives already filled in',
      (tester) async {
    await expectNoOverflow(tester, _reset(token: 'code-from-email'),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    expect(find.text('code-from-email'), findsOneWidget,
        reason: 'retyping a code you were just sent is the one thing the link '
            'is supposed to save you');
  });

  testWidgets('asking for a link says nothing about who has an account',
      (tester) async {
    await expectNoOverflow(tester, _forgot(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'someone@estatecrm.kz');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(_repo.resetRequestedFor, 'someone@estatecrm.kz');
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('someone@estatecrm.kz'), findsWidgets,
        reason: 'the confirmation is deliberately conditional — "if that '
            'address has an account" — so it cannot be used to enumerate staff');
  });
}
