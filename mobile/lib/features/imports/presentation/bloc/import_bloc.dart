import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/imports/domain/repositories/imports_repository.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_event.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_state.dart';

/// A spreadsheet from picking to imported. Every remapping re-reads the file
/// on the server, so what the preview counts is what the import will do; a
/// reply to an older mapping that arrives late is dropped.
class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ImportsRepository _repo;
  int _generation = 0;

  ImportBloc(this._repo) : super(const ImportState()) {
    on<ImportFileChosen>(_onFileChosen);
    on<ImportColumnMapped>(_onColumnMapped);
    on<ImportSkipDuplicatesChanged>(
        (e, emit) => emit(state.copyWith(skipDuplicates: e.skip)));
    on<ImportAssigneeChanged>(
        (e, emit) => emit(state.copyWith(assignee: () => e.agent)));
    on<ImportCommitRequested>(_onCommit);
    on<ImportRestarted>((e, emit) {
      _generation++;
      emit(ImportState(kind: state.kind));
    });
  }

  static const _csvExtensions = ['.csv', '.txt', '.tsv'];

  Future<void> _onFileChosen(
      ImportFileChosen e, Emitter<ImportState> emit) async {
    final name = e.file.name.toLowerCase();
    if (!_csvExtensions.any(name.endsWith)) {
      emit(ImportState(kind: e.kind, fileProblem: ImportFileProblem.notCsv));
      return;
    }
    if (e.file.size > maxImportBytes) {
      emit(ImportState(kind: e.kind, fileProblem: ImportFileProblem.tooLarge));
      return;
    }
    final generation = ++_generation;
    emit(ImportState(phase: ImportPhase.reading, kind: e.kind, file: e.file));
    try {
      final preview = await _repo.preview(e.kind, e.file);
      if (generation != _generation) return;
      emit(state.copyWith(
        phase: ImportPhase.preview,
        preview: preview,
        mapping: preview.mapping,
      ));
    } catch (error) {
      if (generation != _generation) return;
      emit(ImportState(kind: e.kind, failure: ApiFailure.from(error)));
    }
  }

  Future<void> _onColumnMapped(
      ImportColumnMapped e, Emitter<ImportState> emit) async {
    final file = state.file;
    if (file == null || e.column >= state.mapping.length) return;
    // A field fills one column at most: taking it elsewhere frees this one.
    final mapping = [
      for (var i = 0; i < state.mapping.length; i++)
        i == e.column
            ? e.field
            : (state.mapping[i] == e.field ? null : state.mapping[i])
    ];
    final generation = ++_generation;
    emit(state.copyWith(phase: ImportPhase.remapping, mapping: mapping));
    try {
      final preview = await _repo.preview(state.kind, file, mapping: mapping);
      if (generation != _generation) return;
      emit(state.copyWith(phase: ImportPhase.preview, preview: preview));
    } catch (error) {
      if (generation != _generation) return;
      emit(state.copyWith(
          phase: ImportPhase.preview, failure: ApiFailure.from(error)));
    }
  }

  Future<void> _onCommit(
      ImportCommitRequested e, Emitter<ImportState> emit) async {
    final file = state.file;
    if (file == null || !state.canImport) return;
    emit(state.copyWith(phase: ImportPhase.importing));
    try {
      final result = await _repo.commit(
        state.kind,
        file,
        mapping: state.mapping,
        skipDuplicates: state.skipDuplicates,
        assignToAgentId: state.assignee?.id,
      );
      emit(state.copyWith(phase: ImportPhase.done, result: result));
    } catch (error) {
      emit(state.copyWith(
          phase: ImportPhase.preview, failure: ApiFailure.from(error)));
    }
  }
}
