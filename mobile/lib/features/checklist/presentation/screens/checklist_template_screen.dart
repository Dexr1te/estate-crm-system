import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/checklist/domain/checklist_gate.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/checklist_template_bloc.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/checklist_template_event.dart';
import 'package:real_estate_crm/features/checklist/presentation/bloc/checklist_template_state.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_sheets.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/checklist_stage_section.dart';
import 'package:real_estate_crm/features/checklist/presentation/widgets/template_line_row.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The manager edits what every new deal of the agency starts with.
class ChecklistTemplateScreen extends StatelessWidget {
  const ChecklistTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ChecklistTemplateBloc(Injector.checklistRepository)
          ..add(ChecklistTemplateLoadEvent()),
        child: const _TemplateView(),
      );
}

class _TemplateView extends StatelessWidget {
  const _TemplateView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return BlocConsumer<ChecklistTemplateBloc, ChecklistTemplateState>(
      listenWhen: (_, next) => next.outcome != null,
      listener: (context, state) => showActionOutcome(context, state.outcome),
      builder: (context, state) {
        final bloc = context.read<ChecklistTemplateBloc>();
        final loaded = state.status == ChecklistTemplateStatus.loaded;
        return DetailScaffold(
          title: l10n.teamsChecklist,
          bottomAction: loaded
              ? AppFilledButton(
                  key: const Key('template-save'),
                  label: l10n.coreSave,
                  loading: state.saving,
                  onPressed: state.dirty && !state.saving
                      ? () => bloc.add(ChecklistTemplateSaveEvent())
                      : null,
                )
              : null,
          children: [
            Text(
              l10n.teamsChecklistNewDealsOnly,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.45,
                  color: t.textSecondary),
            ),
            if (state.status == ChecklistTemplateStatus.loading)
              const AppCard(child: ChecklistBones()),
            if (state.status == ChecklistTemplateStatus.error)
              AppCard(
                child: ChecklistLoadError(
                  message: l10n.dealsChecklistLoadFailed,
                  onRetry: () => bloc.add(ChecklistTemplateLoadEvent()),
                ),
              ),
            if (loaded)
              for (final stage in ChecklistStage.values)
                _StageEditor(stage: stage, lines: state.linesOf(stage)),
          ],
        );
      },
    );
  }
}

class _StageEditor extends StatelessWidget {
  final ChecklistStage stage;
  final List<TemplateLine> lines;
  const _StageEditor({required this.stage, required this.lines});

  Future<void> _add(BuildContext context) async {
    final bloc = context.read<ChecklistTemplateBloc>();
    final draft =
        await showChecklistLineSheet(context, stage: stage, pickStage: false);
    if (draft != null) {
      bloc.add(ChecklistTemplateAddEvent(stage, draft.title,
          required: draft.required));
    }
  }

  Future<void> _rename(BuildContext context, TemplateLine line) async {
    final bloc = context.read<ChecklistTemplateBloc>();
    final draft = await showChecklistLineSheet(context,
        stage: stage,
        pickStage: false,
        initialTitle: line.title,
        initialRequired: line.required,
        title: AppLocalizations.of(context).teamsChecklistRename);
    if (draft != null) {
      bloc.add(ChecklistTemplateEditEvent(line.key,
          title: draft.title, required: draft.required));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final bloc = context.read<ChecklistTemplateBloc>();
    return AppCard(
      key: ValueKey('template-stage-${stage.name}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(checklistStageLabel(l10n, stage)),
          const SizedBox(height: 6),
          if (lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.teamsChecklistEmptyStage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    color: t.textSecondary),
              ),
            ),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: (from, to) =>
                bloc.add(ChecklistTemplateReorderEvent(stage, from, to)),
            children: [
              for (var i = 0; i < lines.length; i++)
                TemplateLineRow(
                  key: ValueKey('template-line-${lines[i].key}'),
                  line: lines[i],
                  index: i,
                  onRename: () => _rename(context, lines[i]),
                  onToggleRequired: () => bloc.add(ChecklistTemplateEditEvent(
                      lines[i].key,
                      required: !lines[i].required)),
                  onDelete: () =>
                      bloc.add(ChecklistTemplateDeleteEvent(lines[i].key)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          AppGhostButton(
            key: ValueKey('template-add-${stage.name}'),
            label: l10n.teamsChecklistAdd,
            height: AppMetrics.buttonHeightInline,
            onPressed: () => _add(context),
          ),
        ],
      ),
    );
  }
}
