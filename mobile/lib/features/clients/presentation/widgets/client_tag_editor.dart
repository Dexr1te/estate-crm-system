import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/domain/client_tags.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/client_tag_chips.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Why typed tags were not all taken.
enum TagProblem { tooLong, limit }

/// [current] with the tags in [typed] added: split on commas, repeats and tags
/// already held dropped, each written the way the agency already writes it
/// when [known] has it. A tag over [ClientTags.maxLength] or past
/// [ClientTags.maxPerClient] is left out and named as the problem.
({List<String> tags, TagProblem? problem}) addTypedTags(
  List<String> current,
  String typed,
  List<ClientTagUsage> known,
) {
  final tags = [...current];
  TagProblem? problem;
  for (final name in ClientTags.split(typed)) {
    if (ClientTags.holds(tags, name)) continue;
    if (ClientTags.tooLong(name)) {
      problem = TagProblem.tooLong;
      continue;
    }
    if (tags.length >= ClientTags.maxPerClient) {
      problem = TagProblem.limit;
      break;
    }
    final agency = known
        .where((k) => ClientTags.key(k.name) == ClientTags.key(name))
        .firstOrNull;
    tags.add(agency?.name ?? name);
  }
  return (tags: tags, problem: problem);
}

/// The tags on the client form: what the client carries, a field to add more
/// (Enter or a comma adds), and the agency's tags in use to pick from, the
/// most used first and narrowed by what is being typed.
class ClientTagEditor extends StatefulWidget {
  final List<String> tags;
  final List<ClientTagUsage> suggestions;
  final ValueChanged<List<String>> onChanged;

  /// Owned by the form, so a tag still in the field is not lost on save.
  final TextEditingController controller;

  const ClientTagEditor({
    super.key,
    required this.tags,
    required this.suggestions,
    required this.onChanged,
    required this.controller,
  });

  /// How many agency tags are offered at once.
  static const maxSuggestions = 8;

  @override
  State<ClientTagEditor> createState() => _ClientTagEditorState();
}

class _ClientTagEditorState extends State<ClientTagEditor> {
  TagProblem? _problem;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTyped);
  }

  @override
  void didUpdateWidget(ClientTagEditor old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onTyped);
      widget.controller.addListener(_onTyped);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTyped);
    super.dispose();
  }

  /// A comma or semicolon closes the tags before it.
  void _onTyped() {
    final text = widget.controller.text;
    final cut = text.lastIndexOf(RegExp('[,;]'));
    if (cut < 0) {
      setState(() {});
      return;
    }
    _add(text.substring(0, cut), rest: text.substring(cut + 1));
  }

  void _add(String typed, {String rest = ''}) {
    final result = addTypedTags(widget.tags, typed, widget.suggestions);
    widget.controller.value = TextEditingValue(
      text: rest,
      selection: TextSelection.collapsed(offset: rest.length),
    );
    setState(() => _problem = result.problem);
    if (result.tags.length != widget.tags.length) {
      widget.onChanged(result.tags);
    }
  }

  void _remove(String tag) {
    setState(() => _problem = null);
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final full = widget.tags.length >= ClientTags.maxPerClient;
    final query = ClientTags.key(widget.controller.text.trim());
    final offered = full
        ? const <ClientTagUsage>[]
        : widget.suggestions
            .where((s) => !ClientTags.holds(widget.tags, s.name))
            .where((s) => query.isEmpty || ClientTags.key(s.name).contains(query))
            .take(ClientTagEditor.maxSuggestions)
            .toList();
    final problem = full ? TagProblem.limit : _problem;
    final note = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11.5,
        height: 1.35,
        color: t.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.clientsTagsHint,
            maxLines: 3, overflow: TextOverflow.ellipsis, style: note),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in widget.tags)
                Semantics(
                  button: true,
                  label: l10n.clientsTagRemove(tag),
                  excludeSemantics: true,
                  child: InkWell(
                    key: ValueKey('client-tag-remove-$tag'),
                    borderRadius: BorderRadius.circular(AppMetrics.radiusPill),
                    onTap: () => _remove(tag),
                    child: ClientTagChip(
                      tag: tag,
                      trailing: Icon(Icons.close_rounded,
                          size: 13, color: t.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                key: const ValueKey('client-tag-field'),
                controller: widget.controller,
                hint: l10n.clientsTagAddHint,
                enabled: !full,
                textInputAction: TextInputAction.done,
                onSubmitted: _add,
              ),
            ),
            const SizedBox(width: 6),
            AppIconTile(
              key: const ValueKey('client-tag-add'),
              // Not a "+": that is QuickAddButton's alone (quick_add_test).
              icon: Icons.keyboard_return_rounded,
              tooltip: l10n.clientsTagAdd,
              onPressed: full ? () {} : () => _add(widget.controller.text),
            ),
          ],
        ),
        if (problem != null) ...[
          const SizedBox(height: 6),
          Text(
            problem == TagProblem.tooLong
                ? l10n.clientsTagTooLong(ClientTags.maxLength)
                : l10n.clientsTagLimit(ClientTags.maxPerClient),
            key: const ValueKey('client-tag-problem'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: note.copyWith(
                color: problem == TagProblem.tooLong
                    ? t.dangerText
                    : t.textSecondary),
          ),
        ],
        if (offered.isNotEmpty) ...[
          const SizedBox(height: 12),
          EyebrowLabel(l10n.clientsTagSuggestions, color: t.textSecondary),
          const SizedBox(height: 8),
          FilterPillWrap(pills: [
            for (final s in offered)
              FilterPill(
                key: ValueKey('client-tag-suggestion-${s.name}'),
                label: s.name,
                selected: false,
                onCard: true,
                onTap: () => _add(s.name),
              ),
          ]),
        ],
      ],
    );
  }
}
