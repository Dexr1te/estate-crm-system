import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

class MeetingRow extends StatelessWidget {
  final String time;
  final String dayOrType;
  final String title;
  final String meta;
  final VoidCallback? onTap;

  const MeetingRow({
    super.key,
    required this.time,
    required this.dayOrType,
    required this.title,
    required this.meta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppCard(
      radius: 14,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  time,
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  dayOrType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 10,
                      color: t.textHint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 28, color: t.border),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.textPrimary),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11,
                        color: t.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The placeholder a [MeetingRow] leaves: a narrow time column, the rule that
/// separates it, and the title and client beside them.
///
/// The rule is the reason this is not a bare rectangle — it is what makes the
/// row read as a time and a meeting rather than as a list item in general, and
/// it is where the eye goes first once the real rows land.
class MeetingRowBone extends StatelessWidget {
  final double titleFactor;
  final double metaFactor;

  const MeetingRowBone({
    super.key,
    this.titleFactor = 0.62,
    this.metaFactor = 0.38,
  });

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 44,
              child: Column(
                children: [
                  ShimmerBox(width: 38, height: 12, radius: 6),
                  SizedBox(height: 5),
                  ShimmerBox(width: 30, height: 9, radius: 4.5),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const ShimmerBox(width: 1, height: 28, radius: 0.5),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBar(widthFactor: titleFactor, height: 12),
                  const SizedBox(height: 7),
                  ShimmerBar(widthFactor: metaFactor, height: 10),
                ],
              ),
            ),
          ],
        ),
      );
}
