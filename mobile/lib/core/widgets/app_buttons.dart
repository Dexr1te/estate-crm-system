import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/glass.dart';

class AppFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;

  final Color? fill;
  final Color? labelColor;
  final double radius;
  final bool loading;

  const AppFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = AppMetrics.buttonHeight,
    this.fontSize = 14.5,
    this.fill,
    this.labelColor,
    this.radius = AppMetrics.radiusSm,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bg = fill ?? t.primary;
    final fg = labelColor ?? t.onPrimary;
    final enabled = onPressed != null && !loading;

    return SizedBox(
      height: height,
      child: Material(
        color: enabled ? bg : bg.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class AppGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final Color? borderColor;
  final Color? labelColor;
  final IconData? icon;
  final bool loading;

  const AppGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = AppMetrics.buttonHeight,
    this.fontSize = 13.5,
    this.borderColor,
    this.labelColor,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = labelColor ?? t.textPrimary;
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
          onTap: loading ? null : onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
              border: Border.all(
                  color: borderColor ?? t.border,
                  width: AppMetrics.borderWidth),
            ),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: fg),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 17, color: fg),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                                color: fg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppHeaderAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const AppHeaderAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pill = BorderRadius.circular(AppMetrics.radiusPill);
    return ConstrainedBox(
      constraints: const BoxConstraints(
          minHeight: AppMetrics.minHitTarget, maxWidth: 190),
      child: GlassSurface(
        blur: AppMetrics.glassBlur,
        borderRadius: pill,
        fill: t.primary.withValues(alpha: 0.9),
        sheen: Colors.white.withValues(alpha: t.isDark ? 0.18 : 0.12),
        rim: Colors.white.withValues(alpha: 0.12),
        shadow: GlassShadow.soft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: pill,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: t.onPrimary),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: t.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;

  const AppDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = AppMetrics.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      height: height,
      child: Material(
        color: t.dangerFill,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
              border: Border.all(
                  color: t.dangerBorder, width: AppMetrics.borderWidth),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: t.dangerText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppIconTile extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool danger;
  final bool strong;
  final String? tooltip;

  const AppIconTile({
    super.key,
    required this.icon,
    required this.onPressed,
    this.danger = false,
    this.strong = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tile = SizedBox(
      width: AppMetrics.minHitTarget,
      height: AppMetrics.minHitTarget,
      child: Center(
        child: GlassSurface(
          blur: AppMetrics.glassBlur,
          borderRadius: BorderRadius.circular(AppMetrics.radiusPill),
          fill: danger ? t.dangerFill : null,
          rim: danger ? t.dangerBorder : null,
          shadow: GlassShadow.soft,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon,
                size: 16,
                color: danger
                    ? t.dangerText
                    : (strong ? t.textPrimary : t.textSecondary)),
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppMetrics.minHitTarget / 2),
        onTap: onPressed,
        child: tooltip == null ? tile : Tooltip(message: tooltip!, child: tile),
      ),
    );
  }
}
