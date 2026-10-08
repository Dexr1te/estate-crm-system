import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

enum GlassShadow { none, soft, floating }

/// A pane of liquid glass: a translucent fill with a lit top edge, a hairline
/// rim and, when [blur] is above zero, whatever lies behind it blurred.
///
/// Blur is for chrome that floats over moving content (the tab bar, header
/// buttons, sheets). A card sits on the page's fixed backdrop, which is
/// already soft, so it gets the look without paying for a blur pass per card.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final Color? fill;
  final Color? rim;
  final double rimWidth;
  final Color? sheen;
  final GlassShadow shadow;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius =
        const BorderRadius.all(Radius.circular(AppMetrics.radiusMd)),
    this.blur = 0,
    this.fill,
    this.rim,
    this.rimWidth = AppMetrics.borderWidth,
    this.sheen,
    this.shadow = GlassShadow.none,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget pane = CustomPaint(
      painter: _GlassPainter(
        radius: borderRadius,
        fill: fill ?? t.glassFill,
        sheen: sheen ?? t.glassSheen,
      ),
      foregroundPainter: _GlassRimPainter(
        radius: borderRadius,
        rim: rim ?? t.glassRim,
        rimWidth: rimWidth,
        highlight: t.glassHighlight,
      ),
      child: child,
    );
    if (blur > 0) {
      pane = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: pane,
        ),
      );
    }
    if (shadow == GlassShadow.none) return pane;
    return CustomPaint(
      painter: _GlassShadowPainter(
        radius: borderRadius,
        color: t.glassShadow,
        floating: shadow == GlassShadow.floating,
      ),
      child: pane,
    );
  }
}

class _GlassPainter extends CustomPainter {
  final BorderRadius radius;
  final Color fill;
  final Color sheen;

  const _GlassPainter(
      {required this.radius, required this.fill, required this.sheen});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);
    canvas.drawRRect(rrect, Paint()..color = fill);
    if (sheen.a == 0) return;
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [sheen, sheen.withValues(alpha: 0)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.radius != radius || old.fill != fill || old.sheen != sheen;
}

class _GlassRimPainter extends CustomPainter {
  final BorderRadius radius;
  final Color rim;
  final double rimWidth;
  final Color highlight;

  const _GlassRimPainter({
    required this.radius,
    required this.rim,
    required this.rimWidth,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      radius.toRRect(rect).deflate(rimWidth / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimWidth
        ..color = rim,
    );
    // Light catching the top edge, gone by the middle of the pane.
    final lit = radius.toRRect(rect).deflate(rimWidth + 0.5);
    canvas.drawRRect(
      lit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [highlight, highlight.withValues(alpha: 0)],
          stops: const [0, 0.5],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter old) =>
      old.radius != radius ||
      old.rim != rim ||
      old.rimWidth != rimWidth ||
      old.highlight != highlight;
}

/// A shadow drawn only outside the pane: under translucent glass an ordinary
/// box shadow shows through as a dark smudge.
class _GlassShadowPainter extends CustomPainter {
  final BorderRadius radius;
  final Color color;
  final bool floating;

  const _GlassShadowPainter(
      {required this.radius, required this.color, required this.floating});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);
    final sigma = floating ? 14.0 : 8.0;
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect.inflate(sigma * 4))
      ..addRRect(rrect);
    canvas
      ..save()
      ..clipPath(outside)
      ..drawRRect(
        rrect.shift(Offset(0, floating ? 8 : 3)),
        Paint()
          ..color = floating ? color : color.withValues(alpha: color.a * 0.7)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlassShadowPainter old) =>
      old.radius != radius || old.color != color || old.floating != floating;
}

/// The page behind everything: the app's background, painted once under the
/// navigator so a transparent Scaffold shows it.
class AppBackdrop extends StatelessWidget {
  final Widget child;
  const AppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: context.tokens.background, child: child);
}
