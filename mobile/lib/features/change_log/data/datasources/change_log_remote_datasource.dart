import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';
import 'package:real_estate_crm/features/change_log/domain/repositories/change_log_repository.dart';

class ChangeLogRemoteDataSource {
  final ApiClient _client;
  ChangeLogRemoteDataSource(this._client);

  static String _segment(ChangeEntityType type) => switch (type) {
        ChangeEntityType.property => 'properties',
        ChangeEntityType.deal => 'deals',
        ChangeEntityType.client => 'clients',
      };

  static String _name(ChangeEntityType type) => switch (type) {
        ChangeEntityType.property => 'PROPERTY',
        ChangeEntityType.deal => 'DEAL',
        ChangeEntityType.client => 'CLIENT',
      };

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  Future<PagedResponse<RecordChange>> history(
      ChangeEntityType type, int id, int page, int size) async {
    final res = await _client.dio.get('/${_segment(type)}/$id/changes',
        queryParameters: {'page': page, 'size': size});
    return PagedResponse.parse(jsonObject(res), RecordChange.fromJson,
        requestedPage: page);
  }

  Future<PagedResponse<RecordChange>> feed(
      ChangeLogFilter filter, int page, int size) async {
    final res = await _client.dio.get('/audit', queryParameters: {
      'page': page,
      'size': size,
      if (filter.entityType != null) 'entityType': _name(filter.entityType!),
      if (filter.actorId != null) 'actorId': filter.actorId,
      if (filter.from != null) 'from': _day(filter.from!),
      if (filter.to != null) 'to': _day(filter.to!),
    });
    return PagedResponse.parse(jsonObject(res), RecordChange.fromJson,
        requestedPage: page);
  }
}
