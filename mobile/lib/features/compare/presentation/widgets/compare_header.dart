import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const double _cover = 44;

/// The height every column head takes, so the pinned label column can leave
/// the same room above its first row.
double compareHeaderHeight(TextScaler scaler) =>
    8 + _cover + 8 + scaler.scale(33) + 6 + scaler.scale(13) + 8 + 10;

/// A column's head: cover, title and status. Tapping it opens the listing;
/// the cross takes it out of the comparison.
class CompareHeader extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const CompareHeader({
    super.key,
    required this.property,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return InkWell(
      key: ValueKey('compare-head-${property.id}'),
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 0, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PropertyCover.of(property, size: _cover, radius: 12),
                const Spacer(),
                SizedBox(
                  width: AppMetrics.minHitTarget,
                  height: _cover,
                  child: IconButton(
                    key: ValueKey('compare-remove-${property.id}'),
                    onPressed: onRemove,
                    tooltip: l10n.compareRemove,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: t.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              property.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: t.textPrimary),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: PropertyStatusChip(status: property.status),
            ),
          ],
        ),
      ),
    );
  }
}
