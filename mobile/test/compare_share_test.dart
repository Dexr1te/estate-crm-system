import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/features/compare/data/comparison_tray.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_rows.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_share.dart';
import 'package:real_estate_crm/l10n/app_localizations_en.dart';
import 'package:real_estate_crm/l10n/app_localizations_kk.dart';
import 'package:real_estate_crm/l10n/app_localizations_ru.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime(2026, 9, 28);

const _a = PropertyResponse(
    id: 1,
    title: 'Abay 10',
    city: 'Almaty',
    address: 'Abay 10',
    price: 100000,
    areaSqm: 50,
    rooms: 2,
    floor: 1,
    totalFloors: 9,
    agentName: 'Dana');
const _b = PropertyResponse(
    id: 2, title: 'Satpaev 5', price: 120000, areaSqm: 80, rooms: 3);

const _listings = [ComparedListing(_a), ComparedListing(_b, linkViews: 37)];

void main() {
  group('the shared comparison', () {
    test('en: a block per flat, the key rows, the best price per m²', () {
      final text =
          composeComparisonMessage(AppLocalizationsEn(), _listings, _now);
      expect(
          text,
          'Here is how the listings compare:\n\n'
          '1. Abay 10\n'
          'Price: ${formatPrice(100000)}\n'
          'Price per m²: ${formatPrice(2000)}\n'
          'Area: 50 m²\n'
          'Rooms: 2\n'
          'Floor: 1/9 · first floor\n'
          'Address: Almaty, Abay 10\n\n'
          '2. Satpaev 5\n'
          'Price: ${formatPrice(120000)}\n'
          'Price per m²: ${formatPrice(1500)}\n'
          'Area: 80 m²\n'
          'Rooms: 3\n\n'
          'Best price per m²: Satpaev 5');
      expect(text, isNot(contains('Dana')),
          reason: 'the agent is not the buyer\'s business');
      expect(text, isNot(contains('Link views')),
          reason: 'nor are the link views');
    });

    test('ru and kk are worded in their own language', () {
      final ru =
          composeComparisonMessage(AppLocalizationsRu(), _listings, _now);
      expect(ru, startsWith('Сравнение объектов:'));
      expect(ru, contains('Цена за м²: ${formatPrice(2000)}'));
      expect(ru, contains('1/9 · первый этаж'));
      expect(ru, endsWith('Лучшая цена за м²: Satpaev 5'));

      final kk =
          composeComparisonMessage(AppLocalizationsKk(), _listings, _now);
      expect(kk, startsWith('Нысандарды салыстыру:'));
      expect(kk, contains('1 м² бағасы: ${formatPrice(1500)}'));
      expect(kk, contains('1/9 · бірінші қабат'));
      expect(kk, endsWith('1 м² ең тиімді бағасы: Satpaev 5'));
    });

    test('links go under their own flat, and only when given', () {
      final withLinks = composeComparisonMessage(
          AppLocalizationsEn(), _listings, _now,
          links: {1: 'https://crm.test/l/1', 2: 'https://crm.test/l/2'});
      expect(withLinks,
          contains('Address: Almaty, Abay 10\nhttps://crm.test/l/1\n\n2.'));
      expect(withLinks, contains('Rooms: 3\nhttps://crm.test/l/2\n\n'));

      final without =
          composeComparisonMessage(AppLocalizationsEn(), _listings, _now);
      expect(without, isNot(contains('https://')));
    });

    test('no single winner, no best line', () {
      const twin =
          PropertyResponse(id: 3, title: 'Twin', price: 100000, areaSqm: 50);
      final text = composeComparisonMessage(AppLocalizationsEn(),
          const [ComparedListing(_a), ComparedListing(twin)], _now);
      expect(text, isNot(contains('Best price')));
    });
  });

  group('the comparison tray', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('holds up to four, and says so on the fifth', () {
      final tray = ComparisonTray(scope: () => null);
      for (final id in [1, 2, 3, 4]) {
        expect(tray.toggle(id), TrayChange.added);
      }
      expect(tray.toggle(5), TrayChange.full);
      expect(tray.ids, [1, 2, 3, 4]);
      expect(tray.toggle(2), TrayChange.removed);
      expect(tray.ids, [1, 3, 4]);
    });

    test('comes back for the same user after a restart', () async {
      final first = ComparisonTray(scope: () => 'u1:t9');
      await first.load();
      first
        ..toggle(4)
        ..toggle(8);
      await Future<void>.delayed(Duration.zero);

      final again = ComparisonTray(scope: () => 'u1:t9');
      await again.load();
      expect(again.ids, [4, 8]);

      final someoneElse = ComparisonTray(scope: () => 'u2:t9');
      await someoneElse.load();
      expect(someoneElse.ids, isEmpty);
    });

    test('an emptied tray is forgotten', () async {
      final tray = ComparisonTray(scope: () => 'u1:t9');
      await tray.load();
      tray
        ..toggle(4)
        ..clear();
      await Future<void>.delayed(Duration.zero);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isNot(contains('compare_tray:u1:t9')));
    });
  });
}
