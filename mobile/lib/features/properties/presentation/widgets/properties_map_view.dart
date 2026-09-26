import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/map/city_centres.dart';
import 'package:real_estate_crm/core/map/map_tiles.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/domain/map_area.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_map_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_listing_card.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_markers.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/map_status.dart';

/// The listings on a map, loaded for whatever rectangle is on screen under
/// the list's own filters. A tapped pin shows its listing at the bottom.
class PropertiesMapView extends StatefulWidget {
  final MapFilters filters;

  /// Where to open: the first pinned listing the list had, or the city.
  final LatLng? initialCenter;

  /// How long the camera has to rest before the rectangle is asked for.
  final Duration debounce;

  const PropertiesMapView({
    super.key,
    required this.filters,
    this.initialCenter,
    this.debounce = const Duration(milliseconds: 400),
  });

  @override
  State<PropertiesMapView> createState() => _PropertiesMapViewState();
}

class _PropertiesMapViewState extends State<PropertiesMapView> {
  final _repo = Injector.propertiesRepository;
  late final _bloc = PropertiesMapBloc(_repo, filters: widget.filters);
  final _controller = MapController();
  Timer? _settle;
  int? _selectedId;

  @override
  void didUpdateWidget(PropertiesMapView old) {
    super.didUpdateWidget(old);
    if (old.filters != widget.filters) {
      _bloc.add(MapFiltersChanged(widget.filters));
    }
  }

  @override
  void dispose() {
    _settle?.cancel();
    _bloc.close();
    _controller.dispose();
    super.dispose();
  }

  void _askFor(MapCamera camera) {
    final b = camera.visibleBounds;
    _bloc.add(MapAreaChanged(
        MapArea(south: b.south, north: b.north, west: b.west, east: b.east)));
  }

  void _moved(MapCamera camera, bool hasGesture) {
    _settle?.cancel();
    _settle = Timer(widget.debounce, () {
      if (mounted) _askFor(camera);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<PropertiesMapBloc, PropertiesMapState>(
        builder: (context, state) {
          final selected = state.listings
              .where((p) => p.id == _selectedId)
              .cast<PropertyResponse?>()
              .firstWhere((_) => true, orElse: () => null);
          final unpinned = state.unpinnedCount ?? 0;
          return Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: t.surfaceVariant,
                  child: FlutterMap(
                    key: const ValueKey('properties-map'),
                    mapController: _controller,
                    options: MapOptions(
                      initialCenter: widget.initialCenter ?? CityCentres.almaty,
                      initialZoom: 12,
                      minZoom: 3,
                      maxZoom: MapTiles.maxZoom,
                      interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                      onMapReady: () => _askFor(_controller.camera),
                      onPositionChanged: _moved,
                      onTap: (_, __) => setState(() => _selectedId = null),
                    ),
                    children: [
                      MapTiles.layer(),
                      MarkerLayer(
                        markers: [
                          // Sold underneath, the chosen one on top.
                          for (final p in _drawOrder(state.listings))
                            PricePin.marker(p,
                                selected: p.id == _selectedId,
                                onTap: () =>
                                    setState(() => _selectedId = p.id)),
                        ],
                      ),
                      const MapAttribution(),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Center(
                    child: MapStatus(
                        state: state,
                        onRetry: () {
                          _bloc.add(MapRetry());
                        })),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 22,
                child: selected != null
                    ? MapListingCard(
                        property: selected,
                        onTap: () => context.go('/properties/${selected.id}'),
                      )
                    : unpinned > 0
                        ? UnpinnedHint(
                            count: unpinned,
                            repository: _repo,
                            filters: _bloc.filters,
                          )
                        : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PropertyResponse> _drawOrder(List<PropertyResponse> listings) {
    bool sold(PropertyResponse p) => p.status == PropertyStatus.SOLD;
    final rest = listings.where((p) => p.id != _selectedId);
    return [
      ...rest.where(sold),
      ...rest.where((p) => !sold(p)),
      ...listings.where((p) => p.id == _selectedId),
    ];
  }
}
