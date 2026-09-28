import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_rows.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';

final _now = DateTime(2026, 9, 28, 12);

PropertyResponse _flat(int id,
        {double price = 100000,
        double? area = 50,
        int? floor,
        int? totalFloors,
        DateTime? createdAt}) =>
    PropertyResponse(
        id: id,
        title: 'Flat $id',
        price: price,
        areaSqm: area,
        floor: floor,
        totalFloors: totalFloors,
        createdAt: createdAt);

void main() {
  final AppLocalizations l10n = AppLocalizationsEn();

  group('the numbers behind a row', () {
    test('price per m² is price over area, through formatPrice', () {
      final p = _flat(1, price: 85000, area: 65);
      expect(pricePerSqm(p), closeTo(1307.69, 0.01));
      expect(
          compareCell(l10n, CompareRow.pricePerSqm, ComparedListing(p), _now),
          formatPrice(85000 / 65));
    });

    test('no area or no price means no price per m²', () {
      expect(pricePerSqm(_flat(1, area: null)), isNull);
      expect(pricePerSqm(_flat(1, area: 0)), isNull);
      expect(pricePerSqm(_flat(1, price: 0)), isNull);
    });

    test('days on market count from createdAt to the clock', () {
      expect(daysOnMarket(_flat(1, createdAt: DateTime(2026, 9, 18, 9)), _now),
          10);
      expect(
          daysOnMarket(_flat(1, createdAt: DateTime(2026, 9, 28, 8)), _now), 0);
      expect(daysOnMarket(_flat(1, createdAt: DateTime(2026, 10, 1)), _now), 0);
      expect(daysOnMarket(_flat(1), _now), isNull);
      expect(
          compareCell(l10n, CompareRow.days,
              ComparedListing(_flat(1, createdAt: DateTime(2026, 9, 1))), _now),
          '27 days');
    });

    test('first and last floor are called out', () {
      expect(floorHint(_flat(1, floor: 1, totalFloors: 9)), FloorHint.first);
      expect(floorHint(_flat(1, floor: 9, totalFloors: 9)), FloorHint.last);
      expect(floorHint(_flat(1, floor: 5, totalFloors: 9)), FloorHint.none);
      expect(floorHint(_flat(1)), FloorHint.none);
      expect(
          compareCell(l10n, CompareRow.floor,
              ComparedListing(_flat(1, floor: 9, totalFloors: 9)), _now),
          '9/9 · last floor');
    });

    test('the last price change is signed and dated', () {
      final p = PropertyResponse(
          id: 1,
          price: 95000,
          previousPrice: 100000,
          priceChangedAt: DateTime(2026, 9, 3));
      expect(
          compareCell(l10n, CompareRow.priceChange, ComparedListing(p), _now),
          '−${formatPrice(5000)} · ${formatDate(DateTime(2026, 9, 3))}');
    });

    test('a missing value reads as a dash', () {
      const bare = PropertyResponse(id: 1);
      for (final row in [
        CompareRow.price,
        CompareRow.pricePerSqm,
        CompareRow.area,
        CompareRow.rooms,
        CompareRow.floor,
        CompareRow.place,
        CompareRow.agent,
        CompareRow.days,
        CompareRow.priceChange,
        CompareRow.linkViews,
        CompareRow.fit,
      ]) {
        expect(compareCell(l10n, row, const ComparedListing(bare), _now), '—',
            reason: row.name);
      }
    });
  });

  group('best value', () {
    test('lowest price, lowest price per m², largest area', () {
      final a = _flat(1, price: 100000, area: 50); // 2000/m²
      final b = _flat(2, price: 120000, area: 80); // 1500/m²
      final c = _flat(3, price: 150000, area: 70);
      expect(bestIds([a, b, c], BestBy.lowestPrice), {1});
      expect(bestIds([a, b, c], BestBy.lowestPricePerSqm), {2});
      expect(bestIds([a, b, c], BestBy.largestArea), {2});
    });

    test('ties are all marked, but an all-equal row marks nothing', () {
      final a = _flat(1, price: 100000);
      final b = _flat(2, price: 100000);
      final c = _flat(3, price: 130000);
      expect(bestIds([a, b, c], BestBy.lowestPrice), {1, 2});
      expect(bestIds([a, b], BestBy.lowestPrice), isEmpty);
    });

    test('one known value is nothing to compare against', () {
      final a = _flat(1, area: null);
      final b = _flat(2, area: 60);
      expect(bestIds([a, b], BestBy.largestArea), isEmpty);
      expect(bestPricePerSqm([a, b]), isNull);
    });
  });

  group('the fit and the rows shown', () {
    test('the buyer fit comes from the matches', () {
      final matches = [
        PropertyMatch(property: _flat(1)),
        PropertyMatch(property: _flat(2), overBudget: true),
      ];
      expect(buyerFit(1, matches), BuyerFit.matches);
      expect(buyerFit(2, matches), BuyerFit.overBudget);
      expect(buyerFit(3, matches), BuyerFit.outside);
    });

    test('link views and fit rows only when something is known', () {
      final plain = [ComparedListing(_flat(1)), ComparedListing(_flat(2))];
      expect(rowsFor(plain), isNot(contains(CompareRow.linkViews)));
      expect(rowsFor(plain), isNot(contains(CompareRow.fit)));
      final rich = [
        ComparedListing(_flat(1), linkViews: 4, fit: BuyerFit.matches),
        ComparedListing(_flat(2)),
      ];
      expect(
          rowsFor(rich), containsAll([CompareRow.linkViews, CompareRow.fit]));
    });
  });

  group('ids in the location', () {
    test('parsing keeps order, drops junk and repeats, stops at four', () {
      expect(parseCompareIds('3,1,x,3,,-2,7,9,11'), [3, 1, 7, 9]);
      expect(parseCompareIds(null), isEmpty);
    });

    test('the location carries the ids and the client', () {
      expect(compareLocation([1, 2]), '/compare?ids=1,2');
      expect(compareLocation([1, 2, 3, 4, 5], clientId: 7),
          '/compare?ids=1,2,3,4&client=7');
    });
  });
}
