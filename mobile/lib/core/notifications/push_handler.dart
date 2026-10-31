import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/navigation/active_tab.dart';
import 'package:real_estate_crm/core/notifications/push_gateway.dart';
import 'package:real_estate_crm/core/utils/launch_gate.dart';
import 'package:real_estate_crm/core/utils/router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> pushTopics({String? language, Role? role}) => [
      'all',
      if (language != null) 'lang_$language',
      if (role != null) 'role_${role.name.toLowerCase()}',
    ];

class PushHandler {
  PushHandler({
    required PushGateway gateway,
    required AuthBloc auth,
    required void Function(String route) openRoute,
    required void Function(Uri link) openLink,
    required void Function(PushMessage message) showInApp,
    LaunchGate? gate,
  })  : _gateway = gateway,
        _auth = auth,
        _openRoute = openRoute,
        _openLink = openLink,
        _showInApp = showInApp,
        _gate = gate;

  static const topicsKey = 'push_topics';

  final PushGateway _gateway;
  final AuthBloc _auth;
  final void Function(String route) _openRoute;
  final void Function(Uri link) _openLink;
  final void Function(PushMessage message) _showInApp;
  final LaunchGate? _gate;

  final List<StreamSubscription<PushMessage>> _subscriptions = [];
  Set<String>? _topics;
  String? _language;
  PushMessage? _pending;
  bool _asked = false;
  bool _syncing = false;
  bool _again = false;
  bool _disposed = false;

  Future<void> start() async {
    _auth.addListener(_onAuthChanged);
    _gate?.addListener(_flush);
    _listen(() => _gateway.received, _onReceived);
    _listen(() => _gateway.opened, open);
    try {
      final launch = await _gateway.launchMessage();
      if (launch != null) open(launch);
    } catch (error) {
      debugPrint('[push] launch message unavailable: $error');
    }
    _onAuthChanged();
  }

  void setLanguage(String language) {
    if (_disposed || _language == language) return;
    _language = language;
    unawaited(_sync());
  }

  void open(PushMessage message) {
    if (_disposed || (message.route == null && message.link == null)) return;
    _pending = message;
    _flush();
  }

  void _listen(Stream<PushMessage> Function() stream,
      void Function(PushMessage message) onData) {
    try {
      _subscriptions.add(stream().listen(onData, onError: (Object error) {
        debugPrint('[push] stream failed: $error');
      }));
    } catch (error) {
      debugPrint('[push] stream unavailable: $error');
    }
  }

  void _onReceived(PushMessage message) {
    if (!_disposed && message.hasText) _showInApp(message);
  }

  void _onAuthChanged() {
    unawaited(_sync());
    _flush();
  }

  void _flush() {
    final message = _pending;
    if (_disposed || message == null || !_auth.isSessionResolved) return;
    if (!(_gate?.isOpen ?? true)) return;
    _pending = null;
    final link = message.link;
    if (link != null) {
      _openLink(link);
      return;
    }
    final route = message.route;
    if (route != null && _auth.isAuthenticated) _openRoute(route);
  }

  Future<void> _sync() async {
    if (_disposed || _language == null || !_auth.isSessionResolved) return;
    if (_syncing) {
      _again = true;
      return;
    }
    _syncing = true;
    try {
      final user = _auth.currentUser;
      if (user != null && !_asked && await _gateway.canDeliver()) {
        _asked = true;
        await _gateway.requestPermission();
        await _logToken();
      }
      final topics = _topics ??= await _loadTopics();
      final wanted = pushTopics(language: _language, role: user?.role).toSet();
      for (final topic in wanted.difference(topics)) {
        await _gateway.subscribe(topic);
        topics.add(topic);
        await _saveTopics(topics);
      }
      for (final topic in topics.difference(wanted)) {
        await _gateway.unsubscribe(topic);
        topics.remove(topic);
        await _saveTopics(topics);
      }
    } catch (error) {
      debugPrint('[push] topics not updated: $error');
    } finally {
      _syncing = false;
      if (_again && !_disposed) {
        _again = false;
        unawaited(_sync());
      }
    }
  }

  Future<void> _logToken() async {
    if (!kDebugMode) return;
    try {
      debugPrint('[push] FCM token: ${await _gateway.token()}');
    } catch (error) {
      debugPrint('[push] no FCM token: $error');
    }
  }

  static Future<Set<String>> _loadTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(topicsKey) ?? const <String>[]).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> _saveTopics(Set<String> topics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(topicsKey, topics.toList()..sort());
    } catch (_) {}
  }

  Future<void> dispose() async {
    _disposed = true;
    _auth.removeListener(_onAuthChanged);
    _gate?.removeListener(_flush);
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}

Future<void> openPushRoute(GoRouter router, String route) async {
  await WidgetsBinding.instance.endOfFrame;
  final path = Uri.tryParse(route)?.path ?? route;
  if (ShellTabs.routes.contains(path)) {
    router.go(route);
  } else {
    unawaited(router.push<Object?>(route));
  }
}

void showPushBanner(PushMessage message, {VoidCallback? onOpen}) {
  final context = rootNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final l10n = AppLocalizations.of(context);
  final title = message.title?.trim() ?? '';
  final body = message.body?.trim() ?? '';
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      key: const ValueKey('push-banner'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          if (body.isNotEmpty)
            Text(body, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
      action: onOpen == null
          ? null
          : SnackBarAction(
              key: const ValueKey('push-banner-open'),
              label: l10n.coreOpen,
              onPressed: onOpen,
            ),
    ));
}

class PushLanguage extends StatefulWidget {
  final PushHandler handler;
  final Widget child;

  const PushLanguage({super.key, required this.handler, required this.child});

  @override
  State<PushLanguage> createState() => _PushLanguageState();
}

class _PushLanguageState extends State<PushLanguage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.maybeLocaleOf(context)?.languageCode;
    if (language != null) widget.handler.setLanguage(language);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
