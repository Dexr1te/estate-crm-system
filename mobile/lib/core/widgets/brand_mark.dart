import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

/// The EstateCRM mark: a rounded tile holding the "e." wordmark — light text
/// with a gold full stop.
///
/// Light draws it on navy; dark on surfaceVariant, so the tile still reads as
/// a mark rather than a filled button.
class BrandMark extends StatelessWidget {
  final double size;

  /// Corner radius. Defaults to ~30% of [size], matching the 62/19 and 40/12
  /// pairs in the mocks.
  final double? radius;

  const BrandMark({super.key, this.size = 62, this.radius});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.isDark ? t.surfaceVariant : t.primary,
        borderRadius: BorderRadius.circular(radius ?? size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          text: 'e',
          children: [
            TextSpan(text: '.', style: TextStyle(color: t.accent)),
          ],
        ),
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: size * 0.48,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: -size * 0.016,
          color: const Color(0xFFF0F2FF),
        ),
      ),
    );
  }
}

/// The full wordmark — "EstateCRM" with a gold full stop.
class BrandWordmark extends StatelessWidget {
  final double fontSize;
  const BrandWordmark({super.key, this.fontSize = 19});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text.rich(
      TextSpan(
        text: 'EstateCRM',
        children: [
          TextSpan(text: '.', style: TextStyle(color: t.accent)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: fontSize,
        height: 1,
        fontWeight: FontWeight.w700,
        letterSpacing: -fontSize * 0.03,
        color: t.textPrimary,
      ),
    );
  }
}

/// A scroll view whose content is vertically centred when it fits and scrolls
/// when it doesn't — the auth screens' layout, which must survive a 568pt-tall
/// phone at 1.3× text.
class CenteredScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const CenteredScrollView({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight -
                  padding.resolve(Directionality.of(context)).vertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [child],
            ),
          ),
        ),
      );
}
