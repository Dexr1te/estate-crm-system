import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class PropertyCard extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final live = property.status != PropertyStatus.SOLD;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.surfaceVariant,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: t.border, width: AppMetrics.borderWidth),
                ),
                child: Icon(propertyTypeIcon(property.type),
                    size: 18, color: live ? t.accent : t.textHint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                    if (property.address.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        property.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 11.5,
                            color: t.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PropertyStatusChip(status: property.status),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 11, bottom: 10),
            child: Container(height: 1, color: t.border),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatPrice(property.price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: t.textPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  propertySpecs(l10n, property),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String propertySpecs(AppLocalizations l10n, PropertyResponse p) {
  final parts = <String>[
    if (p.areaSqm != null)
      l10n.propertiesAreaValue(p.areaSqm!.toStringAsFixed(0)),
    if (p.rooms != null) l10n.propertiesRoomsCount(p.rooms!),
    if (p.floor != null)
      p.totalFloors != null ? '${p.floor}/${p.totalFloors}' : '${p.floor}',
  ];
  if (parts.isEmpty) return propertyTypeLabel(l10n, p.type);
  return parts.join(' · ');
}

/// The placeholder a [PropertyCard] leaves: the type tile, the title and
/// address, the status chip, and the price over the specs across the rule.
///
/// The square tile is what tells a waiting list apart from a list of people —
/// clients arrive behind a round avatar, listings behind a rounded square.
class PropertyCardBone extends StatelessWidget {
  const PropertyCardBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ShimmerBox(width: 44, height: 44, radius: 13),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerBar(widthFactor: 0.58, height: 12),
                      SizedBox(height: 8),
                      ShimmerBar(widthFactor: 0.82, height: 10),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                ShimmerBox(width: 60, height: 22, radius: 11),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 11, bottom: 10),
              child: ShimmerBox(width: double.infinity, height: 1, radius: 0.5),
            ),
            Row(
              children: [
                ShimmerBox(width: 88, height: 15, radius: 7),
                Spacer(),
                ShimmerBox(width: 72, height: 10, radius: 5),
              ],
            ),
          ],
        ),
      );
}
