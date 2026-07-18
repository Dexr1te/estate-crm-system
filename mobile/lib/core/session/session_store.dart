import 'package:real_estate_crm/core/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds auth tokens in memory and persists the session to [SharedPreferences].
///
/// This is infrastructure shared by the network layer (the refresh interceptor
/// reads/writes tokens here) and the auth feature (login/logout persist here).
class SessionStore {
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _accessToken != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> save(AuthResponse auth) async {
    _accessToken = auth.accessToken;
    _refreshToken = auth.refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', auth.accessToken);
    await prefs.setString('refresh_token', auth.refreshToken);
    await prefs.setString('auth_user', _encodeAuthUser(auth));
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('auth_user');
  }

  Future<AuthResponse?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('auth_user');
    if (data == null) return null;
    try {
      return AuthResponse.fromJson(_decodeAuthUser(data));
    } catch (_) {
      return null;
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
