import 'package:flutter/foundation.dart';

/// What the app thinks the time is.
///
/// Several screens group by calendar day — the meetings list has a TODAY
/// heading, the dashboard draws a rail of the next fourteen days — so their
/// layout depends on where "now" falls inside a day, not just on the data.
///
/// Reading the wall clock straight from those widgets made their tests pass in
/// the morning and fail in the evening: a fixture placed "four hours from now"
/// is today's meeting at 09:00 and tomorrow's at 21:00. One seam, held still by
/// a test, is the difference between a suite that means something and one that
/// has to be run before dinner.
class AppClock {
  const AppClock._();

  static DateTime Function() _source = DateTime.now;

  static DateTime now() => _source();

  /// Freezes the clock at [value] for the rest of the test.
  ///
  /// Pair with [reset] — `addTearDown(AppClock.reset)` — or the next test
  /// inherits the frozen time.
  @visibleForTesting
  static void freeze(DateTime value) => _source = () => value;

  @visibleForTesting
  static void reset() => _source = DateTime.now;
}
