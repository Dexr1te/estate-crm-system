import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_rows.dart';
import 'package:real_estate_crm/features/compare/presentation/widgets/compare_header.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Wide enough that every column fits without scrolling.
const double kCompareWideBreakpoint = 600;

/// The comparison grid: a row label on the left, a column per listing. Below
/// [kCompareWideBreakpoint] the columns scroll sideways under a label column
/// that stays put; at or above it every column shares the width.
class CompareTable extends StatelessWidget {
  final List<ComparedListing> listings;
  final DateTime now;
  final ValueChanged<int> onOpen;
  final ValueChanged<int> onRemove;

  const CompareTable({
    super.key,
    required this.listings,
    required this.now,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final rows = rowsFor(listings);
    final properties = [for (final l in listings) l.property];
    final best = {
      for (final row in rows)
        if (bestByFor(row) != null) row: bestIds(properties, bestByFor(row)!),
    };
    // Every cell is at most two lines, so a row's height is known up front
    // and the pinned label column lines up with the scrolling one.
    final rowHeight = scaler.scale(34) + 18;
    final headHeight = compareHeaderHeight(scaler);

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= kCompareWideBreakpoint;
      final labelWidth = wide ? 150.0 : 108.0;
      final room = constraints.maxWidth - labelWidth;
      final columnWidth =
          wide ? (room / listings.length).clamp(120.0, 260.0) : 150.0;

      Widget column(ComparedListing l) => SizedBox(
            width: columnWidth,
            child: Column(children: [
              SizedBox(
                height: headHeight,
                child: CompareHeader(
                  property: l.property,
                  onOpen: () => onOpen(l.property.id),
                  onRemove: () => onRemove(l.property.id),
                ),
              ),
              for (final row in rows)
                _Cell(
                  key: ValueKey('compare-cell-${row.name}-${l.property.id}'),
                  height: rowHeight,
                  text: compareCell(l10n, row, l, now),
                  best: best[row]?.contains(l.property.id) ?? false,
                  strong: row == CompareRow.price,
                ),
            ]),
          );

      final labels = SizedBox(
        width: labelWidth,
        child: Column(children: [
          SizedBox(height: headHeight),
          for (final row in rows)
            _Cell(
                height: rowHeight,
                text: compareRowLabel(l10n, row),
                label: true),
        ]),
      );

      final columns = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final l in listings) column(l)],
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labels,
          Expanded(
            child: wide
                ? Align(alignment: Alignment.topLeft, child: columns)
                : SingleChildScrollView(
                    key: const ValueKey('compare-columns-scroll'),
                    scrollDirection: Axis.horizontal,
                    child: columns,
                  ),
          ),
        ],
      );
    });
  }
}

/// What the comparison looks like while its listings load: two column heads
/// and a few rows.
class CompareSkeleton extends StatelessWidget {
  const CompareSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = AppMetrics.pagePadding(context);
    return ShimmerGroup(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                SizedBox(width: 108),
                ShimmerBox(width: 44, height: 44, radius: 12),
                Spacer(),
                ShimmerBox(width: 44, height: 44, radius: 12),
                Spacer(),
              ],
            ),
            for (var i = 0; i < 6; i++) ...[
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(child: ShimmerBar(widthFactor: 0.7, height: 10)),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBar(widthFactor: 0.8, height: 12)),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBar(widthFactor: 0.8, height: 12)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final double height;
  final String text;
  final bool best;
  final bool label;
  final bool strong;

  const _Cell({
    super.key,
    required this.height,
    required this.text,
    this.best = false,
    this.label = false,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final positive = StatusPalette.resolve(t, StatusHue.positive);
    final missing = text == kCompareMissing;
    final color = best
        ? positive.label
        : label || missing
            ? t.textSecondary
            : t.textPrimary;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.border, width: 1)),
      ),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: best ? 6 : 0, vertical: 2),
        decoration: best
            ? BoxDecoration(
                color: positive.fill,
                borderRadius: BorderRadius.circular(AppMetrics.radiusSm / 2))
            : null,
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: label ? 11.5 : 12.5,
            height: 1.3,
            fontWeight: best || strong ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ),
    );
  }
}
