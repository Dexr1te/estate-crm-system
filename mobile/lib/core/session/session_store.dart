import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'auth_user';
  static const _legacyKeys = [_accessKey, _refreshKey, _userKey];

  /// The team's currency, kept apart from the user line so that line (and the
  /// cache scope read from it) stays as earlier builds wrote it.
  static const _currencyKey = 'auth_currency';

  final FlutterSecureStorage _storage;

  SessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(iOptions: _ios);

  static const _ios =
      IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  String? _accessToken;
  String? _refreshToken;
  String? _user;
  String? _currency;

  final List<Future<void> Function()> _clearListeners = [];

  /// Called whenever the session ends or passes to a different account, so
  /// whatever was kept for the old one can be forgotten.
  void addClearListener(Future<void> Function() listener) =>
      _clearListeners.add(listener);

  Future<void> _notifyCleared() async {
    for (final listener in List.of(_clearListeners)) {
      try {
        await listener();
      } catch (_) {}
    }
  }

  /// Who the data on this device belongs to — user and team — or null when
  /// nobody is signed in. Anything cached is keyed by it.
  String? get cacheScope {
    final user = _user;
    if (_accessToken == null || user == null) return null;
    final parts = user.split('|');
    final team = parts.length > 4 && parts.last.isNotEmpty ? parts.last : '-';
    return 'u${parts[0]}:t$team';
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _accessToken != null;

  Future<void> load() async {
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
    _user = await _storage.read(key: _userKey);
    _currency = await _storage.read(key: _currencyKey);

    if (_accessToken == null) await _migrateFromPreferences();
  }

  Future<void> save(AuthResponse auth) async {
    final previous = _user?.split('|').first;
    if (previous != null && previous != '${auth.userId}') {
      await _notifyCleared();
    }
    _accessToken = auth.accessToken;
    _refreshToken = auth.refreshToken;
    _user = _encodeAuthUser(auth);
    _currency = auth.teamCurrency;

    await _storage.write(key: _accessKey, value: _accessToken);
    await _storage.write(key: _refreshKey, value: _refreshToken);
    await _storage.write(key: _userKey, value: _user);
    await _storage.write(key: _currencyKey, value: _currency);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _currency = null;

    for (final key in [..._legacyKeys, _currencyKey]) {
      await _storage.delete(key: key);
    }
    await _notifyCleared();
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
    } catch (_) {}
  }

  String _encodeAuthUser(AuthResponse auth) {
    return '${auth.userId}|${auth.fullName}|${auth.email}|${auth.role.name}'
        '|${auth.teamId ?? ''}';
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
      'teamId': parts.length > 4 ? int.tryParse(parts.last) : null,
      'teamCurrency': _currency,
    };
  }
}
