import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

typedef PickerLoader = Future<List<PickerItem>> Function();

class TaskLinkFields extends StatelessWidget {
  final PickerItem? client;
  final PickerItem? deal;
  final PickerItem? assignee;
  final bool showAssignee;
  final PickerLoader loadClients;
  final PickerLoader loadDeals;
  final PickerLoader loadAgents;
  final ValueChanged<PickerItem?> onClient;
  final ValueChanged<PickerItem?> onDeal;
  final ValueChanged<PickerItem?> onAssignee;

  const TaskLinkFields({
    super.key,
    required this.client,
    required this.deal,
    required this.assignee,
    required this.showAssignee,
    required this.loadClients,
    required this.loadDeals,
    required this.loadAgents,
    required this.onClient,
    required this.onDeal,
    required this.onAssignee,
  });

  Future<void> _pick(
    BuildContext context,
    String title,
    PickerLoader load,
    PickerItem? current,
    ValueChanged<PickerItem?> onPicked, {
    String? whenNone,
  }) async {
    final l10n = AppLocalizations.of(context);
    List<PickerItem> items;
    String empty = whenNone ?? l10n.coreNoResults;
    try {
      items = await load();
    } catch (err) {
      items = const [];
      empty = apiFailureLabel(l10n, ApiFailure.from(err));
    }
    if (!context.mounted) return;
    final picked = await showEntityPicker(
      context,
      title: title,
      items: items,
      selectedId: current?.id,
      searchHint: l10n.tasksSearchHint,
      emptyLabel: empty,
    );
    if (picked != null) onPicked(picked);
  }

  Widget _field(BuildContext context, String label, PickerItem? value,
      VoidCallback onTap, ValueChanged<PickerItem?> onChanged) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return LabelledField(
      label: label,
      child: Row(
        children: [
          Expanded(
            child: PickerField(
              value: value?.title,
              placeholder: l10n.coreNotSelected,
              onTap: onTap,
            ),
          ),
          if (value != null)
            SizedBox(
              width: AppMetrics.minHitTarget,
              height: AppMetrics.minHitTarget,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: l10n.tasksClearLink,
                onPressed: () => onChanged(null),
                icon: Icon(Icons.close_rounded, size: 18, color: t.textHint),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EyebrowLabel(l10n.tasksAbout),
        const SizedBox(height: 10),
        _field(
            context,
            l10n.tasksClient,
            client,
            () =>
                _pick(context, l10n.tasksClient, loadClients, client, onClient),
            onClient),
        const SizedBox(height: 12),
        _field(
            context,
            l10n.tasksDeal,
            deal,
            () => _pick(context, l10n.tasksDeal, loadDeals, deal, onDeal),
            onDeal),
        if (showAssignee) ...[
          const SizedBox(height: 12),
          LabelledField(
            label: l10n.tasksAssignee,
            child: PickerField(
              value: assignee?.title,
              placeholder: l10n.coreNotSelected,
              onTap: () => _pick(
                  context, l10n.tasksAssignee, loadAgents, assignee, onAssignee,
                  whenNone: l10n.tasksNoAgents),
            ),
          ),
        ],
      ],
    );
  }
}
