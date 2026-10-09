/// What a star can be on.
enum StarType {
  client,
  property,
  deal;

  /// The server's name for it, the one `/stars/{type}/{id}` takes.
  String get wire => switch (this) {
        StarType.client => 'CLIENT',
        StarType.property => 'PROPERTY',
        StarType.deal => 'DEAL',
      };

  /// The type the server named, or null for one this build does not know.
  static StarType? parse(Object? raw) => switch (raw) {
        'CLIENT' => StarType.client,
        'PROPERTY' => StarType.property,
        'DEAL' => StarType.deal,
        _ => null,
      };
}

/// One record, by type and id: what a star is on.
class StarKey {
  final StarType type;
  final int id;

  const StarKey(this.type, this.id);

  @override
  bool operator ==(Object other) =>
      other is StarKey && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'StarKey(${type.wire}, $id)';
}

/// A starred record as the list shows it: a client's name and phone, a
/// listing's title and address, a deal's title and client.
class StarredItem {
  final StarType type;
  final int id;
  final String title;
  final String? subtitle;
  final DateTime starredAt;

  const StarredItem({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    required this.starredAt,
  });

  StarKey get key => StarKey(type, id);

  /// Null for a type this build does not know, so a newer server's stars on
  /// something else are left out rather than failing the whole list.
  static StarredItem? tryParse(Map<String, dynamic> json) {
    final type = StarType.parse(json['type']);
    final id = json['id'];
    if (type == null || id is! num) return null;
    final subtitle = json['subtitle'];
    final starredAt = json['starredAt'];
    return StarredItem(
      type: type,
      id: id.toInt(),
      title: json['title'] is String ? json['title'] as String : '',
      subtitle:
          subtitle is String && subtitle.trim().isNotEmpty ? subtitle : null,
      starredAt: (starredAt is String ? DateTime.tryParse(starredAt) : null) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
