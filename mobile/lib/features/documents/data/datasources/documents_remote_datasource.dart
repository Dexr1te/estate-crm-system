import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';

class DocumentsRemoteDataSource {
  final ApiClient _client;
  DocumentsRemoteDataSource(this._client);

  String _path(int dealId) => '/deals/$dealId/documents';

  Future<List<DocumentResponse>> getDocuments(int dealId) async {
    final res = await _client.dio.get(_path(dealId));
    return (res.data as List).map((e) => DocumentResponse.fromJson(e)).toList();
  }

  Future<DocumentResponse> uploadDocument(int dealId, PickedFile file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
    });
    final res = await _client.dio.post(
      _path(dealId),
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return DocumentResponse.fromJson(res.data);
  }

  Future<List<int>> downloadDocument(int dealId, int documentId) async {
    final res = await _client.dio.get<List<int>>(
      '${_path(dealId)}/$documentId/content',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? const [];
  }

  Future<void> deleteDocument(int dealId, int documentId) async {
    await _client.dio.delete('${_path(dealId)}/$documentId');
  }
}
