import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/theme/app_text_scaling.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/features/meetings/presentation/bloc/meetings_bloc.dart';
import 'package:real_estate_crm/features/meetings/presentation/screens/meeting_form_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

final _now = DateTime(2026, 3, 12, 9, 0);

class _RecordingMeetings extends FakeMeetingsRepository {
  _RecordingMeetings() : super(const []);

  final creates = <Map<String, dynamic>>[];
  int loads = 0;

  @override
  Future<List<MeetingResponse>> getMeetings({int? agentId}) async {
    loads++;
    return const [];
  }

  @override
  Future<MeetingResponse> createMeeting(Map<String, dynamic> data) async {
    creates.add(data);
    return MeetingResponse(
        id: 99,
        scheduledAt: _now.add(const Duration(days: 1)),
        agentId: 5,
        clientId: 3);
  }
}

late _RecordingMeetings _repo;

/// The form under a real router, so the navigation it performs on success is
/// part of what is being tested rather than an exception to swallow.
Widget _app() {
  final widget = _form();
  return MaterialApp.router(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: GoRouter(
      initialLocation: '/meetings/new',
      routes: [
        GoRoute(path: '/meetings', builder: (_, __) => const _MeetingsStub()),
        GoRoute(path: '/meetings/new', builder: (_, __) => widget),
      ],
    ),
    builder: (context, child) => MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: AppTextScaling(child: child ?? const SizedBox.shrink()),
    ),
  );
}

class _MeetingsStub extends StatelessWidget {
  const _MeetingsStub();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('meetings list')));
}

Widget _form() {
  _repo = _RecordingMeetings();
  Injector.meetingsRepository = _repo;
  Injector.clientsRepository = FakeClientsRepository(clients: const [
    ClientResponse(id: 3, fullName: 'Айгерим Серикбайқызы'),
  ]);
  Injector.agentsRepository = const FakeAgentsRepository([
    AgentOption(id: 5, fullName: 'Нурлан Беков', email: 'n@x.kz'),
  ]);
  Injector.dealsRepository = FakeDealsRepository(const []);
  return BlocProvider(
    create: (_) => MeetingsBloc(_repo),
    child: const MeetingFormScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
  });

  testWidgets('filling the form in creates the meeting', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Показ на Абая');

    // Client, then agent: both pickers show "Not selected" until they are.
    await tester.tap(find.text('Not selected').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Айгерим Серикбайқызы'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not selected').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Нурлан Беков'));
    await tester.pumpAndSettle();

    // The date field shows its own placeholder until a date is chosen.
    await tester.tap(find.text('Date').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'the picker must open');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final button = find.widgetWithText(AppFilledButton, 'Schedule');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('meetings list'), findsOneWidget,
        reason: 'a saved meeting has to take you back to the list');

    expect(_repo.creates, hasLength(1),
        reason: 'a filled-in form has to reach the repository');
    expect(_repo.creates.single['clientId'], 3);
    expect(_repo.creates.single['agentId'], 5);
    expect(_repo.creates.single['title'], 'Показ на Абая');

    expect(_repo.loads, greaterThan(0),
        reason: 'the list behind the form has to be refetched, or the meeting '
            'appears to have vanished');
  });

  testWidgets('the time defaults to the next half hour, not this instant',
      (tester) async {
    await expectNoOverflow(tester, _form(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Date').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // The clock is frozen at 09:00. A default of "now" would put the meeting
    // in the past the moment the server looked at it.
    expect(find.text('09:30'), findsOneWidget,
        reason: 'picking today and leaving the time alone must still produce a '
            'moment the backend will accept');
  });

  testWidgets('a meeting cannot be scheduled into the past', (tester) async {
    await expectNoOverflow(tester, _form(),
        size: const Size(390, 844),
        brightness: Brightness.light,
        textScale: 1.0);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Date').last);
    await tester.pumpAndSettle();

    // The backend rejects a past scheduledAt outright (MeetingRequest is
    // @Future), so a past day is offered as disabled: tapping it does nothing.
    await tester.tap(find.text('11'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Mar 11'), findsNothing,
        reason: 'yesterday must not be selectable');
  });
}
