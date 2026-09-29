import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/map/map_tiles.dart';
import 'package:real_estate_crm/core/utils/money.dart';
import 'package:real_estate_crm/features/app_lock/presentation/controller/app_lock_controller.dart';

import 'fakes.dart';

/// Every screen that shows a client or a deal now carries its tasks card, and
/// that card reads through the injector on its own. A test that is not about
/// tasks should not reach for the network because of it, so the whole suite
/// starts from an empty in-memory repository; a tasks test swaps in its own.
/// The notification bell on the dashboard reads the same way, and the unread
/// count is never polled on a timer here. Map tiles come from memory.
///
/// The same goes for the pickers and lists a form or screen fills on its own —
/// agents, clients, listings, deals, meetings, documents. They start empty, and
/// a test that needs rows puts its own fake in.
///
/// And the app's own HTTP client refuses every request: a test that still
/// reaches it fails and names the path, instead of quietly rendering the
/// "could not load" state that a 400 from the test binding would produce.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Injector.tasksRepository = FakeTasksRepository();
  Injector.notificationsRepository = FakeNotificationsRepository();
  // Every deal detail carries its discussion card, which reads on its own.
  Injector.dealCommentsRepository = FakeDealCommentsRepository();
  Injector.agentsRepository = const FakeAgentsRepository([]);
  Injector.clientsRepository = FakeClientsRepository();
  Injector.propertiesRepository = FakePropertiesRepository(const []);
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
  Injector.documentsRepository = FakeDocumentsRepository();
  Injector.exportsRepository = FakeExportsRepository();
  Injector.notificationsPollInterval = null;
  // No PIN on the phone: the lock stays off, and its keychain is memory.
  Injector.appLockRepository = fakeAppLockRepository();
  Injector.appLock = AppLockController(repository: Injector.appLockRepository);
  // Maps draw blank tiles: no test reaches OpenStreetMap.
  MapTiles.provider = BlankTileProvider.new;
  MapTiles.urlTemplate = 'blank://{z}/{x}/{y}';

  final reached = <String>[];
  Injector.apiClient.dio.interceptors.insert(
    0,
    InterceptorsWrapper(onRequest: (options, handler) {
      reached.add('${options.method} ${options.path}');
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'tests never use the network',
      ));
    }),
  );
  // Money prints in dollars and English unless a test says otherwise.
  tearDown(() {
    AppCurrency.reset();
    AppCurrency.locale = 'en';
  });
  tearDown(() {
    final paths = [...reached];
    reached.clear();
    expect(paths, isEmpty,
        reason: 'the test reached the real API through Injector — '
            'give it a fake repository');
  });

  await testMain();
}
