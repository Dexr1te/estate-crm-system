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

  // An upload, a delete and an open can all be under way at once, so each
  // result is built from the list as it stands when that result lands -- not
  // from a copy taken before its request went out, which would bring back a
  // file deleted meanwhile or drop one uploaded meanwhile -- and every state
  // carries what is still running.
  bool _uploading = false;
  final _busyIds = <int>{};

  Set<int> get _busy => Set.unmodifiable(_busyIds);

  DocumentsLoaded _loaded(List<DocumentResponse> documents) =>
      DocumentsLoaded(documents, uploading: _uploading, busyIds: _busy);

  Future<void> _onLoad(DocumentsLoadEvent e, Emitter<DocumentsState> emit) =>
      load(
        emit,
        keepVisible: _current.isNotEmpty,
        skeleton: DocumentsLoading(),
        fetch: () => _repo.getDocuments(dealId),
        onData: _loaded,
        onFailure: DocumentsError.new,
      );

  Future<void> _onUpload(
      DocumentsUploadEvent e, Emitter<DocumentsState> emit) async {
    await once('attach', () async {
      final picked = await _files.pickFile();

      if (picked == null) return;

      if (picked.size > maxDocumentBytes) {
        _emit(
            emit,
            DocumentsProblemReported(LocalProblem.fileTooLarge, _current,
                busyIds: _busy));
        return;
      }

      _uploading = true;
      _emit(emit, _loaded(_current));
      try {
        final created = await _repo.uploadDocument(dealId, picked);
        _uploading = false;

        _emit(
            emit,
            DocumentsActionSuccess(ActionMessage.documentUploaded,
                [..._current.where((d) => d.id != created.id), created],
                busyIds: _busy));
      } catch (err) {
        _uploading = false;
        _emit(
            emit,
            DocumentsActionFailure(ApiFailure.from(err), _current,
                busyIds: _busy));
      }
    });
  }

  Future<void> _onOpen(
      DocumentsOpenEvent e, Emitter<DocumentsState> emit) async {
    final document = e.document;

    await once('open-${document.id}', () async {
      _busyIds.add(document.id);
      _emit(emit, _loaded(_current));
      try {
        final bytes = await _repo.downloadDocument(dealId, document.id);
        final outcome = await _files.openBytes(document.fileName, bytes);
        _busyIds.remove(document.id);
        switch (outcome) {
          case FileOpenOutcome.opened:
            _emit(emit, _loaded(_current));
          case FileOpenOutcome.noApp:
            _emit(
                emit,
                DocumentsProblemReported(LocalProblem.noAppForFile, _current,
                    uploading: _uploading, busyIds: _busy));
          case FileOpenOutcome.failed:
            _emit(
                emit,
                DocumentsProblemReported(LocalProblem.fileOpenFailed, _current,
                    uploading: _uploading, busyIds: _busy));
        }
      } catch (err) {
        _busyIds.remove(document.id);
        _emit(
            emit,
            DocumentsActionFailure(ApiFailure.from(err), _current,
                uploading: _uploading, busyIds: _busy));
      }
    });
  }

  Future<void> _onDelete(
      DocumentsDeleteEvent e, Emitter<DocumentsState> emit) async {
    await once('delete-${e.id}', () async {
      _busyIds.add(e.id);
      _emit(emit, _loaded(_current));
      try {
        await _repo.deleteDocument(dealId, e.id);
        _busyIds.remove(e.id);
        _emit(
            emit,
            DocumentsActionSuccess(ActionMessage.documentDeleted,
                _current.where((d) => d.id != e.id).toList(),
                uploading: _uploading, busyIds: _busy));
      } catch (err) {
        _busyIds.remove(e.id);
        _emit(
            emit,
            DocumentsActionFailure(ApiFailure.from(err), _current,
                uploading: _uploading, busyIds: _busy));
      }
    });
  }

  void _emit(Emitter<DocumentsState> emit, DocumentsState next) {
    if (!isClosed) emit(next);
  }
}
