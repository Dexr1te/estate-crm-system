import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';

final _now = DateTime(2026, 3, 12, 9, 0);

MeetingResponse _meeting(
  int id,
  Duration fromNow, {
  bool completed = false,
  String title = 'Viewing',
}) =>
    MeetingResponse(
      id: id,
      title: title,
      scheduledAt: _now.add(fromNow),
      completed: completed,
      agentId: 1,
      clientId: 1,
      clientName: 'Aisha Karimova',
    );

List<PlannedReminder> _plan(
  List<MeetingResponse> meetings, {
  ReminderLead lead = ReminderLead.oneHour,
  bool enabled = true,
  int limit = kMaxPendingReminders,
}) =>
    planReminders(
      meetings,
      settings: ReminderSettings(enabled: enabled, lead: lead),
      now: _now,
      limit: limit,
    );

void main() {
  test('a meeting tomorrow is warned about an hour before it', () {
    final plan = _plan([_meeting(1, const Duration(days: 1))]);

    expect(plan, hasLength(1));
    expect(plan.single.fireAt, _now.add(const Duration(days: 1, hours: -1)));
    expect(plan.single.meetingAt, _now.add(const Duration(days: 1)));
  });

  test('the lead time is the one that was chosen', () {
    for (final lead in ReminderLead.values) {
      final plan = _plan([_meeting(1, const Duration(days: 2))], lead: lead);
      expect(plan.single.fireAt,
          _now.add(const Duration(days: 2)).subtract(lead.duration),
          reason: '${lead.name} should fire ${lead.duration} before');
    }
  });

  test('turning reminders off plans nothing at all', () {
    final plan = _plan([_meeting(1, const Duration(days: 1))], enabled: false);

    expect(plan, isEmpty,
        reason: 'an empty plan is what tells the caller to cancel what is '
            'already scheduled');
  });

  group('meetings that do not need warning about', () {
    test('one that has already happened', () {
      expect(_plan([_meeting(1, const Duration(hours: -2))]), isEmpty);
    });

    test('one marked completed, whatever its date says', () {
      expect(_plan([_meeting(1, const Duration(days: 1), completed: true)]),
          isEmpty);
    });

    test('one starting sooner than the notice asked for', () {
      // An hour's notice about a meeting in ten minutes would fire the instant
      // it was scheduled, which is not a reminder — it is a surprise.
      expect(_plan([_meeting(1, const Duration(minutes: 10))]), isEmpty);
    });

    test('but a shorter lead still catches it', () {
      final plan = _plan([_meeting(1, const Duration(minutes: 30))],
          lead: ReminderLead.fifteenMinutes);
      expect(plan, hasLength(1));
      expect(plan.single.fireAt, _now.add(const Duration(minutes: 15)));
    });
  });

  test('the id is the meeting, so re-planning replaces rather than piles up',
      () {
    final first = _plan([_meeting(7, const Duration(days: 1))]);
    final again = _plan([_meeting(7, const Duration(days: 1, hours: 2))]);

    expect(first.single.id, 7);
    expect(again.single.id, first.single.id,
        reason: 'the platform keys pending notifications by id — a new id per '
            'sync would leave the old one to fire as well');
  });

  group('the platform cap', () {
    test('is never exceeded', () {
      final many = [
        for (var i = 0; i < 100; i++) _meeting(i, Duration(days: 2 + i)),
      ];
      expect(_plan(many), hasLength(kMaxPendingReminders));
    });

    test('keeps the soonest, because those are the ones still worth having',
        () {
      final many = [
        for (var i = 0; i < 10; i++) _meeting(i, Duration(days: 10 - i)),
      ];
      final plan = _plan(many, limit: 3);

      expect(plan.map((r) => r.meetingId), [9, 8, 7],
          reason: 'meeting 9 is the soonest of the ten');
      expect(plan.first.fireAt.isBefore(plan.last.fireAt), isTrue);
    });
  });

  test('the plan carries the meeting, not a finished sentence', () {
    final plan = _plan([_meeting(1, const Duration(days: 1), title: 'Показ')]);

    expect(plan.single.meetingTitle, 'Показ');
    expect(plan.single.clientName, 'Aisha Karimova',
        reason: 'the wording is built where localizations exist, so the plan '
            'has to hand over the parts rather than the sentence');
  });
}
