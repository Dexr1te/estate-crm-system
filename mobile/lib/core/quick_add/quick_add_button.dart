import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_crm/core/quick_add/quick_add_sheet.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

enum QuickAddShape { tile, floating, rail }

class QuickAddButton extends StatelessWidget {
  static const floatingSize = 56.0;

  final QuickAddShape shape;
  final VoidCallback? onDone;

  const QuickAddButton.tile({super.key, this.onDone})
      : shape = QuickAddShape.tile;

  const QuickAddButton.floating({super.key, this.onDone})
      : shape = QuickAddShape.floating;

  const QuickAddButton.rail({super.key, this.onDone})
      : shape = QuickAddShape.rail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open() => showQuickAddSheet(context, onDone: onDone);
    void openWithTap() {
      HapticFeedback.lightImpact();
      open();
    }

    return switch (shape) {
      QuickAddShape.tile => AppIconTile(
          key: const ValueKey('quick-add'),
          icon: Icons.add_rounded,
          tooltip: l10n.quickAddOpen,
          onPressed: open,
        ),
      QuickAddShape.floating => _Floating(
          key: const ValueKey('quick-add'),
          label: l10n.quickAddTitle,
          onPressed: openWithTap,
        ),
      QuickAddShape.rail => _Rail(
          key: const ValueKey('quick-add'),
          label: l10n.quickAddTitle,
          onPressed: openWithTap,
        ),
    };
  }
}

class _Floating extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _Floating({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: t.isDark
                    ? t.glassShadow
                    : t.primary.withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: t.primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: QuickAddButton.floatingSize,
                child: Icon(Icons.add_rounded, size: 28, color: t.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _Rail({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pill = BorderRadius.circular(AppMetrics.radiusPill);
    return Material(
      color: t.primary,
      borderRadius: pill,
      child: InkWell(
        borderRadius: pill,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppMetrics.minHitTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 20, color: t.onPrimary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: AppMetrics.buttonFontSize,
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
