import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

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

  const AppGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = AppMetrics.buttonHeight,
    this.fontSize = 13.5,
    this.borderColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
              border: Border.all(
                  color: borderColor ?? t.border,
                  width: AppMetrics.borderWidth),
            ),
            child: Center(
              child: Padding(
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
                    color: labelColor ?? t.textPrimary,
                  ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(
          minHeight: AppMetrics.minHitTarget, maxWidth: 190),
      child: Material(
        color: t.primary,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
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
  final String? tooltip;

  const AppIconTile({
    super.key,
    required this.icon,
    required this.onPressed,
    this.danger = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tile = SizedBox(
      width: AppMetrics.minHitTarget,
      height: AppMetrics.minHitTarget,
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: danger ? t.dangerFill : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: danger ? t.dangerBorder : t.border,
                width: AppMetrics.borderWidth),
          ),
          child: Icon(icon,
              size: 16, color: danger ? t.dangerText : t.textSecondary),
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
