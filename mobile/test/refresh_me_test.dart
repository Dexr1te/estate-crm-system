import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:real_estate_crm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `/auth/me` that answers only when told to, the way a waking host does.
class _SlowMe extends AuthRemoteDataSource {
  _SlowMe(super.client);

  final reply = Completer<AuthResponse>();

  @override
  Future<AuthResponse> me() => reply.future;
}

const _maria = AuthResponse(
  userId: 5,
  fullName: 'Maria Kim',
  email: 'maria@x.kz',
  role: Role.AGENT,
  accessToken: 'access-maria',
  refreshToken: 'refresh-maria',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionStore session;
  late _SlowMe remote;
  late AuthRepositoryImpl repo;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    session = SessionStore();
    await session.load();
    remote = _SlowMe(ApiClient(session));
    repo = AuthRepositoryImpl(remote, session);
    await session.save(_maria);
  });

  // The profile read fired at sign-in can take a minute on a sleeping host.
  // Signing out meanwhile, then its answer landing, saved the profile with
  // the empty tokens /auth/me carries -- and the app was signed in again.
  test('an answer that lands after signing out does not sign back in',
      () async {
    final refresh = repo.refreshMe();
    await session.clear();
    remote.reply.complete(_maria.copyWith(
        fullName: 'Maria K.', accessToken: '', refreshToken: ''));

    await expectLater(refresh, throwsStateError);
    expect(await session.getSavedUser(), isNull);
    expect(session.accessToken, isNull);
  });

  test("nor does it put one person's profile on another's session", () async {
    final refresh = repo.refreshMe();
    const aigerim = AuthResponse(
        userId: 6,
        fullName: 'Aigerim',
        role: Role.AGENT,
        accessToken: 'access-aigerim',
        refreshToken: 'refresh-aigerim');
    await session.save(aigerim);
    remote.reply.complete(_maria);

    await expectLater(refresh, throwsStateError);
    expect((await session.getSavedUser())?.userId, 6);
  });

  test('an answer for the same session is merged in', () async {
    final refresh = repo.refreshMe();
    remote.reply.complete(_maria.copyWith(
        fullName: 'Maria Kim-Doroshenko', accessToken: '', refreshToken: ''));

    final merged = await refresh;
    expect(merged.fullName, 'Maria Kim-Doroshenko');
    expect(merged.accessToken, 'access-maria',
        reason: '/auth/me carries no token; the saved one is kept');
  });
}
