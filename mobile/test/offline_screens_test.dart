import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/offline_cache.dart';
import 'package:real_estate_crm/core/session/session_store.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:real_estate_crm/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/client_form_screen.dart';
import 'package:real_estate_crm/features/clients/presentation/screens/clients_screen.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// The backend, reachable or not.
class _Host implements HttpClientAdapter {
  bool online = true;

  static final _bodies = <String, Object>{
    '/clients': [
      {'id': 1, 'fullName': 'Irina Sokolova', 'phone': '+7 916 220-84-11'},
    ],
    '/clients/with-details': <Object>[],
  };

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (!online) {
      throw DioException(
          requestOptions: options, type: DioExceptionType.connectionError);
    }
    return ResponseBody.fromString(
        jsonEncode(_bodies[options.path] ?? const {}), 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

/// The same cache, kept in memory: the file-backed one is covered by
/// offline_cache_test, and real disk I/O does not finish under a widget test's
/// fake clock.
class _MemoryCache extends OfflineCache {
  _MemoryCache() : super(directory: () async => Directory.systemTemp);
  final _kept = <String, CachedResponse>{};

  @override
  Future<CachedResponse?> read(String key) async => _kept[key];

  @override
  Future<void> write(String key, Object? data, {int statusCode = 200}) async =>
      _kept[key] = CachedResponse(
          data: data,
          statusCode: statusCode,
          savedAt: DateTime(2026, 9, 26, 14, 32));

  @override
  Future<void> wipe() async => _kept.clear();
}

/// A repository whose every write finds no network.
class _Unplugged extends FakeClientsRepository {
  @override
  Future<ClientResponse> createClient(Map<String, dynamic> data) async =>
      throw DioException(
        requestOptions: RequestOptions(path: '/clients', method: 'POST'),
        type: DioExceptionType.connectionError,
      );
}

Future<AuthBloc> _signedIn() async {
  final auth = AuthBloc(FakeAuthRepository(
      user: const AuthResponse(userId: 7, fullName: 'Aisha', teamId: 3)))
    ..add(AuthCheckEvent());
  await auth.stream.firstWhere((s) => s is AuthAuthenticated);
  return auth;
}

Widget _app(AuthBloc auth, ClientsBloc bloc, String initial,
        {ValueNotifier<DateTime?>? offline}) =>
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider.value(value: bloc),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => OfflineBanner(
          status: offline ?? ValueNotifier(null),
          onRetry: () {},
          child: child!,
        ),
        routerConfig: GoRouter(initialLocation: initial, routes: [
          GoRoute(path: '/clients', builder: (_, __) => const ClientsScreen()),
          GoRoute(
              path: '/clients/new',
              builder: (_, __) => const ClientFormScreen()),
        ]),
      ),
    );

void main() {
  testWidgets('in a lift, the client list opens from what was kept',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final session = SessionStore();
    await session.load();
    await session.save(const AuthResponse(
        accessToken: 'a', refreshToken: 'r', userId: 7, teamId: 3));

    final host = _Host();
    final client =
        ApiClient(session, adapter: host, offlineCache: _MemoryCache());
    final repo = ClientsRepositoryImpl(ClientsRemoteDataSource(client));

    // Earlier, with signal: the list was read once, and kept.
    await tester.runAsync(() async {
      await repo.getClients();
      await repo.getClientsWithDetails();
    });

    // Now the signal is gone.
    host.online = false;
    final auth = await _signedIn();
    addTearDown(auth.close);
    final bloc = ClientsBloc(repo);
    addTearDown(bloc.close);

    await tester
        .pumpWidget(_app(auth, bloc, '/clients', offline: client.offline));
    await tester.pumpAndSettle();
    expect(bloc.state, isA<ClientsLoaded>());

    expect(find.text('Irina Sokolova'), findsWidgets);
    expect(find.byKey(const Key('offline-banner')), findsOneWidget);
    expect(find.textContaining('Offline — showing data from'), findsOneWidget);
    expect(find.text('Cannot connect to server. Check your internet.'),
        findsNothing);
  });

  testWidgets('saving a new client offline says it needs a connection',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final auth = await _signedIn();
    addTearDown(auth.close);
    final bloc = ClientsBloc(_Unplugged());
    addTearDown(bloc.close);

    await tester.pumpWidget(_app(auth, bloc, '/clients/new'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Aigerim');
    final create = find.text('Create Client');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();

    expect(
        find.text('You’re offline — this needs a connection.'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });
}
