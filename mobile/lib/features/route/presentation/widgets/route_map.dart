import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:real_estate_crm/core/map/map_tiles.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/route/domain/day_route.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The day on a map: a numbered pin per stop in the order of the schedule,
/// joined by dashed straight lines, since that is all they are.
class RouteMap extends StatelessWidget {
  final List<RouteLeg> legs;
  final RouteLeg? next;
  final DateTime now;
  final double height;

  const RouteMap({
    super.key,
    required this.legs,
    required this.next,
    required this.now,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final points = [for (final l in legs) l.point];
    final options = points.length == 1
        ? MapOptions(initialCenter: points.single, initialZoom: 15)
        : MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: points,
              padding: const EdgeInsets.all(36),
              maxZoom: 16,
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      child: Container(
        height: height,
        color: t.surfaceVariant,
        child: FlutterMap(
          key: const ValueKey('route-map'),
          options: options,
          children: [
            MapTiles.layer(),
            if (points.length > 1)
              PolylineLayer(polylines: [
                Polyline(
                  points: points,
                  strokeWidth: 3,
                  color: t.primary,
                  pattern: StrokePattern.dashed(segments: const [10, 6]),
                ),
              ]),
            MarkerLayer(markers: [
              for (final l in legs)
                Marker(
                  key: ValueKey('route-pin-${l.number}'),
                  point: l.point,
                  width: StopNumber.size,
                  height: StopNumber.size,
                  child: StopNumber(
                    number: l.number,
                    muted: l.stop.isPast(now) || l.stop.isDone,
                    highlighted: identical(l, next),
                  ),
                ),
            ]),
            const MapAttribution(),
          ],
        ),
      ),
    );
  }
}

/// A stop's number in a disc: on the map and at the head of its row, so the
/// two read as one. The next stop takes the accent; one that is over is
/// muted.
class StopNumber extends StatelessWidget {
  static const size = 30.0;

  final int number;
  final bool muted;
  final bool highlighted;

  const StopNumber({
    super.key,
    required this.number,
    this.muted = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final fill = highlighted
        ? t.accent
        : muted
            ? t.surfaceVariant
            : t.primary;
    final ink = highlighted
        ? t.onAccent
        : muted
            ? t.textSecondary
            : t.onPrimary;
    return Semantics(
      label: highlighted ? '$number, ${l10n.routeNext}' : '$number',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: t.surface, width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$number',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ),
      ),
    );
  }
}
