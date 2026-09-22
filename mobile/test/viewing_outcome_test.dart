import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_detail_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// Saying how a showing went, and what the buyer's list does about it.
///
/// The rules of the feedback belong to the backend and are tested there. Here:
/// the verdict can be given at all, only where it means something, and a
/// listing already seen says so rather than looking new.

const _listing = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
  areaSqm: 62,
);

const _buyer = ClientResponse(
  id: 1,
  fullName: 'Irina Alexandrovna Sokolova',
  type: ClientType.BUYER,
  budgetMax: 30000000,
);

final _viewing = MeetingResponse(
  id: 31,
  title: 'Viewing',
  scheduledAt: DateTime(2026, 3, 14, 11),
  agentId: 5,
  agentName: 'Maria Kim-Doroshenko',
  clientId: 1,
  clientName: 'Irina Alexandrovna Sokolova',
  propertyId: 7,
  propertyTitle: 'Severny Residence, apartment 84',
  propertyAddress: 'Severny Residence 12',
);

final _call = MeetingResponse(
  id: 32,
  title: 'Call about the mortgage',
  scheduledAt: DateTime(2026, 3, 15, 10),
  agentId: 5,
  agentName: 'Maria Kim-Doroshenko',
  clientId: 1,
  clientName: 'Irina Alexandrovna Sokolova',
);

void _installFakes({
  List<MeetingResponse> meetings = const [],
  List<PropertyMatch> matches = const [],
}) {
  Injector.meetingsRepository = FakeMeetingsRepository(meetings);
  Injector.clientsRepository =
      FakeClientsRepository(clients: const [_buyer], matches: matches);
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.propertiesRepository = FakePropertiesRepository(const [_listing]);
}

Widget _wrap(Widget child, {List<MeetingResponse> meetings = const []}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
        BlocProvider(
            create: (_) => MeetingsBloc(FakeMeetingsRepository(meetings))),
      ],
      child: child,
    );

Future<void> _open(WidgetTester tester, Widget screen,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en'),
    List<MeetingResponse> meetings = const []}) async {
  await expectNoOverflow(tester, _wrap(screen, meetings: meetings),
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('a viewing can be told how it went', (tester) async {
    _installFakes(meetings: [_viewing]);

    await _open(tester, const MeetingDetailScreen(id: 31),
        meetings: [_viewing]);

    expect(find.text('HOW IT WENT'), findsOneWidget);
    expect(find.text('Interested'), findsOneWidget);
    expect(find.text('Turned it down'), findsOneWidget);
    expect(find.text('No show'), findsOneWidget);
  });

  testWidgets('a meeting that is not a viewing is not asked', (tester) async {
    _installFakes(meetings: [_call]);

    await _open(tester, const MeetingDetailScreen(id: 32), meetings: [_call]);

    expect(find.text('HOW IT WENT'), findsNothing,
        reason: 'a call has no flat to have an opinion about');
  });

  testWidgets('turning a listing down says what that means', (tester) async {
    _installFakes(meetings: [_viewing]);

    await _open(tester, const MeetingDetailScreen(id: 31),
        meetings: [_viewing]);
    await tester.tap(find.text('Turned it down'));
    await tester.pumpAndSettle();

    expect(find.text('A listing turned down stops being offered to this buyer'),
        findsOneWidget,
        reason: 'the consequence is not obvious, and it is not undone easily');
    expect(find.text('What they said'), findsOneWidget);
  });

  testWidgets('a listing already seen says so in the match list',
      (tester) async {
    _installFakes(matches: [
      PropertyMatch(property: _listing, lastShownAt: DateTime(2026, 3, 14)),
    ]);

    await _open(tester, const ClientDetailScreen(id: 1));

    expect(find.textContaining('Shown'), findsOneWidget,
        reason: 'offering it as though it were new wastes the viewing');
  });

  testWidgets('a listing never shown carries no history', (tester) async {
    _installFakes(matches: const [PropertyMatch(property: _listing)]);

    await _open(tester, const ClientDetailScreen(id: 1));

    expect(find.textContaining('Shown'), findsNothing);
  });

  forEachAcceptanceCase('the outcome card',
      (tester, size, brightness, scale) async {
    _installFakes(meetings: [
      _viewing.copyWith(
          outcome: ViewingOutcome.REJECTED, outcomeNote: 'Too dark')
    ]);
    await _open(tester, const MeetingDetailScreen(id: 31),
        size: size,
        brightness: brightness,
        textScale: scale,
        meetings: [_viewing]);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the outcome card renders in ${locale.languageCode}',
        (tester) async {
      _installFakes(meetings: [_viewing]);
      await _open(tester, const MeetingDetailScreen(id: 31),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale,
          meetings: [_viewing]);
    });
  }
}
