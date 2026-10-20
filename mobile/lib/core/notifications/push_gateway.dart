import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushMessage {
  final String? title;
  final String? body;
  final Map<String, String> data;

  const PushMessage({this.title, this.body, this.data = const {}});

  factory PushMessage.fromRemote(RemoteMessage message) => PushMessage(
        title: message.notification?.title,
        body: message.notification?.body,
        data: {
          for (final entry in message.data.entries)
            if (entry.value != null) entry.key: '${entry.value}',
        },
      );

  String? get route {
    final value = data['route']?.trim() ?? '';
    if (!value.startsWith('/') || value.startsWith('//')) return null;
    return value;
  }

  Uri? get link {
    final uri = Uri.tryParse(data['url']?.trim() ?? '');
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri;
  }

  bool get hasText =>
      (title?.trim().isNotEmpty ?? false) || (body?.trim().isNotEmpty ?? false);
}

abstract class PushGateway {
  Future<bool> requestPermission();

  Future<String?> token();

  Future<void> subscribe(String topic);

  Future<void> unsubscribe(String topic);

  Stream<PushMessage> get received;

  Stream<PushMessage> get opened;

  Future<PushMessage?> launchMessage();
}

class FirebasePushGateway implements PushGateway {
  FirebasePushGateway([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const androidChannelId = 'activity';

  final FlutterLocalNotificationsPlugin _plugin;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    await _createAndroidChannel();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _createAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      androidChannelId,
      'Activity',
      description: 'News and updates from EstateCRM',
      importance: Importance.high,
    ));
  }

  @override
  Future<String?> token() async {
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        await _messaging.getAPNSToken() == null) {
      return null;
    }
    return _messaging.getToken();
  }

  @override
  Future<void> subscribe(String topic) => _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribe(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  @override
  Stream<PushMessage> get received =>
      FirebaseMessaging.onMessage.map(PushMessage.fromRemote);

  @override
  Stream<PushMessage> get opened =>
      FirebaseMessaging.onMessageOpenedApp.map(PushMessage.fromRemote);

  @override
  Future<PushMessage?> launchMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : PushMessage.fromRemote(message);
  }
}
