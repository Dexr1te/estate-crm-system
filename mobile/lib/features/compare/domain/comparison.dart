import 'package:real_estate_crm/core/models/models.dart';

/// How many listings sit side by side. Past four the columns stop being
/// readable on a phone, and a buyer is no longer choosing but browsing.
const int kMaxCompared = 4;

/// Where a flat sits in its building, when that is worth a word: buyers ask
/// about the first and the last floor before anything else.
enum FloorHint { none, first, last }

/// How a listing fits the buyer the comparison was opened for.
enum BuyerFit { matches, overBudget, outside }

/// Price for each square metre, or null when either side is missing.
double? pricePerSqm(PropertyResponse p) {
  final area = p.areaSqm;
  if (area == null || area <= 0 || p.price <= 0) return null;
  return p.price / area;
}

/// Whole days since the listing went up; null when that date is unknown.
int? daysOnMarket(PropertyResponse p, DateTime now) {
  final created = p.createdAt;
  if (created == null) return null;
  final days = now.difference(created).inDays;
  return days < 0 ? 0 : days;
}

FloorHint floorHint(PropertyResponse p) {
  final floor = p.floor;
  if (floor == null) return FloorHint.none;
  if (floor <= 1) return FloorHint.first;
  final total = p.totalFloors;
  if (total != null && total > 1 && floor >= total) return FloorHint.last;
  return FloorHint.none;
}

/// The latest price change, as the signed difference from the old price;
/// null when the price was never changed.
double? lastPriceDelta(PropertyResponse p) {
  final previous = p.previousPrice;
  if (previous == null || p.priceChangedAt == null) return null;
  final delta = p.price - previous;
  return delta == 0 ? null : delta;
}

/// Where a listing stands against the buyer's matches — the listings the
/// server already found fit the requirements.
BuyerFit buyerFit(int propertyId, List<PropertyMatch> matches) {
  for (final m in matches) {
    if (m.property.id == propertyId) {
      return m.overBudget ? BuyerFit.overBudget : BuyerFit.matches;
    }
  }
  return BuyerFit.outside;
}

/// The rows where one listing can be better value than another.
enum BestBy { lowestPrice, lowestPricePerSqm, largestArea }

double? _valueFor(BestBy by, PropertyResponse p) => switch (by) {
      BestBy.lowestPrice => p.price > 0 ? p.price : null,
      BestBy.lowestPricePerSqm => pricePerSqm(p),
      BestBy.largestArea =>
        p.areaSqm != null && p.areaSqm! > 0 ? p.areaSqm : null,
    };

/// The ids that win [by]. Nothing is marked unless at least two listings have
/// a value and they are not all equal — a highlight on every column says
/// nothing. Ties for the best are all marked.
Set<int> bestIds(List<PropertyResponse> listings, BestBy by) {
  final values = <int, double>{
    for (final p in listings)
      if (_valueFor(by, p) != null) p.id: _valueFor(by, p)!,
  };
  if (values.length < 2) return const {};
  final lowest = by != BestBy.largestArea;
  final best = values.values
      .reduce((a, b) => lowest ? (a < b ? a : b) : (a > b ? a : b));
  final winners = {
    for (final e in values.entries)
      if (e.value == best) e.key,
  };
  return winners.length == values.length ? const {} : winners;
}

/// The listing to name as the best price per square metre in a shared
/// comparison, or null when there is no single winner.
PropertyResponse? bestPricePerSqm(List<PropertyResponse> listings) {
  final ids = bestIds(listings, BestBy.lowestPricePerSqm);
  if (ids.length != 1) return null;
  return listings.firstWhere((p) => p.id == ids.first);
}

/// Parses `1,2,3` into distinct positive ids, in order, at most
/// [kMaxCompared].
List<int> parseCompareIds(String? raw) {
  final ids = <int>[];
  for (final part in (raw ?? '').split(',')) {
    final id = int.tryParse(part.trim());
    if (id != null && id > 0 && !ids.contains(id)) ids.add(id);
    if (ids.length == kMaxCompared) break;
  }
  return ids;
}

/// The location that opens a comparison of [ids], for [clientId] when the
/// buyer's fit should show.
String compareLocation(Iterable<int> ids, {int? clientId}) {
  final list = ids.take(kMaxCompared).join(',');
  return clientId == null
      ? '/compare?ids=$list'
      : '/compare?ids=$list&client=$clientId';
}
