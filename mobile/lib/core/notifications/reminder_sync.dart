import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Future<void> syncMeetingReminders({
  required NotificationGateway gateway,
  required List<MeetingResponse> meetings,
  required ReminderSettings settings,
  required AppLocalizations l10n,
}) async {
  final planned = planReminders(
    meetings,
    settings: settings,
    now: AppClock.now(),
  );

  await gateway.replaceAll([
    for (final reminder in planned)
      ScheduledNotification(
        id: reminder.id,
        title: _title(reminder, l10n),
        body: _body(reminder, l10n),
        at: reminder.fireAt,
      ),
  ]);
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
