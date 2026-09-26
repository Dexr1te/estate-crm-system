import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

/// The point a listing stands at, or null when nobody has dropped a pin.
LatLng? listingPoint(PropertyResponse p) =>
    p.latitude == null || p.longitude == null
        ? null
        : LatLng(p.latitude!, p.longitude!);

/// A listing on the map: its price in a pill with a point underneath. A sold
/// one is muted, so what is still for sale reads first; the selected one
/// takes the screen's accent.
class PricePin extends StatelessWidget {
  static const size = Size(88, 38);

  final PropertyResponse property;
  final bool selected;
  final VoidCallback onTap;

  const PricePin({
    super.key,
    required this.property,
    required this.onTap,
    this.selected = false,
  });

  static Marker marker(PropertyResponse p,
          {required bool selected, required VoidCallback onTap}) =>
      Marker(
        key: ValueKey('map-pin-${p.id}'),
        point: listingPoint(p)!,
        width: size.width,
        height: size.height,
        alignment: Alignment.topCenter,
        child: PricePin(property: p, selected: selected, onTap: onTap),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final sold = property.status == PropertyStatus.SOLD;
    final fill = selected
        ? t.accent
        : sold
            ? t.surfaceVariant
            : t.primary;
    final ink = selected
        ? t.onAccent
        : sold
            ? t.textHint
            : t.onPrimary;

    return Semantics(
      button: true,
      label: '${property.title}, ${formatPrice(property.price)}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
                  border: Border.all(color: t.surface, width: 1.5),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatPrice(property.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ),
            CustomPaint(
              size: const Size(10, 6),
              painter: _PointerPainter(fill),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;
  const _PointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.color != color;
}

/// A plain pin for one listing: the form's dropped point and the detail
/// preview. Its tip sits on the point.
class LocationPin extends StatelessWidget {
  static const size = 40.0;

  const LocationPin({super.key});

  static Marker marker(LatLng point, {Key? key, Widget? child}) => Marker(
        key: key,
        point: point,
        width: size,
        height: size,
        alignment: Alignment.topCenter,
        child: child ?? const LocationPin(),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Icon(Icons.location_on_rounded,
        size: size,
        color: t.primary,
        shadows: [Shadow(color: t.surface, blurRadius: 3)]);
  }
}
