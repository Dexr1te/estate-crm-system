import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/auth/role_context.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/deal_checklist_bloc.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/deal_checklist_event.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/deal_checklist_state.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_item_row.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_sheets.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_stage_section.dart';
import 'package:real_estate_crm/features/documents/presentation/bloc/documents_bloc.dart';
import 'package:real_estate_crm/features/documents/presentation/bloc/documents_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What the deal still needs, stage by stage: the current stage open, the
/// others folded. Reads a [DealChecklistBloc] and a [DocumentsBloc] above it.
class DealChecklistCard extends StatefulWidget {
  final DealResponse deal;
  const DealChecklistCard({super.key, required this.deal});

  @override
  State<DealChecklistCard> createState() => _DealChecklistCardState();
}

class _DealChecklistCardState extends State<DealChecklistCard> {
  late Set<ChecklistStage> _open = {checklistStageOf(widget.deal.status)};

  @override
  void didUpdateWidget(DealChecklistCard old) {
    super.didUpdateWidget(old);
    if (old.deal.status != widget.deal.status) {
      _open = {checklistStageOf(widget.deal.status)};
    }
  }

  bool get _canEdit =>
      context.isAdminOrManager || widget.deal.agentId == context.currentUserId;

  Future<void> _add() async {
    final bloc = context.read<DealChecklistBloc>();
    final draft = await showChecklistLineSheet(context,
        stage: checklistStageOf(widget.deal.status));
    if (draft == null) return;
    bloc.add(DealChecklistAddEvent(draft.stage, draft.title,
        required: draft.required));
    setState(() => _open = {..._open, draft.stage});
  }

  Future<void> _act(ChecklistItem item, ChecklistRowAction action) async {
    final bloc = context.read<DealChecklistBloc>();
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case ChecklistRowAction.attach:
        final docs = context.read<DocumentsBloc>().state;
        final picked = await showChecklistDocumentPicker(
            context, docs is DocumentsLoaded ? docs.documents : const []);
        if (picked != null) bloc.add(DealChecklistAttachEvent(item, picked.id));
      case ChecklistRowAction.detach:
        bloc.add(DealChecklistAttachEvent(item, null));
      case ChecklistRowAction.delete:
        final ok = await showConfirmDialog(context,
            title: l10n.dealsChecklistDeleteTitle,
            content: l10n.dealsChecklistDeleteBody);
        if (ok) bloc.add(DealChecklistDeleteEvent(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final reached = checklistStageOf(widget.deal.status);

    return BlocConsumer<DealChecklistBloc, DealChecklistState>(
      listenWhen: (_, next) => next.outcome != null,
      listener: (context, state) => showActionOutcome(context, state.outcome),
      builder: (context, state) {
        final counted =
            state.items.where((i) => i.stage.index <= reached.index);
        return AppCard(
          key: const Key('deal-checklist-card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(child: EyebrowLabel(l10n.dealsChecklistTitle)),
                if (state.status == DealChecklistStatus.loaded &&
                    counted.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      l10n.dealsChecklistProgress(
                          counted.where((i) => i.done).length, counted.length),
                      key: const Key('deal-checklist-progress'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          color: t.textHint),
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 8),
              _body(context, state),
              if (_canEdit && state.status == DealChecklistStatus.loaded) ...[
                const SizedBox(height: 10),
                AppGhostButton(
                  key: const Key('deal-checklist-add'),
                  label: l10n.dealsChecklistAdd,
                  height: AppMetrics.buttonHeightInline,
                  onPressed: state.adding ? null : _add,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, DealChecklistState state) {
    final l10n = AppLocalizations.of(context);
    switch (state.status) {
      case DealChecklistStatus.loading:
        return const ChecklistBones();
      case DealChecklistStatus.error:
        return ChecklistLoadError(
          message: l10n.dealsChecklistLoadFailed,
          onRetry: () =>
              context.read<DealChecklistBloc>().add(DealChecklistLoadEvent()),
        );
      case DealChecklistStatus.loaded:
        return Column(children: [
          for (final stage in ChecklistStage.values)
            ChecklistStageSection(
              stage: stage,
              items: state.itemsOf(stage),
              open: _open.contains(stage),
              busyIds: state.busyIds,
              canDelete: _canEdit,
              onHeader: () => setState(() => _open = _open.contains(stage)
                  ? ({..._open}..remove(stage))
                  : {..._open, stage}),
              onToggle: (item) => context
                  .read<DealChecklistBloc>()
                  .add(DealChecklistToggleEvent(item)),
              onAction: _act,
            ),
        ]);
    }
  }
}
