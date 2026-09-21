import 'package:real_estate_crm/core/models/models.dart';

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

class PlannedReminder {
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

const kMaxPendingReminders = 60;

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
