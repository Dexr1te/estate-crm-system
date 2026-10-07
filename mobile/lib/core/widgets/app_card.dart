import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/glass.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;

  final bool nested;

  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.radius = AppMetrics.radiusMd,
    this.nested = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shape = BorderRadius.circular(radius);
    final body = Padding(
      padding: padding ?? EdgeInsets.all(AppMetrics.cardPadding(context)),
      child: child,
    );

    final content = onTap == null
        ? body
        : Material(
            color: Colors.transparent,
            child: InkWell(borderRadius: shape, onTap: onTap, child: body),
          );

    if (nested) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: t.surfaceVariant,
          borderRadius: shape,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 1.5),
        ),
        child: content,
      );
    }

    return GlassSurface(
      borderRadius: shape,
      rim: borderColor,
      rimWidth: borderColor == null ? AppMetrics.borderWidth : 1.5,
      shadow: GlassShadow.soft,
      child: content,
    );
  }
}

class AppHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shape = BorderRadius.circular(AppMetrics.radiusLg);

    final content = Stack(
      children: [
        Positioned(
          right: -40,
          top: -40,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.accent.withValues(alpha: 0.12),
            ),
          ),
        ),
        Padding(padding: padding, child: child),
      ],
    );

    return GlassSurface(
      borderRadius: shape,
      fill: t.heroGlass,
      sheen: Colors.white.withValues(alpha: t.isDark ? 0.05 : 0.08),
      rim: t.heroBorder,
      shadow: GlassShadow.soft,
      child: ClipRRect(
        borderRadius: shape,
        child: onTap == null
            ? content
            : Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: content),
              ),
      ),
    );
  }
}
