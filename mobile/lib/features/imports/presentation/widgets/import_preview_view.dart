import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_bloc.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_event.dart';
import 'package:real_estate_crm/features/imports/presentation/bloc/import_state.dart';
import 'package:real_estate_crm/features/imports/presentation/widgets/import_labels.dart';
import 'package:real_estate_crm/features/imports/presentation/widgets/import_problem_list.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What the sheet would bring in: the counts, which column fills which field,
/// the rows that would not go in and why, and the options for the import.
class ImportPreviewView extends StatelessWidget {
  final ImportState state;
  final VoidCallback onBack;

  const ImportPreviewView({
    super.key,
    required this.state,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = state.preview!;
    final bloc = context.read<ImportBloc>();
    final count = state.rowsToImport;

    return DetailScaffold(
      title: l10n.importTitle,
      onBack: onBack,
      bottomAction: AppFilledButton(
        key: const ValueKey('import-commit'),
        label:
            count > 0 ? l10n.importAction(count) : l10n.importNothingToImport,
        loading: state.phase == ImportPhase.importing,
        onPressed:
            state.canImport ? () => bloc.add(ImportCommitRequested()) : null,
      ),
      children: [
        _Summary(state: state),
        _Columns(state: state),
        ImportProblemList(
          // A new reading is a new list: start again from its first page.
          key: ObjectKey(preview),
          preview: preview,
        ),
        _Options(state: state),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final ImportState state;
  const _Summary({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final p = state.preview!;
    final stale = state.phase == ImportPhase.remapping;

    return AppCard(
      key: const ValueKey('import-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.file?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: t.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.importRowsTotal(p.totalRows),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary),
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            opacity: stale ? 0.45 : 1,
            duration: const Duration(milliseconds: 150),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Count(
                    key: const ValueKey('import-count-valid'),
                    value: p.validRows,
                    label: l10n.importSummaryValid,
                    color: t.chartWon),
                _Count(
                    key: const ValueKey('import-count-invalid'),
                    value: p.invalidRows,
                    label: l10n.importSummaryInvalid,
                    color: t.dangerText),
                if (p.kind == ImportKind.clients)
                  _Count(
                      key: const ValueKey('import-count-duplicates'),
                      value: p.duplicateRows,
                      label: l10n.importSummaryDuplicates,
                      color: t.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Columns extends StatelessWidget {
  final ImportState state;
  const _Columns({required this.state});

  Future<void> _choose(BuildContext context, int column) async {
    final l10n = AppLocalizations.of(context);
    final p = state.preview!;
    final targets = p.targets;
    final current = state.mapping[column];
    // 0 is "skip"; a target is its index plus one.
    final picked = await showEntityPicker(
      context,
      title: p.headers[column].isEmpty ? l10n.importColumns : p.headers[column],
      searchHint: l10n.importPickAgentSearch,
      emptyLabel: l10n.importNothingToImport,
      selectedId: current == null
          ? 0
          : targets.indexWhere((t) => t.field == current) + 1,
      items: [
        PickerItem(id: 0, title: l10n.importSkipColumn),
        for (var i = 0; i < targets.length; i++)
          PickerItem(
            id: i + 1,
            title: importFieldLabel(l10n, p.kind, targets[i].field),
            subtitle: targets[i].required ? l10n.importErrorRequired : null,
          ),
      ],
    );
    if (picked == null || !context.mounted) return;
    final field = picked.id == 0 ? null : targets[picked.id - 1].field;
    if (field == current) return;
    context.read<ImportBloc>().add(ImportColumnMapped(column, field));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final p = state.preview!;
    final missing = state.missingRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.importColumns),
        const SizedBox(height: 4),
        Text(
          l10n.importColumnsHint,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12.5,
              color: t.textSecondary),
        ),
        for (final field in missing) ...[
          const SizedBox(height: 6),
          Text(
            l10n.importMissingRequired(importFieldLabel(l10n, p.kind, field)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: t.dangerText),
          ),
        ],
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < p.headers.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Text(
                  p.headers[i].isEmpty ? '${i + 1}' : p.headers[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: t.textSecondary),
                ),
                const SizedBox(height: 6),
                PickerField(
                  key: ValueKey('import-column-$i'),
                  value: state.mapping[i] == null
                      ? null
                      : importFieldLabel(l10n, p.kind, state.mapping[i]!),
                  placeholder: l10n.importSkipColumn,
                  onTap: state.busy ? () {} : () => _choose(context, i),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Options extends StatelessWidget {
  final ImportState state;
  const _Options({required this.state});

  Future<void> _chooseAgent(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<ImportBloc>();
    List<AgentOption> agents;
    try {
      agents = await Injector.agentsRepository.getAgentOptions();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(apiFailureLabel(l10n, ApiFailure.from(error))),
          backgroundColor: context.tokens.dangerSolid,
        ));
      return;
    }
    if (!context.mounted) return;
    // 0 is the person importing; agents keep their own ids.
    final picked = await showEntityPicker(
      context,
      title: l10n.importAssignTo,
      searchHint: l10n.importPickAgentSearch,
      emptyLabel: l10n.importNoAgents,
      selectedId: state.assignee?.id ?? 0,
      items: [
        PickerItem(id: 0, title: l10n.importAssignToMe),
        for (final a in agents)
          PickerItem(id: a.id, title: a.fullName, subtitle: a.email),
      ],
    );
    if (picked == null) return;
    bloc.add(ImportAssigneeChanged(
        picked.id == 0 ? null : agents.firstWhere((a) => a.id == picked.id)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clients = state.kind == ImportKind.clients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.importOptions),
        const SizedBox(height: 10),
        SettingsGroup(rows: [
          if (clients)
            SettingsRow(
              label: l10n.importSkipDuplicates,
              subLabel: l10n.importSkipDuplicatesHint,
              trailing: AppSwitch(
                key: const ValueKey('import-skip-duplicates'),
                value: state.skipDuplicates,
                onChanged: (v) => context
                    .read<ImportBloc>()
                    .add(ImportSkipDuplicatesChanged(v)),
              ),
            ),
          SettingsRow(
            key: const ValueKey('import-assignee'),
            label: l10n.importAssignTo,
            value: state.assignee?.fullName ?? l10n.importAssignToMe,
            showChevron: true,
            onTap: state.busy ? null : () => _chooseAgent(context),
          ),
        ]),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _Count({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: value == 0 ? t.textHint : color),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12,
                color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
