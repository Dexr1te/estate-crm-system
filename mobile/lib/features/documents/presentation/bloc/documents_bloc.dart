import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/bloc/collection_bloc.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';
import 'package:real_estate_crm/features/documents/domain/repositories/documents_repository.dart';
import 'package:real_estate_crm/features/documents/presentation/bloc/documents_event.dart';
import 'package:real_estate_crm/features/documents/presentation/bloc/documents_state.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState>
    with SingleFlight, CollectionBloc<DocumentsEvent, DocumentsState> {
  final DocumentsRepository _repo;
  final FileGateway _files;
  final int dealId;

  DocumentsBloc(this._repo, this._files, {required this.dealId})
      : super(DocumentsInitial()) {
    on<DocumentsLoadEvent>(_onLoad);
    on<DocumentsUploadEvent>(_onUpload);
    on<DocumentsOpenEvent>(_onOpen);
    on<DocumentsDeleteEvent>(_onDelete);
  }

  List<DocumentResponse> get _current {
    final s = state;
    return s is DocumentsLoaded ? s.documents : const [];
  }

  Future<void> _onLoad(DocumentsLoadEvent e, Emitter<DocumentsState> emit) =>
      load(
        emit,
        keepVisible: _current.isNotEmpty,
        skeleton: DocumentsLoading(),
        fetch: () => _repo.getDocuments(dealId),
        onData: DocumentsLoaded.new,
        onFailure: DocumentsError.new,
      );

  Future<void> _onUpload(
      DocumentsUploadEvent e, Emitter<DocumentsState> emit) async {
    final rows = _current;

    await once('attach', () async {
      final picked = await _files.pickFile();

      if (picked == null) return;

      if (picked.size > maxDocumentBytes) {
        _emit(emit, DocumentsProblemReported(LocalProblem.fileTooLarge, rows));
        return;
      }

      _emit(emit, DocumentsLoaded(rows, uploading: true));
      try {
        final created = await _repo.uploadDocument(dealId, picked);

        _emit(
            emit,
            DocumentsActionSuccess(
                ActionMessage.documentUploaded, [...rows, created]));
      } catch (err) {
        _emit(emit, DocumentsActionFailure(ApiFailure.from(err), rows));
      }
    });
  }

  Future<void> _onOpen(
      DocumentsOpenEvent e, Emitter<DocumentsState> emit) async {
    final rows = _current;
    final document = e.document;

    await once('open-${document.id}', () async {
      _emit(emit, DocumentsLoaded(rows, busyIds: {document.id}));
      try {
        final bytes = await _repo.downloadDocument(dealId, document.id);
        final outcome = await _files.openBytes(document.fileName, bytes);
        switch (outcome) {
          case FileOpenOutcome.opened:
            _emit(emit, DocumentsLoaded(rows));
          case FileOpenOutcome.noApp:
            _emit(emit,
                DocumentsProblemReported(LocalProblem.noAppForFile, rows));
          case FileOpenOutcome.failed:
            _emit(emit,
                DocumentsProblemReported(LocalProblem.fileOpenFailed, rows));
        }
      } catch (err) {
        _emit(emit, DocumentsActionFailure(ApiFailure.from(err), rows));
      }
    });
  }

  Future<void> _onDelete(
      DocumentsDeleteEvent e, Emitter<DocumentsState> emit) async {
    final rows = _current;

    await once('delete-${e.id}', () async {
      _emit(emit, DocumentsLoaded(rows, busyIds: {e.id}));
      try {
        await _repo.deleteDocument(dealId, e.id);
        _emit(
            emit,
            DocumentsActionSuccess(ActionMessage.documentDeleted,
                rows.where((d) => d.id != e.id).toList()));
      } catch (err) {
        _emit(emit, DocumentsActionFailure(ApiFailure.from(err), rows));
      }
    });
  }

  void _emit(Emitter<DocumentsState> emit, DocumentsState next) {
    if (!isClosed) emit(next);
  }
}
