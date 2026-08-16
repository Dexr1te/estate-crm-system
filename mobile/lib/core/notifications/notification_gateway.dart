import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The seam between deciding what to schedule and asking the OS to hold it.
///
/// Everything above this is a pure function of meetings, settings and the clock
/// (see `reminder_plan.dart`) and is tested as such. This part cannot be, so it
/// is kept as thin as it can be: no decisions, only calls.
abstract class NotificationGateway {
  /// Whether the OS will actually deliver anything. False when the person said
  /// no, which is a normal answer and not an error.
  Future<bool> requestPermission();

  /// Replaces everything currently pending with [reminders].
  Future<void> replaceAll(List<ScheduledNotification> reminders);

  Future<void> cancelAll();
}

/// A notification, already worded, waiting for its moment.
class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime at;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
  });
}

class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Loads the timezone database and points it at the device's zone.
  ///
  /// Without this every scheduled time would be read as UTC, which is only
  /// harmless on the prime meridian: a 10:00 reminder in Almaty would arrive at
  /// 15:00. Done lazily so an install that never turns reminders on never pays
  /// for the database.
  Future<void> _ensureReady() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error) {
      // A zone the database does not know is better than crashing on launch;
      // the reminder lands at the wrong hour, and the log says why.
      debugPrint('[reminders] falling back to UTC: $error');
    }

    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Asked for explicitly when the switch is turned on, so the prompt lands
      // next to the thing that explains it rather than on first launch.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureReady();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
              alert: true, badge: true, sound: true) ??
          false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(List<ScheduledNotification> reminders) async {
    await _ensureReady();
    // Cancelling first is what makes a sync idempotent: a meeting moved, marked
    // done or deleted has to lose its pending notification, and the ids alone
    // cannot express a removal.
    await _plugin.cancelAll();

    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        tz.TZDateTime.from(reminder.at, tz.local),
        _details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Inexact on purpose. Exact alarms need a permission Google restricts to
        // apps whose core function is alarms, and a viewing reminder is content
        // with a few minutes of slack.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _ensureReady();
    await _plugin.cancelAll();
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'meeting_reminders',
      'Meeting reminders',
      channelDescription: 'A warning before a scheduled meeting',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );
}
