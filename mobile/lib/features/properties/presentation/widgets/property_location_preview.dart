import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:real_estate_crm/core/map/map_tiles.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_markers.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Where the listing stands, on a small still map, and a way to hand the
/// point to the phone's maps app. Only for a listing with a pin.
class PropertyLocationPreview extends StatelessWidget {
  final PropertyResponse property;
  final double height;

  const PropertyLocationPreview(
      {super.key, required this.property, this.height = 150});

  Future<void> _open(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final opened = await ContactActions.directionsTo(
        property.latitude, property.longitude,
        label: property.title);
    if (!opened && context.mounted) {
      showActionUnavailable(context, l10n.propertiesOpenInMapsFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = listingPoint(property);
    if (point == null) return const SizedBox.shrink();
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final place = [property.address, property.city ?? '']
        .where((s) => s.trim().isNotEmpty)
        .join(', ');

    return AppCard(
      key: const ValueKey('property-location'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.propertiesLocation),
          if (place.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(place,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    color: t.textSecondary)),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
            child: Container(
              height: height,
              color: t.surfaceVariant,
              // Still: a scroll over it scrolls the page, a tap opens maps.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _open(context),
                child: IgnorePointer(
                  child: FlutterMap(
                    key: const ValueKey('property-location-map'),
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: 15,
                      interactionOptions:
                          const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      MapTiles.layer(),
                      MarkerLayer(markers: [LocationPin.marker(point)]),
                      const MapAttribution(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppGhostButton(
            key: const ValueKey('property-open-in-maps'),
            label: l10n.propertiesOpenInMaps,
            icon: Icons.map_outlined,
            onPressed: () => _open(context),
          ),
        ],
      ),
    );
  }
}
