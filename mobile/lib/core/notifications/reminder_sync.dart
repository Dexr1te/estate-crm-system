import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Future<void> syncReminders({
  required NotificationGateway gateway,
  required List<MeetingResponse> meetings,
  List<TaskResponse> tasks = const [],
  int? assigneeId,
  required ReminderSettings settings,
  required AppLocalizations l10n,
}) async {
  final now = AppClock.now();
  final planned = [
    for (final reminder
        in planReminders(meetings, settings: settings, now: now))
      ScheduledNotification(
        id: reminder.id,
        title: _title(reminder, l10n),
        body: _body(reminder, l10n),
        at: reminder.fireAt,
      ),
    for (final reminder in planTaskReminders(tasks,
        settings: settings, now: now, assigneeId: assigneeId))
      ScheduledNotification(
        id: reminder.id,
        title: reminder.title.trim().isEmpty
            ? l10n.tasksTitle
            : reminder.title.trim(),
        body: _taskBody(reminder, l10n),
        at: reminder.fireAt,
      ),
  ]..sort((a, b) => a.at.compareTo(b.at));

  await gateway.replaceAll(planned.length <= kMaxPendingReminders
      ? planned
      : planned.sublist(0, kMaxPendingReminders));
}

String _title(PlannedReminder reminder, AppLocalizations l10n) {
  final title = reminder.meetingTitle?.trim();
  if (title != null && title.isNotEmpty) return title;
  return l10n.remindersFallbackTitle;
}

String _body(PlannedReminder reminder, AppLocalizations l10n) {
  final time = formatTimeOfDay(reminder.meetingAt);
  final client = reminder.clientName?.trim();

  return client == null || client.isEmpty
      ? l10n.remindersBody(time)
      : l10n.remindersBodyWithClient(time, client);
}

String _taskBody(PlannedTaskReminder reminder, AppLocalizations l10n) {
  final client = reminder.clientName?.trim();
  return client == null || client.isEmpty
      ? l10n.remindersTaskDue
      : l10n.remindersTaskDueWithClient(client);
}
