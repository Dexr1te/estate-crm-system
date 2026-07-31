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

  factory PagedResponse.parse(
    dynamic data,
    T Function(Map<String, dynamic>) item, {
    int requestedPage = 0,
  }) {
    if (data is List) {
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
