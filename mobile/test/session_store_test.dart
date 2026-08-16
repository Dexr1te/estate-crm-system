import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _auth = AuthResponse(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  userId: 7,
  fullName: 'Aisha Karimova',
  email: 'aisha@estatecrm.kz',
  role: Role.AGENT,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('a signed-in session is written to secure storage, not preferences',
      () async {
    SharedPreferences.setMockInitialValues({});
    final store = SessionStore();

    await store.save(_auth);

    const secure = FlutterSecureStorage();
    expect(await secure.read(key: 'access_token'), 'access-1');
    expect(await secure.read(key: 'refresh_token'), 'refresh-1');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), isNull,
        reason: 'a token in SharedPreferences is a token in an unencrypted '
            'backup');
    expect(prefs.getString('refresh_token'), isNull);
  });

  group('a session written by an earlier build', () {
    test('is carried over rather than dropped', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'legacy-access',
        'refresh_token': 'legacy-refresh',
        'auth_user': '7|Aisha Karimova|aisha@estatecrm.kz|AGENT',
      });

      final store = SessionStore();
      await store.load();

      expect(store.isLoggedIn, isTrue,
          reason: 'updating the app must not sign anyone out');
      expect(store.accessToken, 'legacy-access');
      expect(store.refreshToken, 'legacy-refresh');
      expect((await store.getSavedUser())?.email, 'aisha@estatecrm.kz');
    });

    test('leaves no plaintext copy behind', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'legacy-access',
        'refresh_token': 'legacy-refresh',
        'auth_user': '7|Aisha Karimova|aisha@estatecrm.kz|AGENT',
      });

      await SessionStore().load();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('access_token'), isNull);
      expect(prefs.getString('refresh_token'), isNull);
      expect(prefs.getString('auth_user'), isNull);

      const secure = FlutterSecureStorage();
      expect(await secure.read(key: 'access_token'), 'legacy-access');
    });

    test('is only consulted when secure storage has nothing', () async {
      FlutterSecureStorage.setMockInitialValues({'access_token': 'current'});
      SharedPreferences.setMockInitialValues({'access_token': 'stale'});

      final store = SessionStore();
      await store.load();

      expect(store.accessToken, 'current',
          reason: 'a leftover preference must never outrank the keychain');
    });
  });

  test('signing out clears the session everywhere', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SessionStore();
    await store.save(_auth);

    await store.clear();

    expect(store.isLoggedIn, isFalse);
    expect(await store.getSavedUser(), isNull);
    const secure = FlutterSecureStorage();
    expect(await secure.read(key: 'access_token'), isNull);
    expect(await secure.read(key: 'refresh_token'), isNull);
    expect(await secure.read(key: 'auth_user'), isNull);
  });
}
