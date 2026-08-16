import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/locale/bloc/locale_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
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

FakeAuthRepository _authRepo = FakeAuthRepository(user: _user);

Widget _profile() {
  _authRepo = FakeAuthRepository(user: _user);
  Injector.authRepository = _authRepo;
  Injector.agentsRepository = const FakeAgentsRepository([
    AgentOption(id: 5, fullName: 'Sultan Assan-Doroshenko', email: 'me@x.kz'),
    AgentOption(id: 9, fullName: 'Нурлан Беков', email: 'nurlan@estatecrm.kz'),
  ]);
  final auth = AuthBloc(_authRepo)..add(AuthCheckEvent());
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

  // App Store Review Guideline 5.1.1(v): an app holding an account has to let
  // the person holding it close it from inside the app.
  testWidgets('an account can be closed from the profile screen',
      (tester) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });

  testWidgets('closing an account hands the records to someone else first',
      (tester) async {
    await expectNoOverflow(
      tester,
      _profile(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    // The action sits at the bottom of a scrolling settings page.
    await tester.scrollUntilVisible(find.text('Delete Account'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    // The successor sheet comes first, and never offers you yourself.
    expect(find.text('Hand your records over to'), findsOneWidget);
    // Match on the addresses: the profile behind the sheet shows the signed-in
    // name twice already, so the name alone cannot tell the two apart.
    expect(find.text('nurlan@estatecrm.kz'), findsOneWidget);
    expect(find.text('me@x.kz'), findsNothing,
        reason: 'you cannot hand your own records to yourself');

    await tester.tap(find.text('Нурлан Беков'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Нурлан Беков'), findsWidgets,
        reason: 'the confirmation names who takes the records over');

    await tester.tap(find.widgetWithText(AppGhostButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(_authRepo.deletedWithReplacement, isNull,
        reason: 'backing out of the dialog must not delete anything');
  });

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
