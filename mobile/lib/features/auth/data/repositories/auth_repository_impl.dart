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
  Future<void> logout() => _session.clear();

  @override
  Future<AuthResponse?> getSavedUser() => _session.getSavedUser();

  @override
  bool get isLoggedIn => _session.isLoggedIn;
}
