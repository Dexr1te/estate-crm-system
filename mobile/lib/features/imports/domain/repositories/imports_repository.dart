import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';

abstract class ImportsRepository {
  /// Reads [file] without writing anything. With [mapping] left out the
  /// server suggests one from the headings.
  Future<ImportPreview> preview(
    ImportKind kind,
    PickedFile file, {
    List<String?>? mapping,
  });

  /// Writes the valid rows of [file] in one transaction.
  Future<ImportResult> commit(
    ImportKind kind,
    PickedFile file, {
    required List<String?> mapping,
    required bool skipDuplicates,
    int? assignToAgentId,
  });

  /// An empty sheet with the headings an import recognises, in [lang].
  Future<List<int>> template(ImportKind kind, String lang);
}
