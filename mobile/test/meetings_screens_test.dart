import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_detail_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meetings_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

final _now = DateTime.now();

MeetingResponse _meeting(int id, Duration fromNow, String title,
        {String? location}) =>
    MeetingResponse(
      id: id,
      title: title,
      scheduledAt: _now.add(fromNow),
      location: location,
      agentId: 5,
      agentName: 'Maria Kim-Doroshenko',
      clientId: 9,
      clientName: 'Irina Alexandrovna Sokolova',
      dealId: 3,
      dealTitle: 'Severny Residence, apt 84',
      description: 'Pick the keys up at reception, show the balcony view.',
    );

final _meetings = [
  _meeting(1, const Duration(minutes: 40),
      'Viewing · Severny Residence, apartment 84',
      location: 'Dmitrovskoye shosse, 107k2'),
  _meeting(2, const Duration(hours: 4), 'Согласование цены',
      location: 'звонок'),
  _meeting(3, const Duration(days: 1), 'Подписание договора',
      location: 'офис Тверская'),
  _meeting(4, const Duration(days: 2), 'Повторный показ офиса'),
];

void _installFakes() {
  Injector.meetingsRepository = FakeMeetingsRepository(_meetings);
  Injector.clientsRepository = FakeClientsRepository(clients: const [
    ClientResponse(id: 9, fullName: 'Irina Sokolova', type: ClientType.BUYER),
  ]);
  Injector.dealsRepository = FakeDealsRepository(const []);
}

Widget _wrap(Widget child, {List<MeetingResponse> meetings = const []}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => MeetingsBloc(FakeMeetingsRepository(meetings))),
      ],
      child: child,
    );

void main() {
  setUp(_installFakes);

  forEachAcceptanceCase('meetings list', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const MeetingsScreen(), meetings: _meetings),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('meetings list — empty',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const MeetingsScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('meeting detail',
      (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const MeetingDetailScreen(id: 1)),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  forEachAcceptanceCase('meeting form', (tester, size, brightness, scale) async {
    await expectNoOverflow(
      tester,
      _wrap(const MeetingFormScreen()),
      size: size,
      brightness: brightness,
      textScale: scale,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('meetings render in ${locale.languageCode}', (tester) async {
      for (final screen in [
        const MeetingsScreen(),
        const MeetingDetailScreen(id: 1),
        const MeetingFormScreen(),
      ]) {
        await expectNoOverflow(
          tester,
          _wrap(screen, meetings: _meetings),
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '${screen.runtimeType} in ${locale.languageCode}');
      }
    });
  }

  testWidgets('the soonest meeting is the hero, the rest are day-grouped',
      (tester) async {
    await expectNoOverflow(
      tester,
      _wrap(const MeetingsScreen(), meetings: _meetings),
      size: const Size(430, 932),
      brightness: Brightness.light,
      textScale: 1.0,
    );
    await tester.pumpAndSettle();

    // The hero carries the eyebrow; the later ones are plain schedule rows.
    // Eyebrows render uppercase, per the design token.
    expect(find.text('NEXT UP'), findsOneWidget);
    expect(find.textContaining('Viewing · Severny'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });
}
