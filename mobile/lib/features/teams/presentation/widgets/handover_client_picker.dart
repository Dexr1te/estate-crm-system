import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Picks some of the agent's clients to hand over. Answers the ids ticked,
/// or null when every client is (the whole list, whatever comes later).
/// Dismissing the sheet changes nothing, which is why the answer is wrapped.
Future<({Set<int>? ids})?> showHandoverClientPicker(
  BuildContext context, {
  required List<ClientResponse> clients,
  required Set<int>? picked,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<({Set<int>? ids})>(
    context,
    title: l10n.handoverPickClients,
    builder: (_) => _ClientPicker(clients: clients, picked: picked),
  );
}

class _ClientPicker extends StatefulWidget {
  final List<ClientResponse> clients;
  final Set<int>? picked;

  const _ClientPicker({required this.clients, required this.picked});

  @override
  State<_ClientPicker> createState() => _ClientPickerState();
}

class _ClientPickerState extends State<_ClientPicker> {
  late final Set<int> _ticked =
      widget.picked ?? {for (final c in widget.clients) c.id};

  bool get _all => _ticked.length == widget.clients.length;

  void _toggle(int id) => setState(() {
        if (!_ticked.remove(id)) _ticked.add(id);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    if (widget.clients.isEmpty) {
      return EmptyState(
          icon: Icons.people_outline_rounded, title: l10n.handoverNoClients);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _all
                    ? l10n.handoverAllClients
                    : l10n.handoverSomeClients(_ticked.length),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    color: t.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AppGhostButton(
                key: const Key('handover-pick-toggle-all'),
                label: _all ? l10n.handoverPickNone : l10n.handoverPickAll,
                height: AppMetrics.buttonHeightInline,
                fontSize: 12,
                onPressed: () => setState(() {
                  if (_all) {
                    _ticked.clear();
                  } else {
                    _ticked.addAll(widget.clients.map((c) => c.id));
                  }
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.clients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final client = widget.clients[i];
              final ticked = _ticked.contains(client.id);
              return AppCard(
                key: ValueKey('handover-client-${client.id}'),
                nested: true,
                radius: AppMetrics.radiusSm,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onTap: () => _toggle(client.id),
                child: Row(
                  children: [
                    Checkbox(
                      value: ticked,
                      onChanged: (_) => _toggle(client.id),
                      activeColor: t.primary,
                      checkColor: t.onPrimary,
                      side: BorderSide(color: t.border, width: 1.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.fullName.trim().isEmpty
                                ? '#${client.id}'
                                : client.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: t.textPrimary),
                          ),
                          if (client.phone != null &&
                              client.phone!.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              client.phone!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  fontSize: 11.5,
                                  color: t.textHint),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        AppFilledButton(
          key: const Key('handover-pick-done'),
          label: l10n.handoverPickDone,
          onPressed: () =>
              Navigator.pop(context, (ids: _all ? null : Set<int>.of(_ticked))),
        ),
      ],
    );
  }
}
