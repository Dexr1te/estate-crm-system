/// A single page of results.
///
/// The backend's list endpoints are backward-compatible: they return either a
/// plain JSON array (legacy) or a Spring `Page` object
/// (`{content, number, totalPages, totalElements, last}`) once paging/filter
/// params are sent. [PagedResponse.parse] normalizes both shapes so callers
/// never have to branch on the response type.
class PagedResponse<T> {
  final List<T> content;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const PagedResponse({
    required this.content,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  bool get hasMore => !isLast;

  /// Builds a [PagedResponse] from either a Spring `Page` map or a raw list.
  /// [item] parses one element of the `content` array.
  factory PagedResponse.parse(
    dynamic data,
    T Function(Map<String, dynamic>) item, {
    int requestedPage = 0,
  }) {
    if (data is List) {
      // Legacy array response — treat as a single, complete page.
      final content = data.map((e) => item(e as Map<String, dynamic>)).toList();
      return PagedResponse(
        content: content,
        page: 0,
        totalPages: 1,
        totalElements: content.length,
        isLast: true,
      );
    }

    final map = data as Map<String, dynamic>;
    final content = (map['content'] as List)
        .map((e) => item(e as Map<String, dynamic>))
        .toList();
    return PagedResponse(
      content: content,
      page: (map['number'] as int?) ?? requestedPage,
      totalPages: (map['totalPages'] as int?) ?? 1,
      totalElements: (map['totalElements'] as int?) ?? content.length,
      isLast: (map['last'] as bool?) ?? true,
    );
  }
}
