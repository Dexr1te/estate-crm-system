import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What a missing value reads as, in a cell and in a shared message.
const String kCompareMissing = '—';

/// One column of the comparison: the listing and what is known about it
/// beyond the listing itself.
class ComparedListing {
  final PropertyResponse property;

  /// How many times its public link was opened; null when that was not
  /// available.
  final int? linkViews;

  /// How it fits the buyer the comparison was opened for; null without one.
  final BuyerFit? fit;

  const ComparedListing(this.property, {this.linkViews, this.fit});
}

enum CompareRow {
  price,
  pricePerSqm,
  area,
  rooms,
  floor,
  type,
  place,
  agent,
  days,
  priceChange,
  linkViews,
  fit,
}

/// The rows worth showing for [listings]: link views only when at least one
/// is known, the buyer's fit only when a buyer is in play.
List<CompareRow> rowsFor(List<ComparedListing> listings) {
  final views = listings.any((l) => l.linkViews != null);
  final fit = listings.any((l) => l.fit != null);
  return [
    for (final row in CompareRow.values)
      if ((row != CompareRow.linkViews || views) &&
          (row != CompareRow.fit || fit))
        row,
  ];
}

String compareRowLabel(AppLocalizations l10n, CompareRow row) => switch (row) {
      CompareRow.price => l10n.compareRowPrice,
      CompareRow.pricePerSqm => l10n.compareRowPricePerSqm,
      CompareRow.area => l10n.compareRowArea,
      CompareRow.rooms => l10n.compareRowRooms,
      CompareRow.floor => l10n.compareRowFloor,
      CompareRow.type => l10n.compareRowType,
      CompareRow.place => l10n.compareRowPlace,
      CompareRow.agent => l10n.compareRowAgent,
      CompareRow.days => l10n.compareRowDays,
      CompareRow.priceChange => l10n.compareRowPriceChange,
      CompareRow.linkViews => l10n.compareRowLinkViews,
      CompareRow.fit => l10n.compareRowFit,
    };

/// The row a highlight belongs to, if any.
BestBy? bestByFor(CompareRow row) => switch (row) {
      CompareRow.price => BestBy.lowestPrice,
      CompareRow.pricePerSqm => BestBy.lowestPricePerSqm,
      CompareRow.area => BestBy.largestArea,
      _ => null,
    };

String _nonBlank(String? s) =>
    s == null || s.trim().isEmpty ? kCompareMissing : s.trim();

String _floorText(AppLocalizations l10n, PropertyResponse p) {
  final floor = p.floor;
  if (floor == null) return kCompareMissing;
  final base = p.totalFloors != null ? '$floor/${p.totalFloors}' : '$floor';
  return switch (floorHint(p)) {
    FloorHint.first => '$base · ${l10n.compareFirstFloor}',
    FloorHint.last => '$base · ${l10n.compareLastFloor}',
    FloorHint.none => base,
  };
}

String _priceChangeText(PropertyResponse p) {
  final delta = lastPriceDelta(p);
  if (delta == null) return kCompareMissing;
  final sign = delta < 0 ? '−' : '+';
  return '$sign${formatPrice(delta.abs())} · ${formatDate(p.priceChangedAt!)}';
}

String placeOf(PropertyResponse p) => _nonBlank([
      if (p.city != null && p.city!.trim().isNotEmpty) p.city!.trim(),
      if (p.address.trim().isNotEmpty) p.address.trim(),
    ].join(', '));

String fitLabel(AppLocalizations l10n, BuyerFit fit) => switch (fit) {
      BuyerFit.matches => l10n.compareFitMatches,
      BuyerFit.overBudget => l10n.compareFitOverBudget,
      BuyerFit.outside => l10n.compareFitOutside,
    };

/// The text of one cell; [kCompareMissing] when the value is unknown.
String compareCell(
    AppLocalizations l10n, CompareRow row, ComparedListing l, DateTime now) {
  final p = l.property;
  switch (row) {
    case CompareRow.price:
      return p.price > 0 ? formatPrice(p.price) : kCompareMissing;
    case CompareRow.pricePerSqm:
      final perSqm = pricePerSqm(p);
      return perSqm == null ? kCompareMissing : formatPrice(perSqm);
    case CompareRow.area:
      final area = p.areaSqm;
      return area == null || area <= 0
          ? kCompareMissing
          : l10n.propertiesAreaValue(area.toStringAsFixed(0));
    case CompareRow.rooms:
      return p.rooms == null ? kCompareMissing : '${p.rooms}';
    case CompareRow.floor:
      return _floorText(l10n, p);
    case CompareRow.type:
      return propertyTypeLabel(l10n, p.type);
    case CompareRow.place:
      return placeOf(p);
    case CompareRow.agent:
      return _nonBlank(p.agentName);
    case CompareRow.days:
      final days = daysOnMarket(p, now);
      return days == null ? kCompareMissing : l10n.compareDays(days);
    case CompareRow.priceChange:
      return _priceChangeText(p);
    case CompareRow.linkViews:
      return l.linkViews == null ? kCompareMissing : '${l.linkViews}';
    case CompareRow.fit:
      return l.fit == null ? kCompareMissing : fitLabel(l10n, l.fit!);
  }
}
