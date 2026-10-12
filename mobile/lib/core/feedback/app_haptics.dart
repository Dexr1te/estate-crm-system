import 'dart:async';

import 'package:flutter/services.dart';

class AppHaptics {
  const AppHaptics._();

  static void light() => _play(HapticFeedback.lightImpact);

  static void selection() => _play(HapticFeedback.selectionClick);

  static void medium() => _play(HapticFeedback.mediumImpact);

  static void success() => _play(HapticFeedback.successNotification);

  static void warning() => _play(HapticFeedback.warningNotification);

  static void _play(Future<void> Function() effect) {
    unawaited(effect().catchError((Object _) {}));
  }
}
