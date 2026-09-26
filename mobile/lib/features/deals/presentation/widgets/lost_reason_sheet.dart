import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class LostReasonChoice {
  final DealLostReason reason;
  final String? note;
  const LostReasonChoice(this.reason, this.note);
}

Future<LostReasonChoice?> showLostReasonSheet(
  BuildContext context, {
  DealLostReason? initialReason,
  String? initialNote,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<LostReasonChoice>(
    context,
    title: l10n.dealsLostSheetTitle,
    subtitle: l10n.dealsLostSheetSubtitle,
    builder: (sheet) => LostReasonForm(
      initialReason: initialReason,
      initialNote: initialNote,
      onConfirm: (choice) => Navigator.pop(sheet, choice),
    ),
  );
}

class LostReasonForm extends StatefulWidget {
  final DealLostReason? initialReason;
  final String? initialNote;
  final ValueChanged<LostReasonChoice> onConfirm;

  const LostReasonForm({
    super.key,
    required this.onConfirm,
    this.initialReason,
    this.initialNote,
  });

  @override
  State<LostReasonForm> createState() => _LostReasonFormState();
}

class _LostReasonFormState extends State<LostReasonForm> {
  static const _noteMax = 500;

  late DealLostReason? _reason = widget.initialReason;
  late final _noteCtrl = TextEditingController(text: widget.initialNote ?? '');

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    var note = _noteCtrl.text.trim();
    if (note.length > _noteMax) note = note.substring(0, _noteMax);
    widget.onConfirm(LostReasonChoice(_reason!, note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        FilterPillWrap(pills: [
          for (final r in DealLostReason.values)
            FilterPill(
              label: dealLostReasonLabel(l10n, r),
              selected: _reason == r,
              onTap: () => setState(() => _reason = r),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            ),
        ]),
        const SizedBox(height: 16),
        LabelledField(
          label: l10n.dealsLostNote,
          child: AppTextField(
            controller: _noteCtrl,
            hint: l10n.dealsLostNoteHint,
            maxLines: 3,
            minLines: 2,
          ),
        ),
        const SizedBox(height: 16),
        AppFilledButton(
          label: l10n.dealsLostConfirm,
          onPressed: _reason == null ? null : _confirm,
        ),
      ],
    );
  }
}
