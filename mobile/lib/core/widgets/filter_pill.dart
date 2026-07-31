import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  final bool onCard;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onCard = false,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(AppMetrics.radiusPill);

    return Material(
      color: selected ? t.primary : (onCard ? t.surfaceVariant : t.surface),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected || onCard
                ? null
                : Border.all(color: t.border, width: AppMetrics.borderWidth),
          ),
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
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 8, children: pills);
}

class FilterPillRow extends StatelessWidget {
  final List<Widget> pills;
  final EdgeInsetsGeometry padding;
  const FilterPillRow({
    super.key,
    required this.pills,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          children: [
            for (var i = 0; i < pills.length; i++) ...[
              if (i > 0) const SizedBox(width: 7),
              pills[i],
            ],
          ],
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Material(
                color: i == selectedIndex ? t.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => onSelected(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12.5,
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
    );
  }
}
