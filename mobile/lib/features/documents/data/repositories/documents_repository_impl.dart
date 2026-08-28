import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/features/documents/data/datasources/documents_remote_datasource.dart';
import 'package:real_estate_crm/features/documents/domain/repositories/documents_repository.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final DocumentsRemoteDataSource _remote;
  DocumentsRepositoryImpl(this._remote);

  @override
  Future<List<DocumentResponse>> getDocuments(int dealId) =>
      _remote.getDocuments(dealId);

  @override
  Future<DocumentResponse> uploadDocument(int dealId, PickedFile file) =>
      _remote.uploadDocument(dealId, file);

  @override
  Future<List<int>> downloadDocument(int dealId, int documentId) =>
      _remote.downloadDocument(dealId, documentId);

  @override
  Future<void> deleteDocument(int dealId, int documentId) =>
      _remote.deleteDocument(dealId, documentId);
}
