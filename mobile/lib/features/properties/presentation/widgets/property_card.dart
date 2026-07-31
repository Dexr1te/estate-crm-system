import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// List-item card for a property: a 44px rounded type tile (gold while the
/// listing is live, grey once sold), title and address, a status chip, then a
/// hairline divider over price and specs.
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
                  border:
                      Border.all(color: t.border, width: AppMetrics.borderWidth),
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

/// "58 m² · 2 rooms · 5/24" — whichever of those the record actually carries.
String propertySpecs(AppLocalizations l10n, PropertyResponse p) {
  final parts = <String>[
    if (p.areaSqm != null) l10n.propertiesAreaValue(p.areaSqm!.toStringAsFixed(0)),
    if (p.rooms != null) l10n.propertiesRoomsCount(p.rooms!),
    if (p.floor != null)
      p.totalFloors != null ? '${p.floor}/${p.totalFloors}' : '${p.floor}',
  ];
  if (parts.isEmpty) return propertyTypeLabel(l10n, p.type);
  return parts.join(' · ');
}

/// Skeleton matching [PropertyCard]'s footprint.
class PropertyCardBone extends StatelessWidget {
  const PropertyCardBone({super.key});

  @override
  Widget build(BuildContext context) => const ShimmerBox(
      width: double.infinity, height: 108, radius: AppMetrics.radiusMd);
}
