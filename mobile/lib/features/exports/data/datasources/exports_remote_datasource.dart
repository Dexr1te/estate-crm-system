import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

class ExportsRemoteDataSource {
  final ApiClient _client;
  ExportsRemoteDataSource(this._client);

  Future<ExportFile> export(
    ExportKind kind, {
    required ExportFilters filters,
    required String lang,
    required ExportDelimiter delimiter,
  }) async {
    try {
      final res = await _client.dio.get<List<int>>(
        '/export/${kind.path}',
        queryParameters: {
          'lang': lang,
          'delimiter': delimiter.param,
          ...filters.toQuery(),
        },
        options: Options(responseType: ResponseType.bytes),
      );
      return ExportFile(
        fileName: ExportFile.fileNameFrom(
            res.headers.value('content-disposition'), '${kind.path}.csv'),
        bytes: Uint8List.fromList(res.data ?? const []),
      );
    } on DioException catch (e) {
      throw _withJsonBody(e);
    }
  }

  /// A refusal arrives as bytes like the file would have; read as JSON, its
  /// code (a row cap, say) reaches [ApiFailure] like any other error's.
  static DioException _withJsonBody(DioException e) {
    final response = e.response;
    final data = response?.data;
    if (response == null || data is! List<int>) return e;
    try {
      final json = jsonDecode(utf8.decode(data));
      return e.copyWith(
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: response.statusCode,
          headers: response.headers,
          data: json,
        ),
      );
    } catch (_) {
      return e;
    }
  }
}
