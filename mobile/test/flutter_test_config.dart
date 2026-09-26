import 'dart:async';

import 'package:real_estate_crm/core/di/injector.dart';

import 'fakes.dart';

/// Every screen that shows a client or a deal now carries its tasks card, and
/// that card reads through the injector on its own. A test that is not about
/// tasks should not reach for the network because of it, so the whole suite
/// starts from an empty in-memory repository; a tasks test swaps in its own.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Injector.tasksRepository = FakeTasksRepository();
  await testMain();
}
