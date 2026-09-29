import 'dart:convert';

/// How long the app may sit in the background before it asks for the PIN.
enum AutoLock {
  immediately(Duration.zero),
  oneMinute(Duration(minutes: 1)),
  fiveMinutes(Duration(minutes: 5)),
  fifteenMinutes(Duration(minutes: 15));

  const AutoLock(this.after);
  final Duration after;

  static AutoLock parse(String? name) => AutoLock.values.firstWhere(
        (a) => a.name == name,
        orElse: () => AutoLock.immediately,
      );
}

/// A PIN as it is kept: never the digits, only a salted PBKDF2 of them.
class PinHash {
  final List<int> salt;
  final List<int> hash;
  final int iterations;

  const PinHash({
    required this.salt,
    required this.hash,
    required this.iterations,
  });
}

/// One user's lock on this device, with the wrong guesses made against it.
class AppLockRecord {
  final PinHash pin;
  final int pinLength;
  final AutoLock autoLock;
  final int failures;
  final DateTime? retryAt;

  const AppLockRecord({
    required this.pin,
    required this.pinLength,
    this.autoLock = AutoLock.immediately,
    this.failures = 0,
    this.retryAt,
  });

  AppLockRecord copyWith({
    PinHash? pin,
    int? pinLength,
    AutoLock? autoLock,
    int? failures,
    DateTime? Function()? retryAt,
  }) =>
      AppLockRecord(
        pin: pin ?? this.pin,
        pinLength: pinLength ?? this.pinLength,
        autoLock: autoLock ?? this.autoLock,
        failures: failures ?? this.failures,
        retryAt: retryAt != null ? retryAt() : this.retryAt,
      );

  String encode() => jsonEncode({
        'v': 1,
        'salt': base64Encode(pin.salt),
        'hash': base64Encode(pin.hash),
        'iter': pin.iterations,
        'len': pinLength,
        'auto': autoLock.name,
        'fails': failures,
        if (retryAt != null) 'until': retryAt!.millisecondsSinceEpoch,
      });

  static AppLockRecord? decode(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final until = m['until'] as int?;
      return AppLockRecord(
        pin: PinHash(
          salt: base64Decode(m['salt'] as String),
          hash: base64Decode(m['hash'] as String),
          iterations: m['iter'] as int,
        ),
        pinLength: m['len'] as int,
        autoLock: AutoLock.parse(m['auto'] as String?),
        failures: m['fails'] as int? ?? 0,
        retryAt:
            until == null ? null : DateTime.fromMillisecondsSinceEpoch(until),
      );
    } catch (_) {
      return null;
    }
  }
}
