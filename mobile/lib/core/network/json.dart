import 'package:dio/dio.dart';

/// The body came back in a shape the API contract does not allow.
///
/// Without this check a malformed payload — an HTML error page from a proxy, a
/// `null` where an object was promised, an array of strings — reached
/// `fromJson` and died there as a bare `TypeError`, with no request path in the
/// message and nothing [ApiFailure] could turn into words on screen.
class ApiFormatException implements Exception {
  /// The request path, so a crash report says which endpoint lied.
  final String path;

  /// What the caller was promised, phrased for a log line.
  final String expected;

  /// What actually arrived.
  final Object? received;

  const ApiFormatException({
    required this.path,
    required this.expected,
    this.received,
  });

  @override
  String toString() =>
      'ApiFormatException: $path returned ${received.runtimeType}, '
      'expected $expected';
}

/// The body of [res] as a JSON object.
///
/// Throws [ApiFormatException] rather than letting a bad shape reach `fromJson`.
Map<String, dynamic> jsonObject(Response<dynamic> res) {
  final data = res.data;
  if (data is Map<String, dynamic>) return data;
  throw ApiFormatException(
    path: res.requestOptions.path,
    expected: 'a JSON object',
    received: data,
  );
}

/// The body of [res] as a JSON array of objects.
///
/// Every element is checked, so `list.map(Model.fromJson)` downstream cannot
/// trip over a stray `null` in an otherwise well-formed array.
List<Map<String, dynamic>> jsonArray(Response<dynamic> res) {
  final data = res.data;
  if (data is! List) {
    throw ApiFormatException(
      path: res.requestOptions.path,
      expected: 'a JSON array',
      received: data,
    );
  }
  return data.map((element) {
    if (element is Map<String, dynamic>) return element;
    throw ApiFormatException(
      path: res.requestOptions.path,
      expected: 'a JSON array of objects',
      received: element,
    );
  }).toList();
}
