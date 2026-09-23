import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

const maxDocumentBytes = 20 * 1024 * 1024;

class PickedFile {
  final String name;
  final String path;
  final int size;

  const PickedFile({
    required this.name,
    required this.path,
    required this.size,
  });
}

enum FileOpenOutcome { opened, noApp, failed }

const maxPhotoBytes = 12 * 1024 * 1024;

const photoPickQuality = 90;

abstract class FileGateway {
  Future<PickedFile?> pickFile();

  Future<List<PickedFile>> pickImages();

  Future<FileOpenOutcome> openBytes(String fileName, List<int> bytes);
}

class DeviceFileGateway implements FileGateway {
  const DeviceFileGateway();

  @override
  Future<PickedFile?> pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.path == null) return null;
    return PickedFile(name: file.name, path: file.path!, size: file.size);
  }

  @override
  Future<List<PickedFile>> pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      compressionQuality: photoPickQuality,
    );
    if (result == null) return const [];
    return [
      for (final file in result.files)
        if (file.path != null)
          PickedFile(name: file.name, path: file.path!, size: file.size),
    ];
  }

  @override
  Future<FileOpenOutcome> openBytes(String fileName, List<int> bytes) async {
    try {
      final dir = await getTemporaryDirectory();

      final safeName = fileName.split(RegExp(r'[/\\]')).last;
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);

      final result = await OpenFile.open(file.path);
      switch (result.type) {
        case ResultType.done:
          return FileOpenOutcome.opened;
        case ResultType.noAppToOpen:
          return FileOpenOutcome.noApp;
        default:
          return FileOpenOutcome.failed;
      }
    } catch (_) {
      return FileOpenOutcome.failed;
    }
  }
}
