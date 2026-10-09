import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/key_models.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/keys/presentation/widgets/keys_labels.dart';
import 'package:real_estate_crm/features/time_off/presentation/widgets/time_off_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Who the keys go to: somebody from the agency, or anybody else by name.
enum KeyHolderKind { colleague, someoneElse }

/// Asks who takes a listing's keys, until when, and a note. Resolves to what
/// to send, or null when the sheet was dismissed.
Future<KeyHandoverDraft?> showHandOverKeysSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<KeyHandoverDraft>(
    context,
    title: l10n.keysHandOverTitle,
    builder: (_) => const HandOverKeysForm(),
  );
}

class HandOverKeysForm extends StatefulWidget {
  const HandOverKeysForm({super.key});

  @override
  State<HandOverKeysForm> createState() => _HandOverKeysFormState();
}

class _HandOverKeysFormState extends State<HandOverKeysForm> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  KeyHolderKind _kind = KeyHolderKind.colleague;
  PickerItem? _colleague;
  DateTime? _dueBackAt;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _noteTooLong => _note.text.trim().length > kKeyNoteMaxLength;

  bool get _ready =>
      !_noteTooLong &&
      switch (_kind) {
        KeyHolderKind.colleague => _colleague != null,
        KeyHolderKind.someoneElse => _name.text.trim().isNotEmpty,
      };

  Future<void> _pickColleague() async {
    final l10n = AppLocalizations.of(context);
    List<AgentOption> agents;
    try {
      agents = await Injector.agentsRepository.getAgentOptions();
    } catch (err) {
      if (mounted) {
        setState(() => _error = apiFailureLabel(l10n, ApiFailure.from(err)));
      }
      return;
    }
    if (!mounted) return;
    final picked = await showEntityPicker(
      context,
      title: l10n.keysPickColleague,
      items: [for (final a in agents) agentPickerItem(context, a)],
      selectedId: _colleague?.id,
      searchHint: l10n.keysSearchColleague,
      emptyLabel: l10n.keysNoColleagues,
    );
    if (picked != null && mounted) {
      setState(() {
        _colleague = picked;
        _error = null;
      });
    }
  }

  void _submit() {
    if (!_ready) return;
    Navigator.pop(
      context,
      KeyHandoverDraft(
        holderUserId: _kind == KeyHolderKind.colleague ? _colleague?.id : null,
        holderName:
            _kind == KeyHolderKind.someoneElse ? _name.text.trim() : null,
        dueBackAt: _dueBackAt,
        note: _note.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelledField(
          label: l10n.keysWho,
          child: FilterPillWrap(pills: [
            FilterPill(
              key: const ValueKey('keys-to-colleague'),
              label: l10n.keysToColleague,
              selected: _kind == KeyHolderKind.colleague,
              onTap: () => setState(() => _kind = KeyHolderKind.colleague),
            ),
            FilterPill(
              key: const ValueKey('keys-to-someone-else'),
              label: l10n.keysToSomeoneElse,
              selected: _kind == KeyHolderKind.someoneElse,
              onTap: () => setState(() => _kind = KeyHolderKind.someoneElse),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        if (_kind == KeyHolderKind.colleague)
          LabelledField(
            label: l10n.keysColleague,
            required: true,
            child: PickerField(
              key: const ValueKey('keys-colleague'),
              value: _colleague?.title,
              placeholder: l10n.keysPickColleague,
              onTap: _pickColleague,
            ),
          )
        else
          LabelledField(
            label: l10n.keysHolderName,
            required: true,
            child: AppTextField(
              key: const ValueKey('keys-holder-name'),
              controller: _name,
              hint: l10n.keysHolderNameHint,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
          ),
        const SizedBox(height: 14),
        _DueBackField(
          value: _dueBackAt,
          onChanged: (d) => setState(() => _dueBackAt = d),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.keysNote,
          child: AppTextField(
            key: const ValueKey('keys-note'),
            controller: _note,
            hint: l10n.keysNoteHint,
            maxLines: 3,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            onChanged: (_) => setState(() {}),
          ),
        ),
        _ErrorLine(_noteTooLong ? l10n.keysNoteTooLong : _error),
        const SizedBox(height: 18),
        AppFilledButton(
          key: const ValueKey('keys-save'),
          label: l10n.keysSave,
          onPressed: _ready ? _submit : null,
        ),
      ],
    );
  }
}

class _DueBackField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DueBackField({required this.value, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final now = AppClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = value;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null || current.isBefore(today)
          ? today.add(const Duration(days: 1))
          : current,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final v = value;
    return LabelledField(
      label: l10n.keysDueBack,
      child: Row(
        children: [
          Expanded(
            child: PickerField(
              key: const ValueKey('keys-due-back'),
              value:
                  v == null ? null : keysDateLabel(v, AppClock.now(), locale),
              placeholder: l10n.keysNoDueDate,
              trailingIcon: Icons.calendar_today_outlined,
              onTap: () => _pick(context),
            ),
          ),
          if (v != null)
            SizedBox(
              width: AppMetrics.minHitTarget,
              height: AppMetrics.minHitTarget,
              child: IconButton(
                key: const ValueKey('keys-due-back-clear'),
                padding: EdgeInsets.zero,
                tooltip: l10n.keysNoDueDate,
                onPressed: () => onChanged(null),
                icon: Icon(Icons.close_rounded,
                    size: 18, color: context.tokens.textHint),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  final String? error;
  const _ErrorLine(this.error);

  @override
  Widget build(BuildContext context) {
    final e = error;
    if (e == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        e,
        key: const ValueKey('keys-sheet-error'),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11.5,
            height: 1.35,
            color: context.tokens.dangerText),
      ),
    );
  }
}
