import 'package:equatable/equatable.dart';

/// The rectangle a map is showing, in degrees: what `GET /properties` narrows
/// to with `minLat`/`maxLat`/`minLng`/`maxLng`.
///
/// A [west] edge east of the [east] edge means the rectangle crosses the
/// antimeridian; the server wraps it.
class MapArea extends Equatable {
  final double south;
  final double north;
  final double west;
  final double east;

  const MapArea({
    required this.south,
    required this.north,
    required this.west,
    required this.east,
  });

  /// The query parameters the server reads, clamped onto the globe: a map
  /// zoomed far out reports edges past the poles and past 180 degrees.
  Map<String, Object> toQuery() => {
        'minLat': _clamp(south, 90),
        'maxLat': _clamp(north, 90),
        'minLng': _clamp(west, 180),
        'maxLng': _clamp(east, 180),
      };

  static double _clamp(double value, double limit) =>
      double.parse(value.clamp(-limit, limit).toStringAsFixed(6));

  @override
  List<Object?> get props => [south, north, west, east];

  @override
  String toString() => 'MapArea($south..$north, $west..$east)';
}
