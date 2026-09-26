import 'package:flutter/widgets.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';

/// A contact that was started from the app and has not been written down yet.
class PendingContact {
  final int clientId;
  final ActivityType type;
  final DateTime startedAt;
  final bool left;

  const PendingContact({
    required this.clientId,
    required this.type,
    required this.startedAt,
    this.left = false,
  });

  PendingContact leaving() => PendingContact(
      clientId: clientId, type: type, startedAt: startedAt, left: true);
}

/// Notices the agent coming back from a call or an email they started here,
/// so the screen can offer to log it while it is still fresh.
///
/// The rules keep the offer from turning into noise:
/// * it is made once — the pending contact is spent the moment it is offered;
/// * only if the agent actually left the app ([AppLifecycleState.hidden] or
///   [AppLifecycleState.paused]) — a system "Call?" alert that was cancelled
///   only makes the app inactive, and must not count;
/// * only if they left within [leaveWindow] of the tap — otherwise the dialer
///   never opened, and some later, unrelated trip out of the app would be
///   mistaken for the call;
/// * only if they came back within [timeout] — a prompt about a call from an
///   hour ago, on returning from lunch, is more puzzling than useful.
///
/// Feed it lifecycle changes with [didChangeAppLifecycleState] — as a
/// [WidgetsBindingObserver], or by hand in a test — and read the time from
/// [now], which defaults to [AppClock].
class ContactFollowUp with WidgetsBindingObserver {
  ContactFollowUp({
    required this.onReturn,
    DateTime Function()? now,
    this.leaveWindow = const Duration(minutes: 1),
    this.timeout = const Duration(minutes: 30),
  }) : _now = now ?? AppClock.now;

  /// Called once, on coming back, with the contact to offer for logging.
  final ValueChanged<PendingContact> onReturn;
  final DateTime Function() _now;
  final Duration leaveWindow;
  final Duration timeout;

  PendingContact? _pending;
  bool _attached = false;

  PendingContact? get pending => _pending;

  /// Starts listening to the app's lifecycle. Pair with [detach].
  void attach() {
    if (_attached) return;
    WidgetsBinding.instance.addObserver(this);
    _attached = true;
  }

  void detach() {
    if (!_attached) return;
    WidgetsBinding.instance.removeObserver(this);
    _attached = false;
  }

  /// The agent has just tapped Call or Email for [clientId]. A newer contact
  /// replaces an older one that was never followed up.
  void begin(int clientId, ActivityType type) {
    _pending =
        PendingContact(clientId: clientId, type: type, startedAt: _now());
  }

  void cancel() => _pending = null;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final pending = _pending;
    if (pending == null) return;
    final elapsed = _now().difference(pending.startedAt);

    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (pending.left) return;
        if (elapsed > leaveWindow) {
          _pending = null;
        } else {
          _pending = pending.leaving();
        }
      case AppLifecycleState.resumed:
        if (!pending.left) {
          if (elapsed > leaveWindow) _pending = null;
          return;
        }
        _pending = null;
        if (elapsed <= timeout) onReturn(pending);
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }
}
