import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/deals/presentation/bloc/deals_bloc.dart';
import 'package:real_estate_crm/features/deals/presentation/screens/deal_form_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_form_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

// Every repository below is empty, so loading record 404 fails the way a
// deleted record, a timeout or an empty offline cache does. The edit form
// used to drop its skeleton and show its fields blank; the client form only
// requires a name, so typing one and saving sent empty tags, no lead source
// and no birthday -- overwriting the real record with nothing.

Future<void> _pump(WidgetTester tester, String location, Widget form) async {
  final clients = FakeClientsRepository();
  final properties = FakePropertiesRepository(const []);
  final deals = FakeDealsRepository(const []);
  final meetings = FakeMeetingsRepository(const []);
  Injector.clientsRepository = clients;
  Injector.propertiesRepository = properties;
  Injector.dealsRepository = deals;
  Injector.meetingsRepository = meetings;
  Injector.agentsRepository = const FakeAgentsRepository([]);

  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
      BlocProvider(create: (_) => ClientsBloc(clients)),
      BlocProvider(create: (_) => PropertiesBloc(properties)),
      BlocProvider(create: (_) => DealsBloc(deals)),
      BlocProvider(create: (_) => MeetingsBloc(meetings)),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: location,
        routes: [GoRoute(path: location, builder: (_, __) => form)],
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void _expectNoForm(WidgetTester tester, String saveLabel) {
  expect(find.text(saveLabel), findsNothing,
      reason: 'a form that never loaded must not be savable');
  expect(find.byType(TextFormField), findsNothing,
      reason: 'blank fields read as a record with nothing in it');
  expect(find.byType(ErrorWidget2), findsOneWidget);
  expect(find.text('Retry'), findsOneWidget);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('editing a client that did not load', (tester) async {
    await _pump(
        tester, '/clients/404/edit', const ClientFormScreen(clientId: 404));
    _expectNoForm(tester, 'Update client');
  });

  testWidgets('editing a listing that did not load', (tester) async {
    await _pump(tester, '/properties/404/edit',
        const PropertyFormScreen(propertyId: 404));
    _expectNoForm(tester, 'Next — details');
  });

  testWidgets('editing a deal that did not load', (tester) async {
    await _pump(tester, '/deals/404/edit', const DealFormScreen(dealId: 404));
    _expectNoForm(tester, 'Update deal');
  });

  testWidgets('editing a meeting that did not load', (tester) async {
    await _pump(
        tester, '/meetings/404/edit', const MeetingFormScreen(meetingId: 404));
    _expectNoForm(tester, 'Update meeting');
  });
}
