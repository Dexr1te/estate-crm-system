import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/stars/presentation/widgets/star_button.dart';
import 'package:real_estate_crm/features/stars/presentation/widgets/star_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One starred record on the Starred screen: what it is, its two lines, and
/// the star that takes it off the list.
class StarredRow extends StatelessWidget {
  final StarredItem item;
  final VoidCallback onTap;
  final VoidCallback onUnstar;

  const StarredRow({
    super.key,
    required this.item,
    required this.onTap,
    required this.onUnstar,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final subtitle = item.subtitle;

    return AppCard(
      key: ValueKey('starred-row-${item.type.wire}-${item.id}'),
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.surfaceVariant,
              borderRadius: BorderRadius.circular(11),
            ),
            child:
                Icon(starTypeIcon(item.type), size: 19, color: t.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  starredTitle(l10n, item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 12,
                        color: t.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          StarButton(
            key: ValueKey('starred-unstar-${item.type.wire}-${item.id}'),
            starred: true,
            onPressed: onUnstar,
          ),
        ],
      ),
    );
  }
}

/// The skeleton of a [StarredRow], shaped like one.
class StarredRowBone extends StatelessWidget {
  const StarredRowBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerGroup(
        child: ShimmerRowCard(
          leading: ShimmerBox(width: 38, height: 38, radius: 11),
          trailing: ShimmerBox(width: 20, height: 20, radius: 6),
          titleFactor: 0.55,
          subtitleFactor: 0.4,
        ),
      );
}
