import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:real_estate_crm/features/properties/domain/repositories/properties_repository.dart';

class BrochurePhotos {
  const BrochurePhotos._();

  static const int maxPhotos = 5;

  static const int maxSide = 1400;

  static Future<List<Uint8List>> fetch(
    PropertiesRepository repository,
    int propertyId,
  ) async {
    final photos = [...await repository.getPhotos(propertyId)]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final wanted = photos.take(maxPhotos).toList();
    final downloads = await Future.wait([
      for (final photo in wanted)
        repository
            .getPhotoBytes(propertyId, photo.id)
            .then<List<int>?>((b) => b)
            .catchError((Object _) => null),
    ]);
    return [
      for (final bytes in downloads)
        if (bytes != null && bytes.isNotEmpty) Uint8List.fromList(bytes),
    ];
  }

  static Future<List<Uint8List>> prepareInBackground(List<Uint8List> raw) =>
      raw.isEmpty ? Future.value(const []) : Isolate.run(() => prepare(raw));

  static List<Uint8List> prepare(List<Uint8List> raw) {
    final out = <Uint8List>[];
    for (final bytes in raw) {
      if (out.length == maxPhotos) break;
      try {
        final decoded = img.decodeImage(bytes);
        if (decoded == null || decoded.width == 0 || decoded.height == 0) {
          continue;
        }
        final oriented = img.bakeOrientation(decoded);
        final longest =
            oriented.width > oriented.height ? oriented.width : oriented.height;
        final fitted = longest <= maxSide
            ? oriented
            : oriented.width >= oriented.height
                ? img.copyResize(oriented, width: maxSide)
                : img.copyResize(oriented, height: maxSide);
        out.add(img.encodeJpg(fitted, quality: 80));
      } catch (_) {
        continue;
      }
    }
    return out;
  }
}
