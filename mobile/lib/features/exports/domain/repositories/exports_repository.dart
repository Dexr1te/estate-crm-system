import 'package:real_estate_crm/core/models/export_models.dart';

abstract class ExportsRepository {
  /// The records of [kind] the caller can see, narrowed by [filters], as a
  /// CSV file with headings in [lang].
  Future<ExportFile> export(
    ExportKind kind, {
    required ExportFilters filters,
    required String lang,
    required ExportDelimiter delimiter,
  });
}
