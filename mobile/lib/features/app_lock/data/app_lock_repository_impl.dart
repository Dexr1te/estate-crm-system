import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:real_estate_crm/features/app_lock/data/pin_hasher.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_models.dart';
import 'package:real_estate_crm/features/app_lock/domain/app_lock_repository.dart';

/// The few calls the lock makes on the keychain, so tests can hand it memory.
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class DeviceSecretStore implements SecretStore {
  const DeviceSecretStore(
      [this._storage = const FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      )]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class AppLockRepositoryImpl implements AppLockRepository {
  AppLockRepositoryImpl({
    this.store = const DeviceSecretStore(),
    this.iterations = defaultIterations,
    this.inBackground = true,
    Random? random,
  }) : _random = random ?? Random.secure();

  /// OWASP's 2023 floor for PBKDF2-HMAC-SHA256 is 600k; a phone that has to
  /// answer a PIN pad in well under a second settles for a sixth of that, with
  /// the retry delays doing the rest.
  static const defaultIterations = 120000;
  static const _saltLength = 16;
  static const _hashLength = 32;

  final SecretStore store;
  final int iterations;
  final bool inBackground;
  final Random _random;

  static String keyFor(int userId) => 'app_lock.v1.u$userId';

  @override
  Future<AppLockRecord?> read(int userId) async =>
      AppLockRecord.decode(await store.read(keyFor(userId)));

  @override
  Future<void> save(int userId, AppLockRecord record) =>
      store.write(keyFor(userId), record.encode());

  @override
  Future<void> delete(int userId) => store.delete(keyFor(userId));

  @override
  Future<PinHash> hash(String pin) async {
    final salt = List<int>.generate(_saltLength, (_) => _random.nextInt(256));
    return PinHash(
      salt: salt,
      hash: await _derive(pin, salt, iterations),
      iterations: iterations,
    );
  }

  @override
  Future<bool> matches(String pin, PinHash stored) async {
    final candidate = await _derive(pin, stored.salt, stored.iterations);
    return constantTimeEquals(candidate, stored.hash);
  }

  Future<List<int>> _derive(String pin, List<int> salt, int rounds) {
    final password = utf8.encode(pin);
    List<int> run() => pbkdf2HmacSha256(password, salt, rounds, _hashLength);
    return inBackground ? Isolate.run(run) : Future.value(run());
  }
}
