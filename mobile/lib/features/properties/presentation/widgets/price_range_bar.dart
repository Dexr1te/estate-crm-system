import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

/// The middle half of the comparables' prices per m² as a band, their median
/// as a tick, and — when there is one — this listing's own as a dot.
class PriceRangeBar extends StatelessWidget {
  final double low;
  final double median;
  final double high;
  final double? marker;

  const PriceRangeBar({
    super.key,
    required this.low,
    required this.median,
    required this.high,
    this.marker,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final from = math.min(low, marker ?? low);
    final to = math.max(high, marker ?? high);
    final pad = to > from ? (to - from) * 0.15 : math.max(from * 0.1, 1.0);
    final start = from - pad;
    final span = (to + pad) - start;
    double at(double v) => ((v - start) / span).clamp(0.0, 1.0);

    final labelStyle = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11, color: t.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 18,
          child: LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 6,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surfaceVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('price-range-band'),
                  left: w * at(low),
                  width: math.max(2.0, w * (at(high) - at(low))),
                  top: 6,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('price-range-median'),
                  left: w * at(median) - 1,
                  width: 2,
                  top: 2,
                  height: 14,
                  child: ColoredBox(color: t.textSecondary),
                ),
                if (marker != null)
                  Positioned(
                    key: const ValueKey('price-range-marker'),
                    left: w * at(marker!) - 6,
                    top: 3,
                    width: 12,
                    height: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: t.textPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(formatPrice(low),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(formatPrice(high),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: labelStyle),
            ),
          ],
        ),
      ],
    );
  }
}
