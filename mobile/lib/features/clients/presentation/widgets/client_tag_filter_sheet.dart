import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/domain/client_tags.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The tags on [clients] with how many carry each, most used first — what the
/// list can be filtered by.
List<({String name, int count})> tagCounts(List<ClientSummary> clients) {
  final names = <String, String>{};
  final counts = <String, int>{};
  for (final client in clients) {
    for (final tag in client.tags) {
      final key = ClientTags.key(tag);
      names.putIfAbsent(key, () => tag);
      counts[key] = (counts[key] ?? 0) + 1;
    }
  }
  final result = [
    for (final e in counts.entries) (name: names[e.key]!, count: e.value),
  ]..sort((a, b) => b.count != a.count
      ? b.count.compareTo(a.count)
      : ClientTags.key(a.name).compareTo(ClientTags.key(b.name)));
  return result;
}

/// Picks the tags the list is narrowed to. Resolves to the new selection —
/// empty when cleared — or null when the sheet is dismissed.
Future<Set<String>?> showClientTagFilter(
  BuildContext context, {
  required List<({String name, int count})> available,
  required Set<String> selected,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<Set<String>>(
    context,
    title: l10n.clientsTagFilterTitle,
    subtitle: available.isEmpty ? null : l10n.clientsTagFilterSubtitle,
    builder: (sheet) => ClientTagFilterForm(
      available: available,
      selected: selected,
      onDone: (picked) => Navigator.pop(sheet, picked),
    ),
  );
}

class ClientTagFilterForm extends StatefulWidget {
  final List<({String name, int count})> available;
  final Set<String> selected;
  final ValueChanged<Set<String>> onDone;

  const ClientTagFilterForm({
    super.key,
    required this.available,
    required this.selected,
    required this.onDone,
  });

  @override
  State<ClientTagFilterForm> createState() => _ClientTagFilterFormState();
}

class _ClientTagFilterFormState extends State<ClientTagFilterForm> {
  late final Set<String> _picked = {...widget.selected};

  void _toggle(String name) => setState(() {
        final held = _picked
            .where((p) => ClientTags.key(p) == ClientTags.key(name))
            .toList();
        if (held.isEmpty) {
          _picked.add(name);
        } else {
          _picked.removeAll(held);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    if (widget.available.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          l10n.clientsTagFilterEmpty,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 13,
              height: 1.4,
              color: t.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        FilterPillWrap(pills: [
          for (final tag in widget.available)
            FilterPill(
              key: ValueKey('client-tag-filter-${tag.name}'),
              label: '${tag.name} · ${tag.count}',
              selected: ClientTags.holds(_picked, tag.name),
              onCard: true,
              onTap: () => _toggle(tag.name),
            ),
        ]),
        const SizedBox(height: 22),
        AppFilledButton(
          key: const ValueKey('client-tag-filter-done'),
          label: l10n.clientsTagFilterDone,
          onPressed: () => widget.onDone(_picked),
        ),
        const SizedBox(height: 9),
        AppGhostButton(
          key: const ValueKey('client-tag-filter-clear'),
          label: l10n.clientsTagFilterClear,
          onPressed: () => widget.onDone(const {}),
        ),
      ],
    );
  }
}
