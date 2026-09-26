import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/import_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/imports/presentation/widgets/import_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The rows that would not go in, a page at a time: a sheet of thousands can
/// have hundreds of them, and building them all at once would stall the frame.
class ImportProblemList extends StatefulWidget {
  final ImportPreview preview;

  const ImportProblemList({super.key, required this.preview});

  static const pageSize = 20;

  @override
  State<ImportProblemList> createState() => _ImportProblemListState();
}

class _ImportProblemListState extends State<ImportProblemList> {
  int _shown = ImportProblemList.pageSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final problems = widget.preview.problems;
    final visible = problems.take(_shown).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.importProblems,
          count: problems.isEmpty ? null : problems.length,
          countIsAlert: widget.preview.invalidRows > 0,
        ),
        const SizedBox(height: 10),
        if (problems.isEmpty)
          AppCard(
            child: Text(
              l10n.importNoProblems,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13,
                  color: t.textSecondary),
            ),
          ),
        for (final row in visible) ...[
          _ProblemCard(kind: widget.preview.kind, row: row),
          const SizedBox(height: 8),
        ],
        if (_shown < problems.length)
          AppGhostButton(
            key: const ValueKey('import-show-more'),
            label: l10n.importShowMore,
            onPressed: () =>
                setState(() => _shown += ImportProblemList.pageSize),
          )
        else if (widget.preview.problemsTruncated)
          Text(
            l10n.importProblemsTruncated,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12.5,
                color: t.textSecondary),
          ),
      ],
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final ImportKind kind;
  final ImportRowResult row;

  const _ProblemCard({required this.kind, required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final name = row.values[kind == ImportKind.clients ? 'fullName' : 'title'];
    final duplicate = row.duplicate;
    final lines = <String>[
      for (final e in row.errors.entries)
        '${importFieldLabel(l10n, kind, e.key)}: ${importErrorLabel(l10n, e.value)}',
      if (duplicate != null)
        duplicate.source == ImportDuplicateSource.file
            ? l10n.importDuplicateOfRow(duplicate.row ?? 0)
            : l10n.importDuplicateOfClient(duplicate.clientName ?? ''),
    ];

    return AppCard(
      key: ValueKey('import-problem-${row.row}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name == null || name.isEmpty
                      ? l10n.importRowLabel(row.row)
                      : '${l10n.importRowLabel(row.row)} · $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: row.status == ImportRowStatus.duplicate
                    ? l10n.importSummaryDuplicates
                    : l10n.importSummaryInvalid,
                hue: row.status == ImportRowStatus.duplicate
                    ? StatusHue.neutral
                    : StatusHue.danger,
              ),
            ],
          ),
          for (final line in lines) ...[
            const SizedBox(height: 4),
            Text(
              line,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  color: t.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
