import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:url_launcher/url_launcher.dart';

/// Where the map's pictures come from: the one place to change it.
///
/// OpenStreetMap's own tile servers are free and need no key, but they are a
/// donated service with a usage policy
/// (https://operations.osmfoundation.org/policies/tiles/): an honest
/// User-Agent, the attribution on screen, and no heavy traffic. An app with
/// many users should move to a commercial provider (MapTiler, Stadia,
/// Thunderforest, ...) by changing [openStreetMap] and, if it has its own,
/// [attribution].
class MapTiles {
  const MapTiles._();

  static const openStreetMap = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// The tile address in use. Tests point it away from OSM along with
  /// [provider]; nothing else should change it at run time.
  static String urlTemplate = openStreetMap;

  /// The app's bundle id; OSM identifies a client by it.
  static const userAgentPackageName = 'com.sultan.estatecrm';

  static const attribution = '© OpenStreetMap contributors';
  static final attributionUrl =
      Uri.parse('https://www.openstreetmap.org/copyright');

  static const maxZoom = 19.0;

  /// What fetches a tile. Tests swap in one that draws nothing, so no test
  /// reaches for the network.
  static TileProvider Function() provider = NetworkTileProvider.new;

  /// The picture layer every map in the app puts first.
  static Widget layer() => TileLayer(
        urlTemplate: urlTemplate,
        userAgentPackageName: userAgentPackageName,
        maxZoom: maxZoom,
        tileProvider: provider(),
      );
}

/// The credit OpenStreetMap asks for, in a corner of every map. Tapping it
/// opens the copyright page.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Align(
      alignment: Alignment.bottomRight,
      child: Semantics(
        link: true,
        child: GestureDetector(
          onTap: () => ContactActions.opener(
              MapTiles.attributionUrl, LaunchMode.externalApplication),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            color: t.surface.withValues(alpha: 0.8),
            child: Text(
              MapTiles.attribution,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 10,
                color: t.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
