import 'package:real_estate_crm/core/models/document_models.dart';

abstract class DocumentsEvent {}

class DocumentsLoadEvent extends DocumentsEvent {}

/// Asks for a file and, if one is chosen, attaches it.
class DocumentsUploadEvent extends DocumentsEvent {}

/// Fetches a document's bytes and hands them to the phone.
class DocumentsOpenEvent extends DocumentsEvent {
  final DocumentResponse document;
  DocumentsOpenEvent(this.document);
}

class DocumentsDeleteEvent extends DocumentsEvent {
  final int id;
  DocumentsDeleteEvent(this.id);
}
