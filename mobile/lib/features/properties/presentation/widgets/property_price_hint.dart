import 'dart:async';

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const priceHintDebounce = Duration(milliseconds: 600);

/// What the agency's similar listings go for at the area being typed, under
/// the price field — and nothing at all until there is enough to go on.
class PropertyPriceHint extends StatefulWidget {
  final TextEditingController city;
  final TextEditingController area;
  final TextEditingController rooms;
  final PropertyType type;
  final int? excludeId;
  final ValueChanged<double> onUseMedian;

  const PropertyPriceHint({
    super.key,
    required this.city,
    required this.area,
    required this.rooms,
    required this.type,
    required this.onUseMedian,
    this.excludeId,
  });

  @override
  State<PropertyPriceHint> createState() => _PropertyPriceHintState();
}

class _PropertyPriceHintState extends State<PropertyPriceHint> {
  Timer? _debounce;
  PriceInsightRange? _range;
  String _asked = '';
  int _generation = 0;

  List<TextEditingController> get _inputs =>
      [widget.city, widget.area, widget.rooms];

  @override
  void initState() {
    super.initState();
    for (final c in _inputs) {
      c.addListener(_schedule);
    }
    _schedule();
  }

  @override
  void didUpdateWidget(PropertyPriceHint old) {
    super.didUpdateWidget(old);
    if (old.type != widget.type) _schedule();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in _inputs) {
      c.removeListener(_schedule);
    }
    super.dispose();
  }

  double? _area() {
    final v = double.tryParse(widget.area.text.trim().replaceAll(',', '.'));
    return v != null && v > 0 ? v : null;
  }

  void _schedule() {
    final city = widget.city.text.trim();
    final area = _area();
    final rooms = int.tryParse(widget.rooms.text.trim());
    final key = '$city|${widget.type.name}|$rooms|$area';
    if (key == _asked) return;
    _asked = key;
    _debounce?.cancel();
    final generation = ++_generation;
    if (city.isEmpty || area == null) {
      if (_range != null) setState(() => _range = null);
      return;
    }
    _debounce = Timer(priceHintDebounce, () async {
      PriceInsight? insight;
      try {
        insight = await Injector.propertiesRepository.getPriceInsight(
          city: city,
          type: widget.type,
          rooms: rooms,
          areaSqm: area,
          excludeId: widget.excludeId,
        );
      } catch (_) {
        insight = null;
      }
      if (!mounted || generation != _generation) return;
      final suggested = insight?.suggested;
      setState(() =>
          _range = insight == null || insight.lowConfidence ? null : suggested);
    });
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    if (range == null) return const SizedBox.shrink();
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Padding(
      key: const ValueKey('property-price-hint'),
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.propertiesPriceHintRange(
                  formatPrice(range.low), formatPrice(range.high)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12,
                  color: t.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AppGhostButton(
              key: const ValueKey('property-price-use-median'),
              label: l10n.propertiesPriceHintUseMedian,
              height: AppMetrics.buttonHeightInline,
              fontSize: 12,
              onPressed: () => widget.onUseMedian(range.median),
            ),
          ),
        ],
      ),
    );
  }
}
