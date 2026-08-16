import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';

/// The last segment of a link the app claims, and where it goes.
///
/// Both forms the backend hands out are listed: the custom scheme its landing
/// pages offer (`estatecrm://accept-invite`, `estatecrm://reset-password`) and
/// the landing URLs themselves (`https://host/api/invite`, `…/api/reset`).
const _targets = {
  'accept-invite': '/accept-invite',
  'invite': '/accept-invite',
  'reset-password': '/reset-password',
  'reset': '/reset-password',
};

/// The in-app location an incoming link should open, or null for a link this
/// app does not claim.
///
/// Matching on the last segment rather than the whole URL means publishing App
/// Links / Universal Links later — which swaps one form for the other — needs
/// no change here.
///
/// A token-less link still resolves: the screen simply opens with an empty
/// field, which is what someone pasting a code by hand needs anyway.
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

/// Hands links the OS delivers to the app over to the router.
///
/// Two things stand between an incoming link and the screen it names, and both
/// are session state, which is why they live here rather than in the router.
///
/// The first is timing: a link can arrive while the saved session is still
/// being read, and the router parks every location on the splash until it is
/// ([resolveRedirect]) — navigating then would be undone a frame later. So the
/// location is held and replayed once [AuthBloc] resolves, which it announces
/// through the [Listenable] the router already refreshes on.
///
/// The second is an occupied session: [resolveRedirect] sends a signed-in user
/// off `/accept-invite` to the dashboard, so an invite tapped by someone
/// already signed in would land nowhere and say nothing. An invite is for one
/// account and the app holds one session, so taking it means giving up the
/// current one — [confirmSignOut] asks first. Confirming signs out, and the
/// same replay that covers the cold start then carries the link through.
class DeepLinkHandler {
  DeepLinkHandler({
    required GoRouter router,
    required AuthBloc auth,
    Stream<Uri>? links,
    Future<bool> Function()? confirmSignOut,
  })  : _router = router,
        _auth = auth,
        _confirmSignOut = confirmSignOut,
        // In app_links 6.x this stream replays the link that cold-started the
        // app before emitting later ones, so there is no separate
        // initial-link call to make.
        _links = links ?? AppLinks().uriLinkStream;

  final GoRouter _router;
  final AuthBloc _auth;
  final Stream<Uri> _links;

  /// Asks whether the live session may be given up for the incoming invite.
  /// Without one there is nobody to ask, so the link waits rather than taking
  /// the session on its own.
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

  /// One prompt at a time: the sign-out this schedules makes [AuthBloc] notify,
  /// and every listener call runs [_flush] again.
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
