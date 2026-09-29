import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/document_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A checklist stage reads as the deal stage it belongs to.
String checklistStageLabel(AppLocalizations l10n, ChecklistStage stage) =>
    dealStatusLabel(l10n, DealStatus.values.byName(stage.name));

/// Asks before a deal moves on with [openRequired] required lines left
/// behind. Nothing to ask about is a yes. The move is never refused: the gate
/// is soft, and this is the whole of it.
Future<bool> confirmChecklistGate(BuildContext context, int openRequired) {
  if (openRequired <= 0) return Future.value(true);
  final l10n = AppLocalizations.of(context);
  return showConfirmDialog(
    context,
    title: l10n.dealsChecklistGateTitle,
    content: l10n.dealsChecklistGateBody(openRequired),
    confirmLabel: l10n.dealsChecklistGateConfirm,
    icon: Icons.checklist_rounded,
  );
}

/// What a new checklist line is: its words, its stage, whether it gates.
class ChecklistLineDraft {
  final ChecklistStage stage;
  final String title;
  final bool required;
  const ChecklistLineDraft(this.stage, this.title, this.required);
}

Future<ChecklistLineDraft?> showChecklistLineSheet(
  BuildContext context, {
  required ChecklistStage stage,
  String initialTitle = '',
  bool initialRequired = false,
  bool pickStage = true,
  String? title,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<ChecklistLineDraft>(
    context,
    title: title ?? l10n.dealsChecklistAddTitle,
    builder: (sheet) => ChecklistLineForm(
      stage: stage,
      initialTitle: initialTitle,
      initialRequired: initialRequired,
      pickStage: pickStage,
      onConfirm: (draft) => Navigator.pop(sheet, draft),
    ),
  );
}

class ChecklistLineForm extends StatefulWidget {
  final ChecklistStage stage;
  final String initialTitle;
  final bool initialRequired;
  final bool pickStage;
  final ValueChanged<ChecklistLineDraft> onConfirm;

  const ChecklistLineForm({
    super.key,
    required this.stage,
    required this.onConfirm,
    this.initialTitle = '',
    this.initialRequired = false,
    this.pickStage = true,
  });

  @override
  State<ChecklistLineForm> createState() => _ChecklistLineFormState();
}

class _ChecklistLineFormState extends State<ChecklistLineForm> {
  late ChecklistStage _stage = widget.stage;
  late bool _required = widget.initialRequired;
  late final _title = TextEditingController(text: widget.initialTitle);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        LabelledField(
          label: l10n.dealsChecklistItemLabel,
          required: true,
          child: AppTextField(
            key: const Key('checklist-line-title'),
            controller: _title,
            hint: l10n.dealsChecklistItemHint,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (widget.pickStage) ...[
          const SizedBox(height: 16),
          LabelledField(
            label: l10n.dealsChecklistStage,
            child: FilterPillWrap(pills: [
              for (final s in ChecklistStage.values)
                FilterPill(
                  label: checklistStageLabel(l10n, s),
                  selected: _stage == s,
                  onTap: () => setState(() => _stage = s),
                ),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        SettingsGroup(rows: [
          SettingsRow(
            key: const Key('checklist-line-required'),
            label: l10n.dealsChecklistRequired,
            subLabel: l10n.dealsChecklistRequiredHint,
            trailing: AppSwitch(
              value: _required,
              onChanged: (v) => setState(() => _required = v),
            ),
            onTap: () => setState(() => _required = !_required),
          ),
        ]),
        const SizedBox(height: 16),
        AppFilledButton(
          key: const Key('checklist-line-save'),
          label: l10n.coreSave,
          onPressed: _title.text.trim().isEmpty
              ? null
              : () => widget.onConfirm(
                  ChecklistLineDraft(_stage, _title.text.trim(), _required)),
        ),
      ],
    );
  }
}

/// One of the deal's documents to prove a line with; null when dismissed.
Future<DocumentResponse?> showChecklistDocumentPicker(
    BuildContext context, List<DocumentResponse> documents) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<DocumentResponse>(
    context,
    title: l10n.dealsChecklistPickDocument,
    builder: (sheet) {
      final t = sheet.tokens;
      if (documents.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            l10n.dealsChecklistNoDocuments,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 13,
                height: 1.45,
                color: t.textSecondary),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SettingsGroup(rows: [
          for (final d in documents)
            SettingsRow(
              key: ValueKey('checklist-doc-${d.id}'),
              label: d.fileName,
              showChevron: true,
              onTap: () => Navigator.pop(sheet, d),
            ),
        ]),
      );
    },
  );
}
