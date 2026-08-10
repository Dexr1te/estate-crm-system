import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';

/// The last segment of a link that means "accept an invite": the host of the
/// custom scheme, or the final path segment of the landing URL.
const _inviteTargets = {'accept-invite', 'invite'};

/// The in-app location an incoming link should open, or null for a link this
/// app does not claim.
///
/// Accepts both forms the backend can hand out: the custom scheme its invite
/// landing page offers (`estatecrm://accept-invite?token=…`, see
/// `app.invite-deep-link`) and the landing URL itself
/// (`https://host/api/invite?token=…`, see `app.invite-url`). Matching on the
/// last segment rather than the whole URL means publishing App Links /
/// Universal Links later — which swaps one form for the other — needs no
/// change here.
///
/// A token-less invite link still resolves: the screen simply opens with an
/// empty field, which is what someone pasting a code by hand needs anyway.
String? resolveDeepLink(Uri uri) {
  final custom = uri.scheme != 'http' && uri.scheme != 'https';
  final segments = [
    if (custom) uri.host,
    ...uri.pathSegments,
  ].where((s) => s.isNotEmpty).toList();

  if (segments.isEmpty) return null;
  if (!_inviteTargets.contains(segments.last)) return null;

  final token = uri.queryParameters['token']?.trim() ?? '';
  if (token.isEmpty) return '/accept-invite';
  return Uri(path: '/accept-invite', queryParameters: {'token': token})
      .toString();
}

/// Hands links the OS delivers to the app over to the router.
///
/// The one subtlety is timing: a link can arrive while the saved session is
/// still being read, and the router parks every location on the splash until
/// it is ([resolveRedirect]) — navigating then would be undone a frame later.
/// So the location is held and replayed once [AuthBloc] resolves, which it
/// announces through the [Listenable] the router already refreshes on.
class DeepLinkHandler {
  DeepLinkHandler({
    required GoRouter router,
    required AuthBloc auth,
    Stream<Uri>? links,
  })  : _router = router,
        _auth = auth,
        // In app_links 6.x this stream replays the link that cold-started the
        // app before emitting later ones, so there is no separate
        // initial-link call to make.
        _links = links ?? AppLinks().uriLinkStream;

  final GoRouter _router;
  final AuthBloc _auth;
  final Stream<Uri> _links;

  StreamSubscription<Uri>? _sub;
  String? _pending;

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
    _pending = null;
    _router.go(location);
  }

  void dispose() {
    _auth.removeListener(_flush);
    _sub?.cancel();
  }
}
