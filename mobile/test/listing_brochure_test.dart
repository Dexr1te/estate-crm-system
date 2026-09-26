import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/properties/brochure/brochure_photos.dart';
import 'package:real_estate_crm/features/properties/brochure/listing_brochure.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Uint8List pngPhoto({int width = 64, int height = 48}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(40, 80, 140));
  return img.encodePng(image);
}

/// Runs [body] and hands back what the PDF library printed — it prints, in
/// debug, every character none of the fonts can draw.
Future<(T, List<String>)> capturePrints<T>(Future<T> Function() body) async {
  final printed = <String>[];
  final result = await runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, line) => printed.add(line),
    ),
  );
  return (result, printed);
}

bool isPdf(Uint8List bytes) =>
    bytes.length > 100 && ascii.decode(bytes.sublist(0, 5)) == '%PDF-';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BrochureFonts fonts;
  final ru = lookupAppLocalizations(const Locale('ru'));
  final kk = lookupAppLocalizations(const Locale('kk'));
  final en = lookupAppLocalizations(const Locale('en'));

  const kazakh = 'Қазақстан, Алматы, ул. Абая — әңғөұүһі ӘҢҒӨҰҮҺІ';
  const property = PropertyResponse(
    id: 42,
    title: 'Светлая квартира у парка',
    address: 'Қазақстан, Алматы, ул. Абая, 150',
    city: 'Алматы',
    price: 125000000,
    areaSqm: 84,
    rooms: 3,
    floor: 7,
    totalFloors: 12,
    agentName: 'Айгерим Нұрланқызы',
    description: 'Просторная квартира с видом на горы. Үлкен терезелер.',
  );
  const contact = BrochureContact(
    name: 'Айгерим Нұрланқызы',
    email: 'aigerim@example.kz',
    agency: 'Алтын Үй',
  );

  setUpAll(() async {
    await initializeDateFormatting();
    fonts = await BrochureFonts.load();
  });

  test('the embedded typeface draws Russian and Kazakh letters', () {
    for (final font in [fonts.regular, fonts.medium, fonts.bold]) {
      final glyphs = TtfParser((font as pw.TtfFont).data).charToGlyphIndexMap;
      for (final rune in kazakh.runes) {
        if (rune == 0x20) continue;
        expect(glyphs.containsKey(rune), isTrue,
            reason: 'missing U+${rune.toRadixString(16)}');
      }
    }
  });

  test('a Kazakh address goes through without a missing glyph', () async {
    final (bytes, printed) = await capturePrints(() => ListingBrochure.build(
          property: property.copyWith(title: kazakh),
          l10n: kk,
          fonts: fonts,
          contact: contact,
        ));
    expect(isPdf(bytes), isTrue);
    expect(printed.where((l) => l.contains('Unable to find a font')), isEmpty);
  });

  test('builds with no photos at all', () async {
    final bytes = await ListingBrochure.build(
        property: const PropertyResponse(id: 1), l10n: en, fonts: fonts);
    expect(isPdf(bytes), isTrue);
  });

  test('builds with photos, and leaves out one that is not an image', () async {
    final photos = [
      pngPhoto(width: 300, height: 200),
      Uint8List.fromList([1, 2, 3, 4, 5]),
      for (var i = 0; i < 4; i++) pngPhoto(),
    ];
    final without = await ListingBrochure.build(
        property: property, l10n: ru, fonts: fonts, contact: contact);
    final (bytes, printed) = await capturePrints(() => ListingBrochure.build(
          property: property.copyWith(status: PropertyStatus.SOLD),
          l10n: ru,
          fonts: fonts,
          photos: BrochurePhotos.prepare(photos),
          contact: contact,
        ));
    expect(isPdf(bytes), isTrue);
    expect(bytes.length, greaterThan(without.length));
    expect(printed.where((l) => l.contains('Unable to find a font')), isEmpty);
    final out = Platform.environment['BROCHURE_SAMPLE'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });

  test('a photo that fails to decode is skipped, the rest are kept', () {
    final prepared = BrochurePhotos.prepare([
      Uint8List.fromList(List.filled(64, 7)),
      pngPhoto(width: 3000, height: 1500),
      pngPhoto(),
    ]);
    expect(prepared, hasLength(2));
    final big = img.decodeJpg(prepared.first)!;
    expect(big.width, BrochurePhotos.maxSide);
    expect(big.height, 700);
  });

  test('a very long description is capped at a word', () async {
    final long = List.filled(2000, 'слово').join(' ');
    final capped = ListingBrochure.capDescription(long);
    expect(
        capped.length, lessThanOrEqualTo(ListingBrochure.maxDescription + 1));
    expect(capped, endsWith('слово…'));
    final bytes = await ListingBrochure.build(
        property: property.copyWith(description: long), l10n: ru, fonts: fonts);
    expect(isPdf(bytes), isTrue);
  });

  test('the file name carries the id and a transliterated title', () {
    expect(ListingBrochure.fileName(property),
        'listing-42-svetlaya-kvartira-u-parka.pdf');
    expect(ListingBrochure.fileName(const PropertyResponse(id: 7, title: '!!')),
        'listing-7.pdf');
    expect(
        ListingBrochure.fileName(
            const PropertyResponse(id: 3, title: 'Sunny flat, 2BR')),
        'listing-3-sunny-flat-2br.pdf');
  });
}
