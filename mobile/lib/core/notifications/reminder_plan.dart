import 'package:real_estate_crm/core/models/models.dart';

/// How far ahead of a meeting its reminder fires.
enum ReminderLead {
  fifteenMinutes(Duration(minutes: 15)),
  oneHour(Duration(hours: 1)),
  oneDay(Duration(days: 1));

  const ReminderLead(this.duration);
  final Duration duration;
}

class ReminderSettings {
  final bool enabled;
  final ReminderLead lead;

  const ReminderSettings(
      {this.enabled = false, this.lead = ReminderLead.oneHour});

  ReminderSettings copyWith({bool? enabled, ReminderLead? lead}) =>
      ReminderSettings(
          enabled: enabled ?? this.enabled, lead: lead ?? this.lead);
}

/// One notification the app intends to have waiting.
///
/// Carries the meeting rather than a finished sentence: this is decided far
/// from any [BuildContext], and the wording has to come out in the reader's
/// language when it is handed to the system.
class PlannedReminder {
  /// Stable across re-plans so rescheduling replaces rather than duplicates —
  /// the platform keys pending notifications by id.
  final int id;
  final int meetingId;
  final DateTime fireAt;
  final DateTime meetingAt;
  final String? meetingTitle;
  final String? clientName;
  final String? location;

  const PlannedReminder({
    required this.id,
    required this.meetingId,
    required this.fireAt,
    required this.meetingAt,
    this.meetingTitle,
    this.clientName,
    this.location,
  });
}

/// iOS keeps at most 64 pending local notifications and silently drops the
/// rest, so the plan stays under that with room for anything else the app
/// might one day schedule.
const kMaxPendingReminders = 60;

/// Which meetings deserve a reminder, and when.
///
/// Deliberately a pure function of the data, the settings and the clock: it is
/// the part worth testing, and the part that would otherwise only be observable
/// by waiting an hour with a real phone.
///
/// Rules, in the order they bite:
///
/// * Reminders off means no reminders at all — including cancelling ones
///   already scheduled, which the caller does by acting on an empty plan.
/// * A completed meeting is not upcoming, whatever its date says.
/// * A meeting that has already started needs no warning.
/// * Neither does one whose warning time has passed. Someone who asks for an
///   hour's notice about a meeting starting in ten minutes is better served by
///   silence than by a notification that fires the instant they set it.
/// * The soonest survive the cap, because they are the ones that still matter.
List<PlannedReminder> planReminders(
  List<MeetingResponse> meetings, {
  required ReminderSettings settings,
  required DateTime now,
  int limit = kMaxPendingReminders,
}) {
  if (!settings.enabled) return const [];

  final planned = <PlannedReminder>[];
  for (final meeting in meetings) {
    if (meeting.completed) continue;
    if (!meeting.scheduledAt.isAfter(now)) continue;

    final fireAt = meeting.scheduledAt.subtract(settings.lead.duration);
    if (!fireAt.isAfter(now)) continue;

    planned.add(PlannedReminder(
      id: meeting.id,
      meetingId: meeting.id,
      fireAt: fireAt,
      meetingAt: meeting.scheduledAt,
      meetingTitle: meeting.title,
      clientName: meeting.clientName,
      location: meeting.location,
    ));
  }

  planned.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return planned.length <= limit ? planned : planned.sublist(0, limit);
}
