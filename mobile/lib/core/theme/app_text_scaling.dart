import 'package:flutter/material.dart';

/// The one text-scaling clamp the whole app renders under.
///
/// It is a widget rather than a line inside `my_app` so the acceptance harness
/// can render screens under the same thing the app does. A copy in the test
/// would prove nothing the moment the two drifted — which is exactly how a
/// clamp that crashed the date picker shipped under a green suite.
///
/// There is deliberately **no minimum**. A floor intersects with the clamps
/// Flutter's own widgets apply — `BottomNavigationBar` caps scaling at 1.0 —
/// and a floor of 1.0 turns that intersection into the empty range [1.0, 1.0],
/// which trips `_ClampedTextScaler`'s `maxScale > minScale` assertion and
/// paints a red error box where the widget should be. A floor also overrides
/// someone who asked for smaller text, which is not ours to override.
class AppTextScaling extends StatelessWidget {
  /// Above this, dense screens stop fitting. Proven rather than assumed: the
  /// acceptance matrix runs every screen at this scale.
  static const double maxScaleFactor = 1.5;

  final Widget child;
  const AppTextScaling({super.key, required this.child});

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: maxScaleFactor,
        child: child,
      );
}
