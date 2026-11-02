import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/accept_invite_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/register_form_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/reset_password_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

Widget _wrap(Widget child) => BlocProvider(
      create: (_) => AuthBloc(FakeAuthRepository()),
      child: child,
    );

void main() {
  forEachAcceptanceCase('login', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const LoginScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  forEachAcceptanceCase('accept invite',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const AcceptInviteScreen(token: 'ABCD-1234')),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  // An unlabelled eye is read out as "button" and nothing else.
  group('the password eye says what a tap will do', () {
    const screens = <String, Widget>{
      'login': LoginScreen(),
      'sign-up': RegisterFormScreen(role: Role.AGENT),
      'reset password': ResetPasswordScreen(),
      'accept invite': AcceptInviteScreen(token: 'ABCD-1234'),
    };
    for (final MapEntry(key: name, value: screen) in screens.entries) {
      testWidgets(name, (tester) async {
        await expectNoOverflow(tester, _wrap(screen),
            size: const Size(390, 844),
            brightness: Brightness.light,
            textScale: 1.0);

        expect(find.byTooltip('Show password'), findsOneWidget);
        expect(find.byTooltip('Hide password'), findsNothing);

        await tester.ensureVisible(find.byTooltip('Show password'));
        await tester.tap(find.byTooltip('Show password'));
        await tester.pump();

        expect(find.byTooltip('Hide password'), findsOneWidget);
        expect(find.byTooltip('Show password'), findsNothing);
      });
    }
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('login renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(const LoginScreen()),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.5,
        locale: locale,
      );
    });
  }
}
