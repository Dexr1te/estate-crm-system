import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  test('a one-room flat reads "1 room", not "1 rooms"', () {
    const flat = PropertyResponse(
        id: 1, areaSqm: 38, rooms: 1, floor: 3, totalFloors: 9);
    expect(propertySpecs(en, flat), '38 m² · 1 room · 3/9');
    expect(propertySpecs(en, flat.copyWith(rooms: 3)), '38 m² · 3 rooms · 3/9');
  });

  test('Russian and Kazakh keep their short room counts', () {
    expect(lookupAppLocalizations(const Locale('ru')).propertiesRoomsCount(1),
        '1 комн.');
    expect(lookupAppLocalizations(const Locale('kk')).propertiesRoomsCount(1),
        '1 бөлме');
  });
}
