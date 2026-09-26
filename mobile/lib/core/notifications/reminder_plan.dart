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

const kTaskReminderIdBase = 1 << 30;

int taskReminderId(int taskId) => kTaskReminderIdBase + taskId;

class PlannedTaskReminder {
  final int id;
  final int taskId;
  final DateTime fireAt;
  final String title;
  final String? clientName;

  const PlannedTaskReminder({
    required this.id,
    required this.taskId,
    required this.fireAt,
    required this.title,
    this.clientName,
  });
}

List<PlannedTaskReminder> planTaskReminders(
  List<TaskResponse> tasks, {
  required ReminderSettings settings,
  required DateTime now,
  int? assigneeId,
  int limit = kMaxPendingReminders,
}) {
  if (!settings.enabled) return const [];

  final planned = [
    for (final task in tasks)
      if (!task.isDone &&
          task.dueAt.isAfter(now) &&
          (assigneeId == null || task.assigneeId == assigneeId))
        PlannedTaskReminder(
          id: taskReminderId(task.id),
          taskId: task.id,
          fireAt: task.dueAt,
          title: task.title,
          clientName: task.clientName,
        ),
  ]..sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return planned.length <= limit ? planned : planned.sublist(0, limit);
}

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
