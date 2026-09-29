import 'package:real_estate_crm/core/models/models.dart';

abstract class ChecklistTemplateEvent {}

class ChecklistTemplateLoadEvent extends ChecklistTemplateEvent {}

class ChecklistTemplateAddEvent extends ChecklistTemplateEvent {
  final ChecklistStage stage;
  final String title;
  final bool required;
  ChecklistTemplateAddEvent(this.stage, this.title, {this.required = false});
}

class ChecklistTemplateEditEvent extends ChecklistTemplateEvent {
  final String key;
  final String? title;
  final bool? required;
  ChecklistTemplateEditEvent(this.key, {this.title, this.required});
}

class ChecklistTemplateDeleteEvent extends ChecklistTemplateEvent {
  final String key;
  ChecklistTemplateDeleteEvent(this.key);
}

/// Moves a line within its stage, with [ReorderableListView]'s indices.
class ChecklistTemplateReorderEvent extends ChecklistTemplateEvent {
  final ChecklistStage stage;
  final int oldIndex;
  final int newIndex;
  ChecklistTemplateReorderEvent(this.stage, this.oldIndex, this.newIndex);
}

class ChecklistTemplateSaveEvent extends ChecklistTemplateEvent {}
