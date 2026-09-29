import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/launch_gate.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_repository.dart';

enum PinCheck { accepted, wrong, throttled }

/// Whether the app is locked, covered, or open — for whoever is signed in.
///
/// It locks on a cold start that restores a session, and on coming back from
/// the background once the chosen time has passed. Wrong guesses are kept
/// with the PIN, so killing the app does not reset the count.
class AppLockController extends ChangeNotifier implements LaunchGate {
  AppLockController({
    required AppLockRepository repository,
    DateTime Function()? now,
  })  : _repo = repository,
        _now = now ?? AppClock.now;

  static const minPinLength = 4;
  static const maxPinLength = 6;
  static const throttleAfter = 5;
  static const signOutAfter = 10;
  static const _delays = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  final AppLockRepository _repo;
  final DateTime Function() _now;

  /// Ends the session the way the profile's Sign out does, which also wipes
  /// the offline cache.
  Future<void> Function()? onSignOut;

  bool _attached = false;
  bool _resolving = false;
  int? _userId;
  int _generation = 0;
  AppLockRecord? _record;
  bool _locked = false;
  bool _backgrounded = false;
  DateTime? _hiddenAt;
  bool _checking = false;

  bool get enabled => _record != null;
  bool get isLocked => _locked;
  AutoLock get autoLock => _record?.autoLock ?? AutoLock.immediately;
  int get pinLength => _record?.pinLength ?? maxPinLength;
  int get failures => _record?.failures ?? 0;
  bool get canSignOut => failures >= signOutAfter;

  /// Hides the app while it is in the switcher, and while the lock for a
  /// just-restored session is still being read.
  bool get isCovered => !_locked && ((_backgrounded && enabled) || _resolving);

  @override
  bool get isOpen => _attached && !_resolving && !_locked;

  Duration? get retryIn {
    final at = _record?.retryAt;
    if (at == null) return null;
    final left = at.difference(_now());
    return left > Duration.zero ? left : null;
  }

  static Duration? delayAfter(int failures) {
    if (failures < throttleAfter) return null;
    final i = failures - throttleAfter;
    return _delays[i < _delays.length ? i : _delays.length - 1];
  }

  /// Follows the signed-in user. A user who leaves — signs out, or hands the
  /// phone to another account — takes their PIN with them.
  Future<void> attach(int? userId) async {
    if (_attached && userId == _userId) return;
    final coldStart = !_attached;
    final previous = _userId;
    final generation = ++_generation;
    _attached = true;
    _userId = userId;
    _record = null;
    _locked = false;
    _hiddenAt = null;
    _resolving = userId != null;
    notifyListeners();

    if (previous != null) await _forget(previous);
    if (userId == null) return;

    AppLockRecord? record;
    try {
      record = await _repo.read(userId);
    } catch (_) {}
    if (generation != _generation) return;
    _record = record;
    _resolving = false;
    _locked = coldStart && record != null;
    notifyListeners();
  }

  void lifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        _cover();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _hiddenAt ??= _now();
        _cover();
      case AppLifecycleState.resumed:
        final since = _hiddenAt;
        _hiddenAt = null;
        _backgrounded = false;
        final record = _record;
        if (record != null &&
            since != null &&
            _now().difference(since) >= record.autoLock.after) {
          _locked = true;
        }
        notifyListeners();
      case AppLifecycleState.detached:
        break;
    }
  }

  void _cover() {
    if (_backgrounded) return;
    _backgrounded = true;
    notifyListeners();
  }

  Future<PinCheck> unlock(String pin) async {
    final result = await _check(pin);
    if (result == PinCheck.accepted && _locked) {
      _locked = false;
      notifyListeners();
    }
    return result;
  }

  /// Checks the PIN without unlocking anything — the first step of changing
  /// or removing it. A wrong one counts like one on the lock screen.
  Future<PinCheck> verify(String pin) => _check(pin);

  Future<void> enable(String pin, AutoLock autoLock) async {
    final user = _userId;
    if (user == null) return;
    final record = AppLockRecord(
      pin: await _repo.hash(pin),
      pinLength: pin.length,
      autoLock: autoLock,
    );
    await _repo.save(user, record);
    if (user != _userId) return;
    _record = record;
    notifyListeners();
  }

  Future<PinCheck> changePin(String current, String next) async {
    final result = await _check(current);
    if (result != PinCheck.accepted) return result;
    final user = _userId;
    final record = _record;
    if (user == null || record == null) return PinCheck.wrong;
    final updated =
        record.copyWith(pin: await _repo.hash(next), pinLength: next.length);
    await _repo.save(user, updated);
    _record = updated;
    notifyListeners();
    return result;
  }

  Future<PinCheck> disable(String current) async {
    final result = await _check(current);
    if (result != PinCheck.accepted) return result;
    final user = _userId;
    if (user != null) await _forget(user);
    _record = null;
    notifyListeners();
    return result;
  }

  Future<void> setAutoLock(AutoLock value) async {
    final user = _userId;
    final record = _record;
    if (user == null || record == null) return;
    _record = record.copyWith(autoLock: value);
    notifyListeners();
    await _repo.save(user, _record!);
  }

  /// "Forgot PIN" and the way out after too many wrong ones: the PIN goes,
  /// then the session and the offline cache. The lock stays up until the
  /// session has actually ended.
  Future<void> signOut() async {
    final user = _userId;
    if (user != null) await _forget(user);
    _record = null;
    await onSignOut?.call();
  }

  Future<PinCheck> _check(String pin) async {
    final user = _userId;
    final record = _record;
    if (user == null || record == null) return PinCheck.wrong;
    if (_checking || retryIn != null) return PinCheck.throttled;

    _checking = true;
    bool ok;
    try {
      ok = await _repo.matches(pin, record.pin);
    } finally {
      _checking = false;
    }
    if (user != _userId || _record == null) return PinCheck.wrong;

    if (ok) {
      if (record.failures > 0) {
        _record = record.copyWith(failures: 0, retryAt: () => null);
        await _repo.save(user, _record!);
      }
      return PinCheck.accepted;
    }

    final failures = record.failures + 1;
    final delay = delayAfter(failures);
    _record = record.copyWith(
      failures: failures,
      retryAt: () => delay == null ? null : _now().add(delay),
    );
    notifyListeners();
    await _repo.save(user, _record!);
    return PinCheck.wrong;
  }

  Future<void> _forget(int userId) async {
    try {
      await _repo.delete(userId);
    } catch (_) {}
  }
}
