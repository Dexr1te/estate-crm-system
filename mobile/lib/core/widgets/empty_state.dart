import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Centred when it fits and scrollable when it does not, so a phone set to
    // large text still reaches the action at the bottom instead of clipping it.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: AppMetrics.pagePadding(context), vertical: 24),
        child: ConstrainedBox(
          // Only stretch to fill when there is a height to fill. In a bottom
          // sheet the column is min-sized, so maxHeight is infinite and asking
          // for it back would demand an infinite child — which is how the
          // picker's "nothing found" turned into an empty sheet.
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight
                ? (constraints.maxHeight - 48).clamp(0.0, double.infinity)
                : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: t.border, width: AppMetrics.borderWidth),
                ),
                child: Icon(icon, size: 26, color: t.textHint),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: t.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12.5,
                      height: 1.55,
                      color: t.textSecondary,
                    ),
                  ),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 22), action!],
            ],
          ),
        ),
      ),
    );
  }
}
