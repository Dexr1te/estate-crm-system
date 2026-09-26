import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:real_estate_crm/core/map/city_centres.dart';
import 'package:real_estate_crm/core/map/map_tiles.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_markers.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A small map in the form to put the listing on: a tap drops the pin, a drag
/// moves it, and it can be taken off again. With no pin it opens on the city.
class PropertyLocationPicker extends StatefulWidget {
  final LatLng? value;
  final String? city;
  final ValueChanged<LatLng?> onChanged;
  final double height;

  const PropertyLocationPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.city,
    this.height = 200,
  });

  @override
  State<PropertyLocationPicker> createState() => _PropertyLocationPickerState();
}

class _PropertyLocationPickerState extends State<PropertyLocationPicker> {
  final _controller = MapController();
  bool _ready = false;

  @override
  void didUpdateWidget(PropertyLocationPicker old) {
    super.didUpdateWidget(old);
    if (_ready && widget.value == null && old.city != widget.city) {
      _controller.move(CityCentres.forCity(widget.city), 12);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final pin = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
          child: Container(
            height: widget.height,
            color: t.surfaceVariant,
            child: FlutterMap(
              key: const ValueKey('location-picker-map'),
              mapController: _controller,
              options: MapOptions(
                initialCenter: pin ?? CityCentres.forCity(widget.city),
                initialZoom: pin == null ? 12 : 15,
                minZoom: 3,
                maxZoom: MapTiles.maxZoom,
                interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                onMapReady: () => _ready = true,
                onTap: (_, point) => widget.onChanged(point),
              ),
              children: [
                MapTiles.layer(),
                if (pin != null)
                  MarkerLayer(markers: [
                    LocationPin.marker(pin,
                        key: const ValueKey('location-picker-pin'),
                        child: _DraggablePin(
                            point: pin, onMoved: widget.onChanged)),
                  ]),
                const MapAttribution(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(l10n.propertiesMapPinHint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary)),
            ),
            if (pin != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: AppGhostButton(
                  key: const ValueKey('location-picker-clear'),
                  label: l10n.propertiesMapPinClear,
                  icon: Icons.close_rounded,
                  height: 36,
                  fontSize: 12.5,
                  onPressed: () => widget.onChanged(null),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// The pin itself follows a finger. It claims the finger the moment it
/// lands, so the map under it does not pan instead; each move is turned back
/// into a point through the map's own camera.
class _DraggablePin extends StatelessWidget {
  final LatLng point;
  final ValueChanged<LatLng?> onMoved;

  const _DraggablePin({required this.point, required this.onMoved});

  @override
  Widget build(BuildContext context) => RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          ImmediateMultiDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                  ImmediateMultiDragGestureRecognizer>(
            () => ImmediateMultiDragGestureRecognizer(debugOwner: this),
            (r) => r.onStart =
                (_) => _PinDrag(MapCamera.of(context), point, onMoved),
          ),
        },
        child: const LocationPin(),
      );
}

class _PinDrag extends Drag {
  final MapCamera camera;
  final ValueChanged<LatLng?> onMoved;
  LatLng point;

  _PinDrag(this.camera, this.point, this.onMoved);

  @override
  void update(DragUpdateDetails details) {
    final at = camera.latLngToScreenOffset(point) + details.delta;
    point = camera.screenOffsetToLatLng(at);
    onMoved(point);
  }
}
