import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

class PropertyCovers {
  static final Map<int, Uint8List?> _cache = {};

  static bool isKnown(int propertyId) => _cache.containsKey(propertyId);

  static Uint8List? held(int propertyId) => _cache[propertyId];

  static Future<Uint8List?> of(int propertyId) async {
    if (_cache.containsKey(propertyId)) return _cache[propertyId];
    try {
      final bytes =
          await Injector.propertiesRepository.getCoverBytes(propertyId);
      final data = bytes.isEmpty ? null : Uint8List.fromList(bytes);
      _cache[propertyId] = data;
      return data;
    } catch (_) {
      _cache[propertyId] = null;
      return null;
    }
  }

  static void forget(int propertyId) => _cache.remove(propertyId);

  static void clear() => _cache.clear();
}

class PropertyCover extends StatelessWidget {
  final int propertyId;
  final PropertyType? type;
  final double size;
  final double radius;
  final bool live;

  const PropertyCover({
    super.key,
    required this.propertyId,
    required this.size,
    this.type,
    this.radius = 13,
    this.live = true,
  });

  PropertyCover.of(
    PropertyResponse property, {
    super.key,
    required this.size,
    this.radius = 13,
  })  : propertyId = property.id,
        type = property.type,
        live = property.status != PropertyStatus.SOLD;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: PropertyCovers.of(propertyId),
      initialData: PropertyCovers.held(propertyId),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return _TypeTile(type: type, size: size, radius: radius, live: live);
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) =>
                _TypeTile(type: type, size: size, radius: radius, live: live),
          ),
        );
      },
    );
  }
}

class _TypeTile extends StatelessWidget {
  final PropertyType? type;
  final double size;
  final double radius;
  final bool live;

  const _TypeTile({
    required this.type,
    required this.size,
    required this.radius,
    required this.live,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: t.border, width: AppMetrics.borderWidth),
      ),
      child: Icon(
        type == null ? Icons.home_work_outlined : propertyTypeIcon(type!),
        size: size * 0.41,
        color: live ? t.accent : t.textHint,
      ),
    );
  }
}
