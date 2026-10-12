import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/feedback/app_haptics.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_surface.dart';
import 'package:real_estate_crm/core/widgets/hit_slop.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  final bool? onCard;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onCard,
    this.fontSize = AppType.footnote,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(AppMetrics.radiusPill);
    final card = onCard ?? AppSurface.levelOf(context) == SurfaceLevel.card;

    return HitSlop(
      child: Material(
        color: selected ? t.primary : (card ? t.surfaceVariant : t.surface),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          child: Padding(
            padding: padding,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: fontSize,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? t.onPrimary : t.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterPillWrap extends StatelessWidget {
  final List<Widget> pills;
  const FilterPillWrap({super.key, required this.pills});

  @override
  Widget build(BuildContext context) => HitSlop(
        minWidth: 0,
        child: Wrap(spacing: 8, runSpacing: 8, children: pills),
      );
}

class FilterPillRow extends StatelessWidget {
  final List<Widget> pills;
  final EdgeInsetsGeometry padding;
  final bool bleed;

  const FilterPillRow({
    super.key,
    required this.pills,
    this.padding = EdgeInsets.zero,
    this.bleed = false,
  });

  @override
  Widget build(BuildContext context) => HitSlop(
        minWidth: 0,
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: padding,
            clipBehavior: bleed ? Clip.none : Clip.hardEdge,
            child: Row(
              children: [
                for (var i = 0; i < pills.length; i++) ...[
                  if (i > 0) const SizedBox(width: 7),
                  pills[i],
                ],
              ],
            ),
          ),
        ),
      );
}

class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return HitSlop(
      minWidth: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.segmentTrack,
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: HitSlop(
            minWidth: 0,
            minHeight: double.infinity,
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Material(
                      color: i == selectedIndex
                          ? t.segmentThumb
                          : Colors.transparent,
                      elevation: i == selectedIndex && !t.isDark ? 1 : 0,
                      shadowColor: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () {
                          if (i != selectedIndex) AppHaptics.selection();
                          onSelected(i);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: AppType.subhead,
                              fontWeight: i == selectedIndex
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: i == selectedIndex
                                  ? t.textPrimary
                                  : t.textSecondary,
                            ),
                          ),
                        ),
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
