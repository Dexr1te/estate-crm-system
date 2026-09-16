import 'package:dio/dio.dart';
import 'package:real_estate_crm/core/network/json.dart';

/// Why a request failed, in terms the app can put words to.
///
/// The wording lives in `apiFailureLabel` rather than here: this layer has no
/// localizations, and a failure travels through a bloc — which has no context
/// to resolve them with — before anything shows it.
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

/// A failed request, carried from the repository to whatever puts it on screen.
class ApiFailure {
  final ApiFailureKind kind;

  /// What the backend itself said, when it said anything.
  ///
  /// Kept verbatim and preferred over our own wording: it is the only thing
  /// that can explain a rule the app does not know about — "the primary admin
  /// account cannot be deleted", a validation message naming the field. The
  /// cost is that these arrive in the backend's language.
  final String? serverText;

  /// The backend's machine-readable reason, when it named one — EMAIL_NOT_VERIFIED,
  /// TEAM_REQUIRED, ALREADY_IN_TEAM. Unlike [serverText] this is stable enough to
  /// branch on, which is how the app knows to open the code screen rather than
  /// just complain.
  final String? serverCode;

  const ApiFailure(this.kind, {this.serverText, this.serverCode});

  factory ApiFailure.from(Object? error) {
    // A body we cannot parse is the backend's fault, not the connection's, so
    // it reads as a server error rather than the catch-all.
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
