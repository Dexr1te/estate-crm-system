import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/locale/bloc/locale_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/profile/presentation/screens/profile_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _user = AuthResponse(
  userId: 5,
  fullName: 'Sultan Assan-Doroshenko',
  email: 'asansultan25@gmail.com',
  role: Role.ADMIN,
);

Widget _profile() {
  final auth = AuthBloc(FakeAuthRepository(user: _user))..add(AuthCheckEvent());
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: auth),
      BlocProvider(create: (_) => ThemeBloc()),
      BlocProvider(create: (_) => LocaleBloc()),
    ],
    child: const ProfileScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  forEachAcceptanceCase('profile', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('profile renders in ${locale.languageCode}', (tester) async {
      await expectNoOverflow(
        tester,
        _profile(),
        size: const Size(320, 568),
        brightness: Brightness.dark,
        textScale: 1.3,
        locale: locale,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the role renders localised, never as a raw enum value',
      (tester) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: const Locale('ru'),
    );
    await tester.pumpAndSettle();

    expect(find.text('АДМИН'), findsOneWidget);
    expect(find.text('ADMIN'), findsNothing);
  });
}
