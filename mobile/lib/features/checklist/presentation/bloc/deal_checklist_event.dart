import 'package:real_estate_crm/core/models/models.dart';

abstract class DealChecklistEvent {}

class DealChecklistLoadEvent extends DealChecklistEvent {}

class DealChecklistToggleEvent extends DealChecklistEvent {
  final ChecklistItem item;
  DealChecklistToggleEvent(this.item);
}

/// Links [documentId] to the line, or unlinks whatever is there when null.
class DealChecklistAttachEvent extends DealChecklistEvent {
  final ChecklistItem item;
  final int? documentId;
  DealChecklistAttachEvent(this.item, this.documentId);
}

class DealChecklistAddEvent extends DealChecklistEvent {
  final ChecklistStage stage;
  final String title;
  final bool required;
  DealChecklistAddEvent(this.stage, this.title, {this.required = false});
}

class DealChecklistDeleteEvent extends DealChecklistEvent {
  final ChecklistItem item;
  DealChecklistDeleteEvent(this.item);
}
