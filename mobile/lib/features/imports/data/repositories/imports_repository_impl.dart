import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/features/imports/data/datasources/imports_remote_datasource.dart';
import 'package:real_estate_crm/features/imports/domain/repositories/imports_repository.dart';

class ImportsRepositoryImpl implements ImportsRepository {
  final ImportsRemoteDataSource _remote;
  ImportsRepositoryImpl(this._remote);

  @override
  Future<ImportPreview> preview(
    ImportKind kind,
    PickedFile file, {
    List<String?>? mapping,
  }) =>
      _remote.preview(kind, file, mapping: mapping);

  @override
  Future<ImportResult> commit(
    ImportKind kind,
    PickedFile file, {
    required List<String?> mapping,
    required bool skipDuplicates,
    int? assignToAgentId,
  }) =>
      _remote.commit(kind, file,
          mapping: mapping,
          skipDuplicates: skipDuplicates,
          assignToAgentId: assignToAgentId);

  @override
  Future<List<int>> template(ImportKind kind, String lang) =>
      _remote.template(kind, lang);
}
