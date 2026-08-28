import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';

abstract class DocumentsRepository {
  Future<List<DocumentResponse>> getDocuments(int dealId);

  Future<DocumentResponse> uploadDocument(int dealId, PickedFile file);

  /// The file's bytes. Small enough to hold in memory — the size limit above is
  /// what makes that true.
  Future<List<int>> downloadDocument(int dealId, int documentId);

  Future<void> deleteDocument(int dealId, int documentId);
}
