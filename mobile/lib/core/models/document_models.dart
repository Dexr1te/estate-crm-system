/// A file attached to a deal.
///
/// Only what the list needs to show it — the bytes stay on the server until
/// somebody asks to open one.
class DocumentResponse {
  final int id;
  final String fileName;

  /// The extension, lowercased, as the backend recorded it: `pdf`, `jpg`.
  final String fileType;
  final int fileSize;
  final int dealId;
  final int? uploadedById;
  final String uploadedByName;
  final DateTime? uploadedAt;

  const DocumentResponse({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.dealId,
    this.uploadedById,
    this.uploadedByName = '',
    this.uploadedAt,
  });

  factory DocumentResponse.fromJson(Map<String, dynamic> json) =>
      DocumentResponse(
        id: (json['id'] as num).toInt(),
        fileName: (json['fileName'] ?? '') as String,
        fileType: ((json['fileType'] ?? '') as String).toLowerCase(),
        fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
        dealId: (json['dealId'] as num?)?.toInt() ?? 0,
        uploadedById: (json['uploadedById'] as num?)?.toInt(),
        uploadedByName: (json['uploadedByName'] ?? '') as String,
        uploadedAt: json['uploadedAt'] is String
            ? DateTime.tryParse(json['uploadedAt'] as String)
            : null,
      );
}
