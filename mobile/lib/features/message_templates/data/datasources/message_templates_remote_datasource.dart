import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/network/json.dart';

class MessageTemplatesRemoteDataSource {
  final ApiClient _client;
  MessageTemplatesRemoteDataSource(this._client);

  static const _path = '/team/message-templates';

  Future<List<MessageTemplate>> getTemplates() async {
    final res = await _client.dio.get(_path);
    return jsonArray(res).map(MessageTemplate.fromJson).toList();
  }

  Future<MessageTemplate> createTemplate(
      {required String title, required String body}) async {
    final res =
        await _client.dio.post(_path, data: {'title': title, 'body': body});
    return MessageTemplate.fromJson(jsonObject(res));
  }

  Future<MessageTemplate> updateTemplate(int id,
      {required String title, required String body}) async {
    final res = await _client.dio
        .put('$_path/$id', data: {'title': title, 'body': body});
    return MessageTemplate.fromJson(jsonObject(res));
  }

  Future<void> deleteTemplate(int id) async {
    await _client.dio.delete('$_path/$id');
  }
}
