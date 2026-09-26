/// What a spreadsheet is imported as. [path] is the segment of `/import/{kind}`.
enum ImportKind {
  clients('clients'),
  properties('properties');

  final String path;
  const ImportKind(this.path);
}

const maxImportBytes = 5 * 1024 * 1024;

enum ImportRowStatus { valid, invalid, duplicate }

enum ImportDuplicateSource { agency, file }

/// A field a column can be mapped to, and whether a row needs it.
class ImportTarget {
  final String field;
  final bool required;

  const ImportTarget({required this.field, this.required = false});

  factory ImportTarget.fromJson(Map<String, dynamic> json) => ImportTarget(
        field: (json['field'] ?? '') as String,
        required: json['required'] == true,
      );
}

class ImportDuplicate {
  final ImportDuplicateSource source;
  final int? clientId;
  final String? clientName;
  final int? row;

  const ImportDuplicate({
    required this.source,
    this.clientId,
    this.clientName,
    this.row,
  });

  factory ImportDuplicate.fromJson(Map<String, dynamic> json) =>
      ImportDuplicate(
        source: json['source'] == 'FILE'
            ? ImportDuplicateSource.file
            : ImportDuplicateSource.agency,
        clientId: (json['clientId'] as num?)?.toInt(),
        clientName: json['clientName'] as String?,
        row: (json['row'] as num?)?.toInt(),
      );
}

/// One row of the sheet as the server read it: error codes and normalised
/// values, both keyed by field.
class ImportRowResult {
  final int row;
  final ImportRowStatus status;
  final Map<String, String> errors;
  final Map<String, String> values;
  final ImportDuplicate? duplicate;

  const ImportRowResult({
    required this.row,
    required this.status,
    this.errors = const {},
    this.values = const {},
    this.duplicate,
  });

  factory ImportRowResult.fromJson(Map<String, dynamic> json) =>
      ImportRowResult(
        row: (json['row'] as num?)?.toInt() ?? 0,
        status: switch (json['status']) {
          'INVALID' => ImportRowStatus.invalid,
          'DUPLICATE' => ImportRowStatus.duplicate,
          _ => ImportRowStatus.valid,
        },
        errors: _strings(json['errors']),
        values: _strings(json['values']),
        duplicate: json['duplicate'] is Map<String, dynamic>
            ? ImportDuplicate.fromJson(
                json['duplicate'] as Map<String, dynamic>)
            : null,
      );
}

class ImportPreview {
  final ImportKind kind;
  final List<String> headers;

  /// One entry per header: the field that column fills, or null.
  final List<String?> mapping;
  final List<ImportTarget> targets;
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final int duplicateRows;
  final List<ImportRowResult> problems;
  final bool problemsTruncated;

  const ImportPreview({
    required this.kind,
    required this.headers,
    required this.mapping,
    required this.targets,
    this.totalRows = 0,
    this.validRows = 0,
    this.invalidRows = 0,
    this.duplicateRows = 0,
    this.problems = const [],
    this.problemsTruncated = false,
  });

  factory ImportPreview.fromJson(Map<String, dynamic> json) => ImportPreview(
        kind: json['kind'] == 'properties'
            ? ImportKind.properties
            : ImportKind.clients,
        headers: [
          for (final h in (json['headers'] as List? ?? const [])) '${h ?? ''}'
        ],
        mapping: [
          for (final m in (json['mapping'] as List? ?? const []))
            m is String && m.isNotEmpty ? m : null
        ],
        targets: [
          for (final t in (json['targets'] as List? ?? const []))
            if (t is Map<String, dynamic>) ImportTarget.fromJson(t)
        ],
        totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
        validRows: (json['validRows'] as num?)?.toInt() ?? 0,
        invalidRows: (json['invalidRows'] as num?)?.toInt() ?? 0,
        duplicateRows: (json['duplicateRows'] as num?)?.toInt() ?? 0,
        problems: [
          for (final p in (json['problems'] as List? ?? const []))
            if (p is Map<String, dynamic>) ImportRowResult.fromJson(p)
        ],
        problemsTruncated: json['problemsTruncated'] == true,
      );
}

class ImportResult {
  final ImportKind kind;
  final int totalRows;
  final int created;
  final int skippedDuplicates;
  final int invalid;

  const ImportResult({
    required this.kind,
    this.totalRows = 0,
    this.created = 0,
    this.skippedDuplicates = 0,
    this.invalid = 0,
  });

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(
        kind: json['kind'] == 'properties'
            ? ImportKind.properties
            : ImportKind.clients,
        totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
        created: (json['created'] as num?)?.toInt() ?? 0,
        skippedDuplicates: (json['skippedDuplicates'] as num?)?.toInt() ?? 0,
        invalid: (json['invalid'] as num?)?.toInt() ?? 0,
      );
}

Map<String, String> _strings(Object? raw) => raw is Map
    ? {
        for (final e in raw.entries)
          if (e.value != null) '${e.key}': '${e.value}'
      }
    : const {};
