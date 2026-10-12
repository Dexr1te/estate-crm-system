import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_surface.dart';

class AppCard extends StatelessWidget {
  static const EdgeInsets nestedPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 11);

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? radius;

  final bool nested;

  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.radius,
    this.nested = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tile = nested && AppSurface.levelOf(context) != SurfaceLevel.page;
    final shape = BorderRadius.circular(
        radius ?? (nested ? AppMetrics.radiusSm : AppMetrics.radiusMd));
    final body = Padding(
      padding: padding ??
          (nested
              ? nestedPadding
              : EdgeInsets.all(AppMetrics.cardPadding(context))),
      child: AppSurface(
        level: tile ? SurfaceLevel.nested : SurfaceLevel.card,
        child: child,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tile ? t.surfaceVariant : t.surface,
        borderRadius: shape,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1.5),
      ),
      child: onTap == null
          ? body
          : Material(
              color: Colors.transparent,
              child: InkWell(borderRadius: shape, onTap: onTap, child: body),
            ),
    );
  }
}

class AppHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppHeroCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shape = BorderRadius.circular(AppMetrics.radiusLg);
    final content = Padding(
      padding: padding ?? EdgeInsets.all(AppMetrics.cardPadding(context)),
      child: AppSurface(level: SurfaceLevel.hero, child: child),
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: t.heroSurface, borderRadius: shape),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(borderRadius: shape, onTap: onTap, child: content),
            ),
    );
  }
}
