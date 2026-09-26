import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';
import 'package:real_estate_crm/core/notifications/reminder_sync.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';

/// A task is reminded about at the moment it falls due, only to the person who
/// has to do it, only while it is open, and never under an id a meeting's
/// reminder could also be using — the gateway replaces everything at once, so
/// a collision would silently drop one of the two.

final _now = DateTime(2026, 9, 25, 9, 0);

TaskResponse _task(int id, Duration fromNow,
        {int assignee = 5, bool done = false, String? client}) =>
    TaskResponse(
      id: id,
      title: 'Call Irina back',
      dueAt: _now.add(fromNow),
      assigneeId: assignee,
      completedAt: done ? _now : null,
      clientName: client,
    );

MeetingResponse _meeting(int id, Duration fromNow) => MeetingResponse(
      id: id,
      title: 'Viewing',
      scheduledAt: _now.add(fromNow),
      agentId: 5,
      clientId: 1,
    );

const _on = ReminderSettings(enabled: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
  });

  test('an open task is reminded about when it falls due', () {
    final plan = planTaskReminders([_task(1, const Duration(hours: 3))],
        settings: _on, now: _now, assigneeId: 5);

    expect(plan.single.fireAt, _now.add(const Duration(hours: 3)));
    expect(plan.single.taskId, 1);
  });

  test('done, overdue and other people\'s tasks plan nothing', () {
    final plan = planTaskReminders([
      _task(1, const Duration(hours: 3), done: true),
      _task(2, const Duration(hours: -1)),
      _task(3, const Duration(hours: 3), assignee: 9),
    ], settings: _on, now: _now, assigneeId: 5);

    expect(plan, isEmpty);
  });

  test('turning reminders off plans no task either', () {
    final plan = planTaskReminders([_task(1, const Duration(hours: 3))],
        settings: const ReminderSettings(enabled: false), now: _now);

    expect(plan, isEmpty);
  });

  test('a task and a meeting with the same id get different notifications',
      () async {
    final gateway = FakeNotificationGateway();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await syncReminders(
      gateway: gateway,
      meetings: [_meeting(7, const Duration(days: 1))],
      tasks: [_task(7, const Duration(days: 1))],
      assigneeId: 5,
      settings: _on,
      l10n: l10n,
    );

    final ids = gateway.scheduled.map((n) => n.id).toSet();
    expect(ids, {7, taskReminderId(7)});
    expect(taskReminderId(7), lessThan(1 << 31),
        reason: 'notification ids are 32-bit on Android');
  });

  test('completing or deleting a task takes its reminder away on the next sync',
      () async {
    final gateway = FakeNotificationGateway();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    Future<void> sync(List<TaskResponse> tasks) => syncReminders(
        gateway: gateway,
        meetings: const [],
        tasks: tasks,
        assigneeId: 5,
        settings: _on,
        l10n: l10n);

    await sync([_task(1, const Duration(hours: 2))]);
    expect(gateway.scheduled, hasLength(1));

    await sync([_task(1, const Duration(hours: 2), done: true)]);
    expect(gateway.scheduled, isEmpty);

    await sync([_task(1, const Duration(hours: 2))]);
    await sync(const []);
    expect(gateway.scheduled, isEmpty);
  });

  test('the reminder is worded in the reader\'s language and names the client',
      () async {
    final gateway = FakeNotificationGateway();
    final l10n = await AppLocalizations.delegate.load(const Locale('ru'));

    await syncReminders(
      gateway: gateway,
      meetings: const [],
      tasks: [_task(1, const Duration(hours: 2), client: 'Ирина')],
      assigneeId: 5,
      settings: _on,
      l10n: l10n,
    );

    expect(gateway.scheduled.single.title, 'Call Irina back');
    expect(gateway.scheduled.single.body, 'Пора сделать · Ирина');
  });

  test('meetings and tasks together stay under the platform\'s cap', () async {
    final gateway = FakeNotificationGateway();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await syncReminders(
      gateway: gateway,
      meetings: [
        for (var i = 1; i <= 50; i++) _meeting(i, Duration(days: i, hours: 2))
      ],
      tasks: [for (var i = 1; i <= 50; i++) _task(i, Duration(days: i))],
      assigneeId: 5,
      settings: _on,
      l10n: l10n,
    );

    expect(gateway.scheduled, hasLength(kMaxPendingReminders));
    expect(gateway.scheduled.first.at, _now.add(const Duration(days: 1)),
        reason: 'the soonest are the ones kept');
  });
}
