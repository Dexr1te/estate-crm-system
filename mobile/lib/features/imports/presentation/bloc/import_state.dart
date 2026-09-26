import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';

/// Where the import stands: choosing a file, reading it, looking at what it
/// would bring in (and re-reading it after a column is remapped), writing it,
/// and done.
enum ImportPhase { choosing, reading, preview, remapping, importing, done }

/// A file refused before it is sent anywhere.
enum ImportFileProblem { tooLarge, notCsv }

class ImportState {
  final ImportPhase phase;
  final ImportKind kind;
  final PickedFile? file;
  final ImportPreview? preview;

  /// One entry per column of the file: the field it fills, or null.
  final List<String?> mapping;
  final bool skipDuplicates;

  /// Who the rows go to; null is the person importing.
  final AgentOption? assignee;
  final ImportResult? result;
  final ApiFailure? failure;
  final ImportFileProblem? fileProblem;

  const ImportState({
    this.phase = ImportPhase.choosing,
    this.kind = ImportKind.clients,
    this.file,
    this.preview,
    this.mapping = const [],
    this.skipDuplicates = true,
    this.assignee,
    this.result,
    this.failure,
    this.fileProblem,
  });

  bool get busy =>
      phase == ImportPhase.reading ||
      phase == ImportPhase.remapping ||
      phase == ImportPhase.importing;

  /// Required fields no column is mapped to.
  List<String> get missingRequired {
    final p = preview;
    if (p == null) return const [];
    return [
      for (final t in p.targets)
        if (t.required && !mapping.contains(t.field)) t.field
    ];
  }

  /// Rows the import would create with the options as they stand.
  int get rowsToImport {
    final p = preview;
    if (p == null) return 0;
    return p.validRows + (skipDuplicates ? 0 : p.duplicateRows);
  }

  bool get canImport =>
      phase == ImportPhase.preview &&
      missingRequired.isEmpty &&
      rowsToImport > 0;

  ImportState copyWith({
    ImportPhase? phase,
    ImportKind? kind,
    PickedFile? file,
    ImportPreview? preview,
    List<String?>? mapping,
    bool? skipDuplicates,
    AgentOption? Function()? assignee,
    ImportResult? result,
    ApiFailure? failure,
    ImportFileProblem? fileProblem,
  }) =>
      ImportState(
        phase: phase ?? this.phase,
        kind: kind ?? this.kind,
        file: file ?? this.file,
        preview: preview ?? this.preview,
        mapping: mapping ?? this.mapping,
        skipDuplicates: skipDuplicates ?? this.skipDuplicates,
        assignee: assignee != null ? assignee() : this.assignee,
        result: result ?? this.result,
        // A failure or a refused file is shown once, never carried along.
        failure: failure,
        fileProblem: fileProblem,
      );
}
