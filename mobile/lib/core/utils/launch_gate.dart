import 'package:flutter/foundation.dart';

/// Something a deep link or a home-screen shortcut must wait behind before it
/// opens a screen — the app lock, while it is up. It notifies when it opens.
abstract class LaunchGate implements Listenable {
  bool get isOpen;
}
