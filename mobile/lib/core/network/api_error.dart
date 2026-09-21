import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/network/json.dart';

enum ApiFailureKind {
  credentials,
  forbidden,
  notFound,
  conflict,
  badRequest,
  server,
  timeout,
  offline,
  unknown,
}

class ApiFailure {
  final ApiFailureKind kind;

  final String? serverText;

  final String? serverCode;

  const ApiFailure(this.kind, {this.serverText, this.serverCode});

  factory ApiFailure.from(Object? error) {
    if (error is ApiFormatException) {
      return const ApiFailure(ApiFailureKind.server);
    }
    if (error is! DioException) return const ApiFailure(ApiFailureKind.unknown);

    final serverText = _serverText(error);
    final status = error.response?.statusCode;

    return ApiFailure(_kindOf(error, status),
        serverText: serverText, serverCode: _serverCode(error));
  }

  static ApiFailureKind _kindOf(DioException error, int? status) {
    switch (status) {
      case 401:
        return ApiFailureKind.credentials;
      case 403:
        return ApiFailureKind.forbidden;
      case 404:
        return ApiFailureKind.notFound;
      case 409:
        return ApiFailureKind.conflict;
      case 400:
        return ApiFailureKind.badRequest;
    }
    if (status != null && status >= 500) return ApiFailureKind.server;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiFailureKind.timeout;
      case DioExceptionType.connectionError:
        return ApiFailureKind.offline;
      default:
        return ApiFailureKind.unknown;
    }
  }

  static String? _serverCode(DioException error) {
    final data = error.response?.data;
    if (data is! Map) return null;
    final code = data['code'];
    return code == null || code.toString().isEmpty ? null : code.toString();
  }

  static String? _serverText(DioException error) {
    final data = error.response?.data;
    if (data is! Map) return null;

    final validation = data['validationErrors'];
    if (validation is Map && validation.isNotEmpty) {
      return validation.values.map((v) => v.toString()).join('\n');
    }

    final message = data['message'] ?? data['error'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    return null;
  }
}
