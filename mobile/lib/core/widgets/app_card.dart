import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;

  final bool nested;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.radius = AppMetrics.radiusMd,
    this.nested = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shape = BorderRadius.circular(radius);
    final body = Padding(
      padding: padding ?? EdgeInsets.all(AppMetrics.cardPadding(context)),
      child: child,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: nested ? t.surfaceVariant : t.surface,
        borderRadius: shape,
        border: nested
            ? null
            : Border.all(color: t.border, width: AppMetrics.borderWidth),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.heroSurface,
        borderRadius: shape,
        border: t.heroBorder == null
            ? null
            : Border.all(color: t.heroBorder!, width: AppMetrics.borderWidth),
      ),
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
