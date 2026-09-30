abstract class MessageTemplatesEvent {}

class MessageTemplatesLoadEvent extends MessageTemplatesEvent {}

/// Adds a template when [id] is null, rewrites that one otherwise.
class MessageTemplatesSaveEvent extends MessageTemplatesEvent {
  final int? id;
  final String title;
  final String body;
  MessageTemplatesSaveEvent({this.id, required this.title, required this.body});
}

class MessageTemplatesDeleteEvent extends MessageTemplatesEvent {
  final int id;
  MessageTemplatesDeleteEvent(this.id);
}
