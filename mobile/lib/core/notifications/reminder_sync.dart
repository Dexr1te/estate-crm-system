import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';
import 'package:real_estate_crm/core/notifications/reminder_plan.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Turns a plan into worded notifications and hands them to the OS.
///
/// Called whenever a fresh list of meetings arrives — from the meetings screen
/// or from the dashboard — because that is the only moment the app knows the
/// truth. A meeting moved on the web, completed by a colleague or deleted has
/// no other way of reaching the pending notification it left behind, and
/// [NotificationGateway.replaceAll] is a replacement rather than an addition
/// for exactly that reason.
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
