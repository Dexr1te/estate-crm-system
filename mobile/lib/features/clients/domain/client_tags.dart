/// What a typed tag becomes, and when two tags are the same one — the server's
/// rule (`ClientTags` in the backend), repeated here so the editor shows what
/// will be saved before it is.
///
/// A tag is trimmed, a leading `#` is dropped and inner runs of spaces become
/// one. Commas and semicolons separate tags. Two tags are the same when they
/// are equal without case.
abstract final class ClientTags {
  /// Characters in one tag.
  static const maxLength = 32;

  /// Tags on one client.
  static const maxPerClient = 10;

  static final _separators = RegExp('[,;]');
  static final _spaces = RegExp(r'\s+');

  /// The shown form of one typed tag, or null when nothing is left of it.
  static String? display(String raw) {
    var name = raw.replaceAll(_spaces, ' ').trim();
    while (name.startsWith('#')) {
      name = name.substring(1).trimLeft();
    }
    return name.isEmpty ? null : name;
  }

  static String key(String name) => name.toLowerCase();

  /// Every tag in [raw], split on commas and semicolons, without repeats; the
  /// first spelling of each is kept.
  static List<String> split(String raw) {
    final byKey = <String, String>{};
    for (final part in raw.split(_separators)) {
      final name = display(part);
      if (name != null) byKey.putIfAbsent(key(name), () => name);
    }
    return byKey.values.toList();
  }

  static bool tooLong(String name) => name.runes.length > maxLength;

  /// Whether [tags] holds [name] in any case.
  static bool holds(Iterable<String> tags, String name) {
    final k = key(name);
    return tags.any((t) => key(t) == k);
  }
}
