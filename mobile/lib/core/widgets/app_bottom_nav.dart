import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/glass.dart';

class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const AppNavItem(
      {required this.icon, required this.activeIcon, required this.label});
}

/// The tab bar as a floating island of glass. The screen scrolls on under it,
/// so it sits in a Scaffold with `extendBody`.
class AppBottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  static const _lensTravel = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final below = inset > 0 ? math.max(inset - 12, 8.0) : 12.0;
    final pill = BorderRadius.circular(AppMetrics.radiusPill);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppMetrics.navIslandInset, 0, AppMetrics.navIslandInset, below),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppMetrics.navIslandMaxWidth),
          child: GlassSurface(
            blur: AppMetrics.glassBlur,
            borderRadius: pill,
            shadow: GlassShadow.floating,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: LayoutBuilder(builder: (context, constraints) {
                final cell = constraints.maxWidth / items.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _lensTravel,
                      curve: Curves.easeOutBack,
                      left: cell * currentIndex,
                      width: cell,
                      top: 0,
                      bottom: 0,
                      child: const _Lens(),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: _NavCell(
                              item: items[i],
                              selected: i == currentIndex,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Lens extends StatelessWidget {
  const _Lens();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GlassSurface(
      borderRadius: BorderRadius.circular(AppMetrics.radiusPill),
      fill: t.glassLens,
      sheen: t.glassSheen,
      child: const SizedBox.expand(),
    );
  }
}

class _NavCell extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavCell(
      {required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = selected ? t.primary : t.textSecondary;

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppMetrics.minHitTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.12 : 1,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: SizedBox(
                    height: AppMetrics.navIconBox,
                    child: Center(
                      child: Icon(selected ? item.activeIcon : item.icon,
                          size: AppMetrics.navIconBox, color: color),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 10.5,
                    height: 1.1,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
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
