import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';

/// Both steps send the file itself; the server keeps nothing between them.
class ImportsRemoteDataSource {
  final ApiClient _client;
  ImportsRemoteDataSource(this._client);

  String _path(ImportKind kind) => '/import/${kind.path}';

  Future<FormData> _form(PickedFile file, Map<String, dynamic> fields) async =>
      FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
        ...fields,
      });

  Future<ImportPreview> preview(
    ImportKind kind,
    PickedFile file, {
    List<String?>? mapping,
  }) async {
    final res = await _client.dio.post(
      '${_path(kind)}/preview',
      data: await _form(file, {
        if (mapping != null) 'mapping': jsonEncode(mapping),
      }),
      options: Options(contentType: 'multipart/form-data'),
    );
    return ImportPreview.fromJson(jsonObject(res));
  }

  Future<ImportResult> commit(
    ImportKind kind,
    PickedFile file, {
    required List<String?> mapping,
    required bool skipDuplicates,
    int? assignToAgentId,
  }) async {
    final res = await _client.dio.post(
      '${_path(kind)}/commit',
      data: await _form(file, {
        'mapping': jsonEncode(mapping),
        'skipDuplicates': '$skipDuplicates',
        if (assignToAgentId != null) 'assignToAgentId': '$assignToAgentId',
      }),
      options: Options(contentType: 'multipart/form-data'),
    );
    return ImportResult.fromJson(jsonObject(res));
  }

  Future<List<int>> template(ImportKind kind, String lang) async {
    final res = await _client.dio.get<List<int>>(
      '${_path(kind)}/template',
      queryParameters: {'lang': lang},
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? const [];
  }
}
