import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/message_templates/data/datasources/message_templates_remote_datasource.dart';
import 'package:real_estate_crm/features/message_templates/domain/repositories/message_templates_repository.dart';

class MessageTemplatesRepositoryImpl implements MessageTemplatesRepository {
  final MessageTemplatesRemoteDataSource _remote;
  MessageTemplatesRepositoryImpl(this._remote);

  @override
  Future<List<MessageTemplate>> getTemplates() => _remote.getTemplates();

  @override
  Future<MessageTemplate> createTemplate(
          {required String title, required String body}) =>
      _remote.createTemplate(title: title, body: body);

  @override
  Future<MessageTemplate> updateTemplate(int id,
          {required String title, required String body}) =>
      _remote.updateTemplate(id, title: title, body: body);

  @override
  Future<void> deleteTemplate(int id) => _remote.deleteTemplate(id);
}
