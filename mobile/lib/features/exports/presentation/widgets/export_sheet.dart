import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/export_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String exportTitle(AppLocalizations l10n, ExportKind kind) => switch (kind) {
      ExportKind.clients => l10n.exportTitleClients,
      ExportKind.properties => l10n.exportTitleProperties,
      ExportKind.deals => l10n.exportTitleDeals,
    };

/// The options of one export. Resolves to the chosen separator, or null when
/// the sheet is dismissed.
Future<ExportDelimiter?> showExportSheet(
  BuildContext context, {
  required ExportKind kind,
  required ExportFilters filters,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<ExportDelimiter>(
    context,
    title: exportTitle(l10n, kind),
    builder: (sheet) => ExportOptionsForm(
      kind: kind,
      filters: filters,
      onConfirm: (delimiter) => Navigator.pop(sheet, delimiter),
    ),
  );
}

class ExportOptionsForm extends StatefulWidget {
  final ExportKind kind;
  final ExportFilters filters;
  final ValueChanged<ExportDelimiter> onConfirm;

  const ExportOptionsForm({
    super.key,
    required this.kind,
    required this.filters,
    required this.onConfirm,
  });

  @override
  State<ExportOptionsForm> createState() => _ExportOptionsFormState();
}

class _ExportOptionsFormState extends State<ExportOptionsForm> {
  ExportDelimiter? _delimiter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final delimiter = _delimiter ??
        ExportDelimiter.forLanguage(
            Localizations.localeOf(context).languageCode);
    final note = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13,
        height: 1.4,
        color: t.textSecondary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(l10n.exportFormatNote,
            key: const ValueKey('export-format-note'),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: note),
        const SizedBox(height: 6),
        Text(
            widget.filters.isEmpty
                ? l10n.exportAllNote
                : l10n.exportFiltersNote,
            key: const ValueKey('export-filters-note'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: note),
        if (widget.kind == ExportKind.clients) ...[
          const SizedBox(height: 14),
          _PersonalDataNote(text: l10n.exportPersonalData),
        ],
        const SizedBox(height: 18),
        Text(l10n.exportDelimiter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.textPrimary)),
        const SizedBox(height: 8),
        FilterPillWrap(pills: [
          for (final d in ExportDelimiter.values)
            FilterPill(
              key: ValueKey('export-delimiter-${d.param}'),
              label: d == ExportDelimiter.comma
                  ? l10n.exportDelimiterComma
                  : l10n.exportDelimiterSemicolon,
              selected: delimiter == d,
              onTap: () => setState(() => _delimiter = d),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            ),
        ]),
        const SizedBox(height: 8),
        Text(l10n.exportDelimiterHint,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: note.copyWith(fontSize: 12, color: t.textHint)),
        const SizedBox(height: 18),
        AppFilledButton(
          key: const ValueKey('export-confirm'),
          label: l10n.exportConfirm,
          onPressed: () => widget.onConfirm(delimiter),
        ),
      ],
    );
  }
}

class _PersonalDataNote extends StatelessWidget {
  final String text;
  const _PersonalDataNote({required this.text});

  @override
  Widget build(BuildContext context) {
    final palette =
        StatusPalette.resolve(context.tokens, StatusHue.negotiation);
    return Container(
      key: const ValueKey('export-personal-data'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 18, color: palette.label),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: palette.label)),
          ),
        ],
      ),
    );
  }
}
