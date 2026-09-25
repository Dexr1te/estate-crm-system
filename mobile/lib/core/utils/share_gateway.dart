import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

class SharedImage {
  final String name;
  final Uint8List bytes;

  const SharedImage({required this.name, required this.bytes});

  String get mimeType {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  String get fileName {
    final ext = switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    return '$name.$ext';
  }
}

enum ShareOutcome { shared, dismissed, failed }

abstract class ShareGateway {
  Future<ShareOutcome> share({
    required String text,
    String? subject,
    List<SharedImage> images = const [],
  });
}

class DeviceShareGateway implements ShareGateway {
  const DeviceShareGateway();

  @override
  Future<ShareOutcome> share({
    required String text,
    String? subject,
    List<SharedImage> images = const [],
  }) async {
    try {
      final result = await SharePlus.instance.share(ShareParams(
        text: text,
        subject: subject,
        files: images.isEmpty
            ? null
            : [
                for (final image in images)
                  XFile.fromData(image.bytes, mimeType: image.mimeType),
              ],
        fileNameOverrides: images.isEmpty
            ? null
            : [for (final image in images) image.fileName],
      ));
      return result.status == ShareResultStatus.dismissed
          ? ShareOutcome.dismissed
          : ShareOutcome.shared;
    } catch (_) {
      return ShareOutcome.failed;
    }
  }
}
