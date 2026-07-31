import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/accept_invite_screen.dart';
import 'package:real_estate_crm/features/auth/presentation/screens/login_screen.dart';

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

  forEachAcceptanceCase('accept invite', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const AcceptInviteScreen(token: 'ABCD-1234')),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('login renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        _wrap(const LoginScreen()),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.3,
        locale: locale,
      );
    });
  }
}
