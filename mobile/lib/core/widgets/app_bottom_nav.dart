import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const AppNavItem(
      {required this.icon, required this.activeIcon, required this.label});
}

/// Bottom navigation per the handoff: 6 items, surface fill, 1px top border.
///
/// Each item is a two-row grid with a **fixed 18px icon box** above the label,
/// so every label shares one baseline regardless of glyph height. Labels stay
/// at 11px and never wrap or ellipsise — the copy is shortened instead.
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

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(
            top: BorderSide(color: t.border, width: AppMetrics.borderWidth)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 9,
          bottom: AppMetrics.bottomInset(context),
        ),
        child: Row(
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
      ),
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
    final color = selected ? t.primary : t.textHint;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: AppMetrics.minHitTarget),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: AppMetrics.navIconBox,
                  child: Center(
                    child: Icon(selected ? item.activeIcon : item.icon,
                        size: AppMetrics.navIconBox, color: color),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  // Labels are shortened in copy, never truncated with an
                  // ellipsis — clip is the visible failure mode if a
                  // translation is ever too long.
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11,
                    height: 1.1,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
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
