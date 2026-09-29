import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/features/app_lock/data/app_lock_repository_impl.dart';
import 'package:real_estate_crm/features/app_lock/data/pin_hasher.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';

import 'fakes.dart';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('PBKDF2-HMAC-SHA256', () {
    // RFC 7914 §11.
    test('matches the published vector, one round, 64 bytes', () {
      expect(
        _hex(pbkdf2HmacSha256(
            utf8.encode('passwd'), utf8.encode('salt'), 1, 64)),
        '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc'
        '49ca9cccf179b645991664b39d77ef317c71b845b1e30bd509112041d3a19783',
      );
    });

    test('matches the published vector, 80 000 rounds', () {
      expect(
        _hex(pbkdf2HmacSha256(
            utf8.encode('Password'), utf8.encode('NaCl'), 80000, 64)),
        '4ddcd8f60b98be21830cee5ef22701f9641a4418d04c0414aeff08876b34ab56'
        'a1d425a1225833549adb841b51c9b3176a272bdebba1d078478f62b397f33c8d',
      );
    });

    test('matches the widely used 4096-round vector', () {
      expect(
        _hex(pbkdf2HmacSha256(
            utf8.encode('password'), utf8.encode('salt'), 4096, 32)),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });
  });

  group('constant-time comparison', () {
    test('equal bytes are equal, anything else is not', () {
      expect(constantTimeEquals([1, 2, 3], [1, 2, 3]), isTrue);
      expect(constantTimeEquals([1, 2, 3], [1, 2, 4]), isFalse);
      expect(constantTimeEquals([1, 2, 3], [1, 2]), isFalse);
      expect(constantTimeEquals([], [0]), isFalse);
      expect(constantTimeEquals([], []), isTrue);
    });

    test('a difference in the first byte is caught as well as the last', () {
      final a = List<int>.filled(32, 7);
      expect(constantTimeEquals(a, [8, ...a.skip(1)]), isFalse);
      expect(constantTimeEquals(a, [...a.take(31), 8]), isFalse);
    });
  });

  group('the repository', () {
    test('keeps a salted hash per user, never the digits', () async {
      final store = FakeSecretStore();
      final repo = fakeAppLockRepository(store);
      final pin = await repo.hash('4821');
      await repo.save(3, AppLockRecord(pin: pin, pinLength: 4));

      expect(store.values.keys, [AppLockRepositoryImpl.keyFor(3)]);
      final raw = store.values.values.single;
      expect(raw, isNot(contains('4821')));
      expect(
          base64Decode(
              (jsonDecode(raw) as Map<String, dynamic>)['salt'] as String),
          hasLength(16));
      expect(await repo.read(4), isNull);
    });

    test('the same PIN twice gets two salts and two hashes', () async {
      final repo = fakeAppLockRepository();
      final a = await repo.hash('4821');
      final b = await repo.hash('4821');
      expect(a.salt, isNot(b.salt));
      expect(a.hash, isNot(b.hash));
    });

    test('verifies the right PIN and refuses a wrong one', () async {
      final repo = fakeAppLockRepository();
      final stored = await repo.hash('482193');
      expect(await repo.matches('482193', stored), isTrue);
      expect(await repo.matches('482194', stored), isFalse);
      expect(await repo.matches('48219', stored), isFalse);
    });

    test('ships with at least 100 000 rounds and survives a round trip',
        () async {
      expect(AppLockRepositoryImpl.defaultIterations,
          greaterThanOrEqualTo(100000));
      final repo = fakeAppLockRepository();
      final record = AppLockRecord(
        pin: await repo.hash('1234'),
        pinLength: 4,
        autoLock: AutoLock.fiveMinutes,
        failures: 6,
        retryAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
      await repo.save(1, record);
      final back = (await repo.read(1))!;
      expect(back.autoLock, AutoLock.fiveMinutes);
      expect(back.failures, 6);
      expect(back.retryAt, record.retryAt);
      expect(await repo.matches('1234', back.pin), isTrue);
    });

    test('an unreadable record reads as no lock rather than a crash', () {
      expect(AppLockRecord.decode('not json'), isNull);
      expect(AppLockRecord.decode(null), isNull);
    });
  });
}
