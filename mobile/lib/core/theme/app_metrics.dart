import 'package:flutter/material.dart';

/// Layout constants from the design handoff.
///
/// Only *spacing* scales with width, and only in two steps, so small phones
/// don't cramp and large ones don't sprawl. Radii, border widths, icon boxes
/// and hit targets are absolute — never scale them with MediaQuery.
class AppMetrics {
  const AppMetrics._();

  // ── Fluid spacing (two steps, off width) ──────────────────────
  static double pagePadding(BuildContext c) =>
      MediaQuery.sizeOf(c).width < 360 ? 16 : 20;
  static double blockGap(BuildContext c) =>
      MediaQuery.sizeOf(c).width < 360 ? 10 : 14;
  static double cardPadding(BuildContext c) =>
      MediaQuery.sizeOf(c).width < 360 ? 13 : 15;

  // ── Fixed values ──────────────────────────────────────────────
  static const double radiusSm = 12; // buttons, inputs, small cards
  static const double radiusMd = 16; // cards
  static const double radiusLg = 18; // hero card
  static const double radiusPill = 999;
  static const double borderWidth = 1;
  static const double minHitTarget = 44;

  /// Full-width filled/ghost button height.
  static const double buttonHeight = 52;

  /// Inline (header) button height.
  static const double buttonHeightInline = 40;

  /// The bottom nav's icon box. Fixed so every label shares one baseline
  /// regardless of glyph height.
  static const double navIconBox = 18;

  // ── Breakpoints ───────────────────────────────────────────────
  /// At and above this width a phone layout must not simply stretch: content
  /// is centred inside [wideMaxContentWidth].
  static const double wideBreakpoint = 600;
  static const double wideMaxContentWidth = 560;

  /// Below this width the 2-column detail grids collapse to one column.
  static const double singleColumnBreakpoint = 340;

  /// At and above this width the bottom nav becomes a rail.
  static const double railBreakpoint = 900;

  /// Bottom inset for content that sits above the home indicator.
  static double bottomInset(BuildContext c) {
    final v = MediaQuery.viewPaddingOf(c).bottom;
    return v > 0 ? v : 12;
  }

  /// Padding for a CTA parked at the end of a scroll view: clears the home
  /// indicator, and the keyboard when one is up.
  static EdgeInsets ctaPadding(BuildContext c) {
    final mq = MediaQuery.of(c);
    final keyboard = mq.viewInsets.bottom;
    return EdgeInsets.only(
        bottom: 20 + (keyboard > 0 ? 0 : mq.viewPadding.bottom));
  }

  /// Caps page width on tablets/landscape instead of stretching a phone
  /// layout across the screen.
  ///
  /// Aligned to **top**-centre, not centre: `Center` would also centre
  /// vertically, which floats a short detail or form screen in the middle of
  /// the viewport. Screens that genuinely want vertical centring (auth) do it
  /// themselves with `CenteredScrollView`.
  static Widget constrain(Widget child) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: wideMaxContentWidth),
          child: child,
        ),
      );
}
