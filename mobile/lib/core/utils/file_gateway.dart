import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

/// The largest file the backend accepts — `spring.servlet.multipart.max-file-size`.
///
/// Checked on this side as well, so a 40 MB video is refused before it is pushed
/// up a phone connection only to come back as a 400.
const maxDocumentBytes = 20 * 1024 * 1024;

/// A file the person chose, as far as the app needs to know it.
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

/// How opening a downloaded file went.
///
/// [noApp] is not a bug: a phone with no PDF reader is a normal phone, and the
/// person needs to be told that rather than shown a failure.
enum FileOpenOutcome { opened, noApp, failed }

/// The seam between the app and the phone's own file handling.
///
/// Everything above it — what may be attached, how big, what the list shows —
/// is ordinary logic and is tested as such. This part cannot be, so it holds no
/// decisions: it picks, it writes, it hands the file over.
abstract class FileGateway {
  /// The file the person chose, or null if they backed out.
  Future<PickedFile?> pickFile();

  /// Writes [bytes] somewhere temporary under [fileName] and asks the phone to
  /// open it with whatever app claims the type.
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
  Future<FileOpenOutcome> openBytes(String fileName, List<int> bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      // The name is the server's copy of what was uploaded, so it can carry a
      // separator on the way back; anything but the last segment is dropped
      // rather than trusted with a path.
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
