import 'package:flutter/foundation.dart';

class AppClock {
  const AppClock._();

  static DateTime Function() _source = DateTime.now;

  static DateTime now() => _source();

  @visibleForTesting
  static void freeze(DateTime value) => _source = () => value;

  @visibleForTesting
  static void reset() => _source = DateTime.now;
}
