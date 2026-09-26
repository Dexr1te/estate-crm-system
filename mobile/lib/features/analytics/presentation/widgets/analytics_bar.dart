import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

String percentLabel(double? rate, String none) =>
    rate == null ? none : '${(rate * 100).round()}%';

class AnalyticsBarRow extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final double fraction;
  final Color color;

  const AnalyticsBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final f = fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: t.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: t.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: t.chartTrack)),
                FractionallySizedBox(
                  widthFactor: f,
                  heightFactor: 1,
                  child: ColoredBox(color: color),
                ),
              ],
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 5),
          Text(
            caption!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11,
                color: t.textSecondary),
          ),
        ],
      ],
    );
  }
}
