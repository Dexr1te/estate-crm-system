import 'package:real_estate_crm/core/models/models.dart';

abstract class MessageTemplatesRepository {
  /// The agency's templates, oldest first; everybody in the agency may read
  /// them. The server writes the defaults the first time they are needed.
  Future<List<MessageTemplate>> getTemplates();

  /// The manager's, like the two below.
  Future<MessageTemplate> createTemplate(
      {required String title, required String body});

  Future<MessageTemplate> updateTemplate(int id,
      {required String title, required String body});

  Future<void> deleteTemplate(int id);
}
