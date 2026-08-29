import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/network/json.dart';

Response<dynamic> _response(Object? body, {String path = '/clients'}) =>
    Response<dynamic>(requestOptions: RequestOptions(path: path), data: body);

void main() {
  group('jsonObject', () {
    test('hands back a well-formed object', () {
      final data = jsonObject(_response({'id': 1, 'fullName': 'Аружан'}));

      expect(data['id'], 1);
      expect(data['fullName'], 'Аружан');
    });

    test('rejects an array where an object was promised', () {
      expect(
        () => jsonObject(_response(const [])),
        throwsA(isA<ApiFormatException>()),
      );
    });

    test('rejects an empty body', () {
      expect(
        () => jsonObject(_response(null)),
        throwsA(isA<ApiFormatException>()),
      );
    });

    test('rejects a proxy error page', () {
      expect(
        () => jsonObject(_response('<html>502 Bad Gateway</html>')),
        throwsA(isA<ApiFormatException>()),
      );
    });

    test('names the endpoint that lied', () {
      expect(
        () => jsonObject(_response(null, path: '/deals/7')),
        throwsA(
          isA<ApiFormatException>()
              .having((e) => e.path, 'path', '/deals/7')
              .having((e) => e.toString(), 'message', contains('/deals/7')),
        ),
      );
    });
  });

  group('jsonArray', () {
    test('hands back every element typed', () {
      final rows = jsonArray(_response([
        {'id': 1},
        {'id': 2},
      ]));

      expect(rows.map((r) => r['id']), [1, 2]);
    });

    test('an empty array is not an error', () {
      expect(jsonArray(_response(const [])), isEmpty);
    });

    test('rejects an object where a list was promised', () {
      expect(
        () => jsonArray(_response(const {'content': []})),
        throwsA(isA<ApiFormatException>()),
      );
    });

    test('rejects a stray null inside an otherwise fine array', () {
      expect(
        () => jsonArray(_response([
          {'id': 1},
          null,
        ])),
        throwsA(isA<ApiFormatException>()),
      );
    });
  });

  test('a malformed body reads as a server failure, not the catch-all', () {
    final failure = ApiFailure.from(
      const ApiFormatException(path: '/clients', expected: 'a JSON object'),
    );

    expect(failure.kind, ApiFailureKind.server);
  });
}
