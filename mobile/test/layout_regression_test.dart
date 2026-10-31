import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/properties_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _size = Size(390, 844);

void main() {
  setUp(() {
    Injector.clientsRepository = FakeClientsRepository(clients: const []);
    Injector.propertiesRepository = FakePropertiesRepository(const []);
  });

  group('a list tab leaves its "+" to the floating one in the shell', () {
    Future<void> check(WidgetTester tester, Widget screen) async {
      await expectNoOverflow(
        tester,
        screen,
        size: _size,
        brightness: Brightness.light,
        textScale: 1.0,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('quick-add')), findsNothing);
      // Compare may be spelt out as a header action where it fits; nothing
      // else may be.
      expect(
          find.byWidgetPredicate((w) =>
              w is AppHeaderAction &&
              w.key != const ValueKey('properties-compare')),
          findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    }

    testWidgets('clients', (tester) async {
      await check(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
            BlocProvider(
                create: (_) =>
                    ClientsBloc(FakeClientsRepository(clients: const []))),
          ],
          child: const ClientsScreen(),
        ),
      );
    });

    testWidgets('properties', (tester) async {
      await check(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
            BlocProvider(
                create: (_) =>
                    PropertiesBloc(FakePropertiesRepository(const []))),
          ],
          child: const PropertiesScreen(),
        ),
      );
    });
  });

  testWidgets('constrain() top-aligns content shorter than the viewport',
      (tester) async {
    await expectNoOverflow(
      tester,
      Scaffold(
        body: AppMetrics.constrain(
          const SizedBox(
              key: ValueKey('content'), height: 120, width: double.infinity),
        ),
      ),
      size: _size,
      brightness: Brightness.light,
      textScale: 1.0,
    );

    final content = tester.getRect(find.byKey(const ValueKey('content')));
    expect(content.top, 0,
        reason: 'short page content must start at the top, not be centred');
  });

  testWidgets('a form screen renders its first card under the app bar',
      (tester) async {
    await expectNoOverflow(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(
              create: (_) =>
                  ClientsBloc(FakeClientsRepository(clients: const []))),
        ],
        child: const ClientFormScreen(),
      ),
      size: _size,
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    final appBar = tester.getRect(find.byType(DetailAppBar));
    final firstCard = tester.getRect(find.byType(FormSectionCard).first);
    expect(firstCard.top, greaterThan(appBar.bottom));
    expect(firstCard.top, lessThan(appBar.bottom + 140),
        reason: 'the form is floating below the top of the screen');
  });
}
