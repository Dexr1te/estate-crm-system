import 'package:real_estate_crm/core/models/document_models.dart';

abstract class DocumentsEvent {}

class DocumentsLoadEvent extends DocumentsEvent {}

class DocumentsUploadEvent extends DocumentsEvent {}

class DocumentsOpenEvent extends DocumentsEvent {
  final DocumentResponse document;
  DocumentsOpenEvent(this.document);
}

class DocumentsDeleteEvent extends DocumentsEvent {
  final int id;
  DocumentsDeleteEvent(this.id);
}
