import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';

/// The placeholders a message template may use, in the order the editor
/// offers them. The server refuses any other name in braces.
const kTemplatePlaceholders = <String>[
  'client',
  'agent',
  'listing',
  'price',
  'address',
  'link',
];

/// `{client}` and the like: a placeholder as it is typed into a template.
String placeholderToken(String name) => '{$name}';

final _placeholder = RegExp(r'\{([^{}\n]*)\}');
final _spaces = RegExp(r'[ \t]{2,}');
final _spaceBeforePunctuation = RegExp(r'[ \t]+([,.;:!?])');
final _doubledPunctuation = RegExp(r'([,;:])[ \t]*(?=[,.;:!?])');
final _leadingPunctuation = RegExp(r'^[,;:.!?][ \t]*');
final _blankRuns = RegExp(r'\n{3,}');

/// What each placeholder stands for when writing to [clientName] as
/// [agentName], about [listing] if one was chosen. [link] is the listing's
/// public page, when it has one.
Map<String, String> templateValues({
  required String clientName,
  String? agentName,
  PropertyResponse? listing,
  String? link,
}) {
  final place = listing == null
      ? ''
      : [
          if (listing.address.trim().isNotEmpty) listing.address.trim(),
          if (listing.city != null && listing.city!.trim().isNotEmpty)
            listing.city!.trim(),
        ].join(', ');
  return {
    'client': clientName.trim(),
    'agent': agentName?.trim() ?? '',
    'listing': listing?.title.trim() ?? '',
    'price':
        listing != null && listing.price > 0 ? formatPrice(listing.price) : '',
    'address': place,
    'link': link?.trim() ?? '',
  };
}

/// [body] with its placeholders filled from [values], ready to send.
///
/// Nothing in braces survives: a placeholder with no value — an unknown name,
/// or a listing detail when no listing was chosen — comes out empty. So the
/// text still reads, a line whose known placeholders all came out empty is
/// dropped ("{link}" alone on a line, "Now {price}"), and a line with only
/// some of them empty loses the doubled spaces and stray commas they leave.
/// An unknown name never drops a line: that line is the agent's own words
/// with a slip in braces, not a detail that is missing. Lines without an
/// empty placeholder are left exactly as written. Names are matched without
/// regard to case or spaces inside the braces, as the server accepts them.
String fillTemplate(String body, Map<String, String> values) {
  final out = <String>[];
  for (final line in body.split('\n')) {
    var known = 0;
    var knownEmpty = 0;
    var empty = 0;
    final filled = line.replaceAllMapped(_placeholder, (m) {
      final name = m[1]!.trim().toLowerCase();
      final value = values[name]?.trim() ?? '';
      if (values.containsKey(name)) {
        known++;
        if (value.isEmpty) knownEmpty++;
      }
      if (value.isEmpty) empty++;
      return value;
    });
    if (known > 0 && knownEmpty == known) continue;
    out.add(empty == 0 ? filled : _tidy(filled));
  }
  return out.join('\n').replaceAll(_blankRuns, '\n\n').trim();
}

String _tidy(String line) => line
    .replaceAll(_spaces, ' ')
    .replaceAllMapped(_spaceBeforePunctuation, (m) => m[1]!)
    .replaceAll(_doubledPunctuation, '')
    .trim()
    .replaceFirst(_leadingPunctuation, '');
