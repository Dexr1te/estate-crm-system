import 'package:flutter/material.dart';

class AppMetrics {
  const AppMetrics._();

  static double pagePadding(BuildContext c) =>
      MediaQuery.sizeOf(c).width < 360 ? 16 : 20;
  static double blockGap(BuildContext c) =>
      MediaQuery.sizeOf(c).width < 360 ? 10 : 14;
  static double cardPadding(BuildContext c) =>
      MediaQuery.sizeOf(c).width < 360 ? 13 : 15;

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 18;
  static const double radiusPill = 999;
  static const double borderWidth = 1;
  static const double minHitTarget = 44;

  static const double buttonHeight = 52;

  static const double buttonHeightInline = 40;

  static const double navIconBox = 18;

  static const double wideBreakpoint = 600;
  static const double wideMaxContentWidth = 560;

  static const double singleColumnBreakpoint = 340;

  static const double railBreakpoint = 900;

  static double bottomInset(BuildContext c) {
    final v = MediaQuery.viewPaddingOf(c).bottom;
    return v > 0 ? v : 12;
  }

  static EdgeInsets ctaPadding(BuildContext c) {
    final mq = MediaQuery.of(c);
    final keyboard = mq.viewInsets.bottom;
    return EdgeInsets.only(
        bottom: 20 + (keyboard > 0 ? 0 : mq.viewPadding.bottom));
  }

  static Widget constrain(Widget child) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: wideMaxContentWidth),
          child: child,
        ),
      );
}
