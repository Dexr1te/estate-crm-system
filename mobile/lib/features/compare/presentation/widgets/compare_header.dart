import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const double _cover = 44;
const double _coverTop = 14;

/// The height every column head takes, so the pinned label column can leave
/// the same room above its first row.
double compareHeaderHeight(TextScaler scaler) =>
    _coverTop + _cover + 8 + scaler.scale(38) + 6 + scaler.scale(15) + 8 + 10;

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
        padding: const EdgeInsets.fromLTRB(6, 0, 0, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _cover - 4 + AppMetrics.minHitTarget / 2,
              height: _coverTop + _cover,
              child: Stack(
                children: [
                  PositionedDirectional(
                    start: 0,
                    top: _coverTop,
                    child: PropertyCover.of(property, size: _cover, radius: 12),
                  ),
                  PositionedDirectional(
                    end: 0,
                    top: 0,
                    width: AppMetrics.minHitTarget,
                    height: AppMetrics.minHitTarget,
                    child: IconButton(
                      key: ValueKey('compare-remove-${property.id}'),
                      onPressed: onRemove,
                      tooltip: l10n.compareRemove,
                      padding: EdgeInsets.zero,
                      icon: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            color: t.surface, shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded,
                            size: 14, color: t.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              property.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: AppType.subhead,
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
