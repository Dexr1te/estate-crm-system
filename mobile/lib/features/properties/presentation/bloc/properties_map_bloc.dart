import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/properties/domain/map_area.dart';
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';

/// The filters the list is showing; the map honours the same ones.
class MapFilters extends Equatable {
  final PropertyStatus? status;
  final PropertyType? type;
  final String? search;

  const MapFilters({this.status, this.type, this.search});

  @override
  List<Object?> get props => [status, type, search];
}

abstract class PropertiesMapEvent {}

/// The camera settled on a new rectangle (the screen debounces the moves).
class MapAreaChanged extends PropertiesMapEvent {
  final MapArea area;
  MapAreaChanged(this.area);
}

class MapFiltersChanged extends PropertiesMapEvent {
  final MapFilters filters;
  MapFiltersChanged(this.filters);
}

class MapRetry extends PropertiesMapEvent {}

enum MapLoad { idle, loading, loaded, failed }

class PropertiesMapState extends Equatable {
  final MapLoad load;
  final List<PropertyResponse> listings;

  /// Listings under the same filters with no pin; null until counted.
  final int? unpinnedCount;

  /// The rectangle held more than the map draws at once.
  final bool capped;
  final ApiFailure? failure;

  const PropertiesMapState({
    this.load = MapLoad.idle,
    this.listings = const [],
    this.unpinnedCount,
    this.capped = false,
    this.failure,
  });

  PropertiesMapState copyWith({
    MapLoad? load,
    List<PropertyResponse>? listings,
    int? unpinnedCount,
    bool? capped,
    ApiFailure? failure,
  }) =>
      PropertiesMapState(
        load: load ?? this.load,
        listings: listings ?? this.listings,
        unpinnedCount: unpinnedCount ?? this.unpinnedCount,
        capped: capped ?? this.capped,
        failure: failure,
      );

  @override
  List<Object?> get props => [load, listings, unpinnedCount, capped, failure];
}

/// What the map draws: the listings inside the visible rectangle under the
/// list's filters, at most [cap] of them, and how many cannot be drawn at all
/// for want of a pin.
class PropertiesMapBloc extends Bloc<PropertiesMapEvent, PropertiesMapState> {
  final PropertiesRepository _repo;

  /// No clustering: past this many pins in view the map asks for a zoom.
  static const cap = 200;

  MapArea? _area;
  MapFilters _filters;
  int _ticket = 0;

  PropertiesMapBloc(this._repo, {MapFilters filters = const MapFilters()})
      : _filters = filters,
        super(const PropertiesMapState()) {
    on<MapAreaChanged>((e, emit) async {
      if (e.area == _area && state.load == MapLoad.loaded) return;
      _area = e.area;
      await _fetchArea(emit);
    });
    on<MapFiltersChanged>((e, emit) async {
      if (e.filters == _filters) return;
      _filters = e.filters;
      await Future.wait([_fetchArea(emit), _countUnpinned(emit)]);
    });
    on<MapRetry>(
        (e, emit) => Future.wait([_fetchArea(emit), _countUnpinned(emit)]));
    on<_CountUnpinned>((e, emit) => _countUnpinned(emit));
    add(_CountUnpinned());
  }

  MapFilters get filters => _filters;

  Future<void> _fetchArea(Emitter<PropertiesMapState> emit) async {
    final area = _area;
    if (area == null) return;
    final ticket = ++_ticket;
    emit(state.copyWith(load: MapLoad.loading, failure: state.failure));
    try {
      final page = await _repo.getPropertiesInArea(area,
          status: _filters.status,
          type: _filters.type,
          search: _filters.search,
          size: cap);
      if (ticket != _ticket) return;
      emit(state.copyWith(
        load: MapLoad.loaded,
        listings: List.unmodifiable(page.content
            .where((p) => p.latitude != null && p.longitude != null)),
        capped: page.totalElements > page.content.length,
      ));
    } catch (err) {
      if (ticket != _ticket) return;
      emit(state.copyWith(load: MapLoad.failed, failure: ApiFailure.from(err)));
    }
  }

  Future<void> _countUnpinned(Emitter<PropertiesMapState> emit) async {
    try {
      final page = await _repo.getPropertiesWithoutLocation(
          status: _filters.status,
          type: _filters.type,
          search: _filters.search,
          size: 1);
      emit(state.copyWith(
          unpinnedCount: page.totalElements, failure: state.failure));
    } catch (_) {
      // The hint is a nicety; the map itself says when loading failed.
    }
  }
}

class _CountUnpinned extends PropertiesMapEvent {}
