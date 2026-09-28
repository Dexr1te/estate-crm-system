import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_rows.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The rows a buyer reads in a message — the ones that decide value. The
/// agent, the link views and the fit are for the agent's eyes only.
const _sharedRows = [
  CompareRow.price,
  CompareRow.pricePerSqm,
  CompareRow.area,
  CompareRow.rooms,
  CompareRow.floor,
  CompareRow.place,
];

/// A comparison as plain text, one block per listing, ending with the best
/// price per square metre when a single listing has it. [links] maps a
/// listing's id to its public page.
String composeComparisonMessage(
  AppLocalizations l10n,
  List<ComparedListing> listings,
  DateTime now, {
  Map<int, String> links = const {},
}) {
  final buffer = StringBuffer(l10n.compareShareIntro);
  for (var i = 0; i < listings.length; i++) {
    final listing = listings[i];
    final p = listing.property;
    buffer.write('\n\n${i + 1}. ${p.title.trim()}');
    for (final row in _sharedRows) {
      final value = compareCell(l10n, row, listing, now);
      if (value == kCompareMissing) continue;
      buffer.write('\n${compareRowLabel(l10n, row)}: $value');
    }
    final link = links[p.id];
    if (link != null && link.isNotEmpty) buffer.write('\n$link');
  }
  final best = bestPricePerSqm([for (final l in listings) l.property]);
  if (best != null) {
    buffer.write('\n\n${l10n.compareShareBest(best.title.trim())}');
  }
  return buffer.toString();
}
