import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

/// A schedule row: a 44pt time column, a 28pt hairline divider, then the
/// title and meta. Used by the dashboard's upcoming list and the meetings
/// screen's day groups.
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
                      fontFamily: AppFonts.sans, fontSize: 10, color: t.textHint),
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
