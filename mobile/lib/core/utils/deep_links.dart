import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';

const _targets = {
  'accept-invite': '/accept-invite',
  'invite': '/accept-invite',
  'reset-password': '/reset-password',
  'reset': '/reset-password',
};

String? resolveDeepLink(Uri uri) {
  final custom = uri.scheme != 'http' && uri.scheme != 'https';
  final segments = [
    if (custom) uri.host,
    ...uri.pathSegments,
  ].where((s) => s.isNotEmpty).toList();

  if (segments.isEmpty) return null;
  final path = _targets[segments.last];
  if (path == null) return null;

  final token = uri.queryParameters['token']?.trim() ?? '';
  if (token.isEmpty) return path;
  return Uri(path: path, queryParameters: {'token': token}).toString();
}

class DeepLinkHandler {
  DeepLinkHandler({
    required GoRouter router,
    required AuthBloc auth,
    Stream<Uri>? links,
    Future<bool> Function()? confirmSignOut,
  })  : _router = router,
        _auth = auth,
        _confirmSignOut = confirmSignOut,
        _links = links ?? AppLinks().uriLinkStream;

  final GoRouter _router;
  final AuthBloc _auth;
  final Stream<Uri> _links;

  final Future<bool> Function()? _confirmSignOut;

  StreamSubscription<Uri>? _sub;
  String? _pending;
  bool _asking = false;
  bool _disposed = false;

  void start() {
    _auth.addListener(_flush);
    _sub = _links.listen(_onLink, onError: (_) {});
  }

  void _onLink(Uri uri) {
    final location = resolveDeepLink(uri);
    if (location == null) return;
    _pending = location;
    _flush();
  }

  void _flush() {
    final location = _pending;
    if (location == null || !_auth.isSessionResolved) return;
    if (_auth.isAuthenticated) {
      _askToSignOut();
      return;
    }
    _pending = null;
    _router.go(location);
  }

  Future<void> _askToSignOut() async {
    final confirm = _confirmSignOut;
    if (_asking || confirm == null) return;
    _asking = true;
    try {
      final signOut = await confirm();
      if (_disposed) return;
      if (signOut) {
        if (!_auth.isClosed) _auth.add(AuthLogoutEvent());
      } else {
        _pending = null;
      }
    } finally {
      _asking = false;
    }
  }

  void dispose() {
    _disposed = true;
    _auth.removeListener(_flush);
    _sub?.cancel();
  }
}
