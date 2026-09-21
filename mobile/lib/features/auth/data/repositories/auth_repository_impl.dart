import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:real_estate_crm/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SessionStore _session;
  AuthRepositoryImpl(this._remote, this._session);

  @override
  Future<AuthResponse> login(String email, String password) async {
    final auth = await _remote.login(email, password);
    await _session.save(auth);
    return auth;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required Role role,
    String? phone,
  }) =>
      _remote.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

  @override
  Future<AuthResponse> verifyEmail(String email, String code) async {
    final auth = await _remote.verifyEmail(email, code);
    await _session.save(auth);
    return auth;
  }

  @override
  Future<void> resendVerification(String email) =>
      _remote.resendVerification(email);

  @override
  Future<AuthResponse> refreshMe() async {
    final fresh = await _remote.me();
    final saved = await _session.getSavedUser();

    final merged = fresh.copyWith(
      accessToken: saved?.accessToken ?? fresh.accessToken,
      refreshToken: saved?.refreshToken ?? fresh.refreshToken,
    );
    await _session.save(merged);
    return merged;
  }

  @override
  Future<AuthResponse> acceptInvite(String token, String newPassword) async {
    final auth = await _remote.acceptInvite(token, newPassword);
    await _session.save(auth);
    return auth;
  }

  @override
  Future<AuthResponse> updateProfile(String fullName, String email) async {
    final auth = await _remote.updateProfile(fullName, email);
    await _session.save(auth);
    return auth;
  }

  @override
  Future<void> requestPasswordReset(String email) =>
      _remote.requestPasswordReset(email);

  @override
  Future<AuthResponse> resetPassword(String token, String newPassword) async {
    final auth = await _remote.resetPassword(token, newPassword);
    await _session.save(auth);
    return auth;
  }

  @override
  Future<void> logout() => _session.clear();

  @override
  Future<void> deleteAccount({int? replacementId}) async {
    await _remote.deleteAccount(replacementId: replacementId);

    await _session.clear();
  }

  @override
  Future<AuthResponse?> getSavedUser() => _session.getSavedUser();

  @override
  bool get isLoggedIn => _session.isLoggedIn;
}
