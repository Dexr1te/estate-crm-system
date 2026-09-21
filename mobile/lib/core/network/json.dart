import 'package:dio/dio.dart';

class ApiFormatException implements Exception {
  final String path;

  final String expected;

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

Map<String, dynamic> jsonObject(Response<dynamic> res) {
  final data = res.data;
  if (data is Map<String, dynamic>) return data;
  throw ApiFormatException(
    path: res.requestOptions.path,
    expected: 'a JSON object',
    received: data,
  );
}

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
