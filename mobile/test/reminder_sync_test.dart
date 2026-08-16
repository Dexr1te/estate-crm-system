import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';
import 'package:real_estate_crm/core/notifications/reminder_sync.dart';
import 'package:real_estate_crm/core/notifications/reminders_bloc.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

final _now = DateTime(2026, 3, 12, 9, 0);

MeetingResponse _meeting(int id, Duration fromNow,
        {String title = 'Viewing', String client = 'Aisha Karimova'}) =>
    MeetingResponse(
      id: id,
      title: title,
      scheduledAt: _now.add(fromNow),
      agentId: 1,
      clientId: 1,
      clientName: client,
    );

Future<void> _sync(
  FakeNotificationGateway gateway,
  List<MeetingResponse> meetings, {
  required ReminderSettings settings,
  Locale locale = const Locale('en'),
}) async {
  final l10n = await AppLocalizations.delegate.load(locale);
  await syncMeetingReminders(
    gateway: gateway,
    meetings: meetings,
    settings: settings,
    l10n: l10n,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
  });

  test('a reminder is worded in the reader’s language, not English', () async {
    final gateway = FakeNotificationGateway();

    await _sync(gateway, [_meeting(1, const Duration(days: 1))],
        settings: const ReminderSettings(enabled: true),
        locale: const Locale('ru'));

    expect(gateway.scheduled.single.body, contains('Начало в'));
    expect(gateway.scheduled.single.body, contains('Aisha Karimova'));
  });

  test('the meeting’s own title is what the notification is called', () async {
    final gateway = FakeNotificationGateway();

    await _sync(gateway, [_meeting(1, const Duration(days: 1), title: 'Показ')],
        settings: const ReminderSettings(enabled: true));

    expect(gateway.scheduled.single.title, 'Показ');
  });

  test('an untitled meeting still says something', () async {
    final gateway = FakeNotificationGateway();

    await _sync(gateway, [_meeting(1, const Duration(days: 1), title: '')],
        settings: const ReminderSettings(enabled: true));

    expect(gateway.scheduled.single.title, 'Meeting');
  });

  test('a meeting with no client on it does not say "with"', () async {
    final gateway = FakeNotificationGateway();

    await _sync(gateway, [_meeting(1, const Duration(days: 1), client: '')],
        settings: const ReminderSettings(enabled: true));

    expect(gateway.scheduled.single.body, isNot(contains('with')));
  });

  test('a sync replaces what was pending rather than adding to it', () async {
    final gateway = FakeNotificationGateway();
    const settings = ReminderSettings(enabled: true);

    await _sync(gateway, [_meeting(1, const Duration(days: 1))],
        settings: settings);
    // The meeting moved on the web; the app hears about it on the next load.
    await _sync(gateway, [_meeting(1, const Duration(days: 3))],
        settings: settings);

    expect(gateway.scheduled, hasLength(1),
        reason: 'the old notification must not survive alongside the new one');
    expect(gateway.scheduled.single.at,
        _now.add(const Duration(days: 3, hours: -1)));
  });

  test('a meeting that disappears takes its reminder with it', () async {
    final gateway = FakeNotificationGateway();
    const settings = ReminderSettings(enabled: true);

    await _sync(gateway, [_meeting(1, const Duration(days: 1))],
        settings: settings);
    await _sync(gateway, const [], settings: settings);

    expect(gateway.scheduled, isEmpty);
  });

  group('the setting', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('asks the OS before it turns anything on', () async {
      final gateway = FakeNotificationGateway();
      final bloc = RemindersBloc(gateway);
      addTearDown(bloc.close);

      bloc.add(RemindersLeadChangedEvent(ReminderLead.oneHour));
      await bloc.stream.first;

      expect(gateway.permissionRequests, 1);
      expect(bloc.state.settings.enabled, isTrue);
      expect(bloc.state.settings.lead, ReminderLead.oneHour);
    });

    test('stays off, and says why, when the OS says no', () async {
      final gateway = FakeNotificationGateway(permissionGranted: false);
      final bloc = RemindersBloc(gateway);
      addTearDown(bloc.close);

      bloc.add(RemindersLeadChangedEvent(ReminderLead.oneHour));
      final state = await bloc.stream.first;

      expect(state.settings.enabled, isFalse,
          reason: 'a switch that stays on while nothing can be delivered is a '
              'lie the app tells every day');
      expect(state.permissionDenied, isTrue);
    });

    test('turning it off cancels what was already waiting', () async {
      final gateway = FakeNotificationGateway();
      final bloc = RemindersBloc(gateway);
      addTearDown(bloc.close);

      bloc.add(RemindersLeadChangedEvent(null));
      await bloc.stream.first;

      expect(gateway.cancelAllCount, 1);
      expect(bloc.state.settings.enabled, isFalse);
    });

    test('is remembered across launches', () async {
      SharedPreferences.setMockInitialValues({
        'reminders_enabled': true,
        'reminders_lead': 'oneDay',
      });
      final bloc = RemindersBloc(FakeNotificationGateway());
      addTearDown(bloc.close);

      bloc.add(RemindersLoadEvent());
      final state = await bloc.stream.first;

      expect(state.settings.enabled, isTrue);
      expect(state.settings.lead, ReminderLead.oneDay);
    });
  });
}
