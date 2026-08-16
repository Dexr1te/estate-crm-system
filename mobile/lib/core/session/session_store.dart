import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the signed-in session lives between launches.
///
/// The tokens are a credential, so they belong in the Keychain — and in
/// Android's keystore-backed store — rather than in SharedPreferences, which on
/// iOS is a plain plist inside the app container and rides along in unencrypted
/// device backups. Builds up to 1.0.0 wrote them to SharedPreferences, so
/// [load] moves anything it finds there and wipes the old copy; nobody is
/// signed out by updating.
class SessionStore {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'auth_user';
  static const _legacyKeys = [_accessKey, _refreshKey, _userKey];

  final FlutterSecureStorage _storage;

  SessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(iOptions: _ios);

  /// The default keychain accessibility only unlocks while the screen is
  /// unlocked, which loses the session to a token refresh that happens with the
  /// phone in a pocket. After the first unlock since boot is the right line.
  static const _ios =
      IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  String? _accessToken;
  String? _refreshToken;
  String? _user;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _accessToken != null;

  Future<void> load() async {
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
    _user = await _storage.read(key: _userKey);

    if (_accessToken == null) await _migrateFromPreferences();
  }

  Future<void> save(AuthResponse auth) async {
    _accessToken = auth.accessToken;
    _refreshToken = auth.refreshToken;
    _user = _encodeAuthUser(auth);

    await _storage.write(key: _accessKey, value: _accessToken);
    await _storage.write(key: _refreshKey, value: _refreshToken);
    await _storage.write(key: _userKey, value: _user);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;

    for (final key in _legacyKeys) {
      await _storage.delete(key: key);
    }
  }

  Future<AuthResponse?> getSavedUser() async {
    final data = _user;
    if (data == null) return null;
    try {
      return AuthResponse.fromJson(_decodeAuthUser(data));
    } catch (_) {
      return null;
    }
  }

  /// Carries a session written by an earlier build over to secure storage, then
  /// removes the plaintext original. Best effort: a session that cannot be
  /// moved is not worth blocking the launch for, and the worst case is one
  /// sign-in.
  Future<void> _migrateFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final legacyAccess = prefs.getString(_accessKey);
      if (legacyAccess == null) return;

      _accessToken = legacyAccess;
      _refreshToken = prefs.getString(_refreshKey);
      _user = prefs.getString(_userKey);

      await _storage.write(key: _accessKey, value: _accessToken);
      if (_refreshToken != null) {
        await _storage.write(key: _refreshKey, value: _refreshToken);
      }
      if (_user != null) await _storage.write(key: _userKey, value: _user);

      for (final key in _legacyKeys) {
        await prefs.remove(key);
      }
    } catch (_) {
      // Leave the tokens where they are; the next launch tries again.
    }
  }

  String _encodeAuthUser(AuthResponse auth) {
    return '${auth.userId}|${auth.fullName}|${auth.email}|${auth.role.name}';
  }

  Map<String, dynamic> _decodeAuthUser(String data) {
    final parts = data.split('|');
    return {
      'accessToken': _accessToken ?? '',
      'refreshToken': _refreshToken ?? '',
      'tokenType': 'Bearer',
      'userId': int.tryParse(parts[0]) ?? 0,
      'fullName': parts.length > 1 ? parts[1] : '',
      'email': parts.length > 2 ? parts[2] : '',
      'role': parts.length > 3 ? parts[3] : 'AGENT',
    };
  }
}
