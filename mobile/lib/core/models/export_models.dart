import 'dart:typed_data';

/// What a spreadsheet is exported from. [path] is the segment of
/// `/export/{kind}`.
enum ExportKind {
  clients('clients'),
  properties('properties'),
  deals('deals');

  final String path;
  const ExportKind(this.path);
}

/// How the cells of a row are separated. Excel in Russian and Kazakh splits a
/// double-clicked file on semicolons, because the comma is the decimal point
/// there; English Excel splits on commas.
enum ExportDelimiter {
  comma('comma'),
  semicolon('semicolon');

  final String param;
  const ExportDelimiter(this.param);

  static ExportDelimiter forLanguage(String languageCode) =>
      languageCode == 'en' ? comma : semicolon;
}

/// The list filters an export narrows by: whatever the list on screen is
/// filtered by when Export is tapped. Enum values travel as their names.
class ExportFilters {
  final String? type;
  final String? status;
  final String? source;
  final String? search;
  final DateTime? createdFrom;

  /// Clients carrying every one of these tags. Travels as one comma-separated
  /// value: a tag never holds a comma.
  final List<String> tags;

  /// Clients who reached the agency this way: a `LeadSource` name.
  final String? leadSource;

  const ExportFilters({
    this.type,
    this.status,
    this.source,
    this.search,
    this.createdFrom,
    this.tags = const [],
    this.leadSource,
  });

  static const none = ExportFilters();

  bool get isEmpty =>
      type == null &&
      status == null &&
      source == null &&
      (search == null || search!.trim().isEmpty) &&
      createdFrom == null &&
      tags.isEmpty &&
      leadSource == null;

  Map<String, String> toQuery() => {
        if (type != null) 'type': type!,
        if (status != null) 'status': status!,
        if (source != null) 'source': source!,
        if (search != null && search!.trim().isNotEmpty)
          'search': search!.trim(),
        if (createdFrom != null) 'createdFrom': _date(createdFrom!),
        if (tags.isNotEmpty) 'tags': tags.join(','),
        if (leadSource != null) 'leadSource': leadSource!,
      };

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ExportFilters &&
      other.type == type &&
      other.status == status &&
      other.source == source &&
      other.search == search &&
      other.createdFrom == createdFrom &&
      other.tags.join(',') == tags.join(',') &&
      other.leadSource == leadSource;

  @override
  int get hashCode => Object.hash(
      type, status, source, search, createdFrom, tags.join(','), leadSource);

  @override
  String toString() => 'ExportFilters(${toQuery()})';
}

/// A downloaded export: the file's bytes and the name the server gave it.
class ExportFile {
  final String fileName;
  final Uint8List bytes;

  const ExportFile({required this.fileName, required this.bytes});

  static const mimeType = 'text/csv';

  /// The name out of a `Content-Disposition` header, preferring the RFC 5987
  /// `filename*` form, or [fallback] when there is none.
  static String fileNameFrom(String? disposition, String fallback) {
    if (disposition == null) return fallback;
    final star = RegExp(r"filename\*=UTF-8''([^;]+)", caseSensitive: false)
        .firstMatch(disposition);
    if (star != null) {
      try {
        return Uri.decodeComponent(star.group(1)!.trim());
      } catch (_) {}
    }
    final plain = RegExp(r'filename="?([^";]+)"?', caseSensitive: false)
        .firstMatch(disposition);
    return plain?.group(1)?.trim() ?? fallback;
  }
}
