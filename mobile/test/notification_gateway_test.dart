import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/notifications/notification_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final scheduled = <int>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    scheduled.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'zonedSchedule') {
        final args = call.arguments as Map<Object?, Object?>;
        scheduled.add(args['id']! as int);
      }
      return call.method == 'initialize' ? true : null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('a reminder that fell due during the sync does not stop the later ones',
      () async {
    final now = DateTime.now();

    await LocalNotificationGateway().replaceAll([
      ScheduledNotification(
          id: 1,
          title: 'Viewing',
          body: 'Starts now',
          at: now.subtract(const Duration(minutes: 1))),
      ScheduledNotification(
          id: 2,
          title: 'Call back',
          body: 'In two hours',
          at: now.add(const Duration(hours: 2))),
    ]);

    expect(scheduled, [2]);
  });
}
