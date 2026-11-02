import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));

  test('a Russian count ending in 1 keeps its own number', () {
    expect(ru.documentsCount(1), '1 файл');
    expect(ru.documentsCount(21), '21 файл');
    expect(ru.documentsCount(25), '25 файлов');
    expect(ru.propertiesPhotoCount(31), '31 фото');
    expect(ru.clientsDealCount(101), '101 сделка');
    expect(ru.dashboardAgentDeals(21), '21 сделка');
    expect(ru.dashboardIdleDays(21), 'без движения 21 день');
    expect(ru.meetingsCounter(21), '21 на этой неделе');
    expect(ru.clientsActivitySentListings(21), 'Отправлен 21 объект');
    expect(ru.clientsDeleteCascade(21, 'Айгерим'),
        startsWith('Айгерим и 21 связанная сделка'));
  });

  test('no Russian plural pins the "one" form to exactly 1', () {
    final arb = File('lib/l10n/app_ru.arb').readAsStringSync();
    expect(arb, isNot(contains('=1{')));
  });
}
