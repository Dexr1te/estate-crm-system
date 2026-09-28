import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/features/exports/data/datasources/exports_remote_datasource.dart';
import 'package:real_estate_crm/features/exports/domain/repositories/exports_repository.dart';

class ExportsRepositoryImpl implements ExportsRepository {
  final ExportsRemoteDataSource _remote;
  ExportsRepositoryImpl(this._remote);

  @override
  Future<ExportFile> export(
    ExportKind kind, {
    required ExportFilters filters,
    required String lang,
    required ExportDelimiter delimiter,
  }) =>
      _remote.export(kind, filters: filters, lang: lang, delimiter: delimiter);
}
