import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/partners/domain/repositories/partners_repository.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/partner_labels.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/partner_picker.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Sends [clientId] to a partner, or moves [existing] along. Resolves to what
/// was saved, or null when the sheet was dismissed.
Future<PartnerHandoff?> showHandoffSheet(
  BuildContext context, {
  required int clientId,
  PartnerHandoff? existing,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<PartnerHandoff>(
    context,
    title: existing == null
        ? l10n.partnersSendToPartner
        : l10n.partnersHandoffEdit,
    builder: (_) => HandoffForm(clientId: clientId, existing: existing),
  );
}

class HandoffForm extends StatefulWidget {
  final int clientId;
  final PartnerHandoff? existing;

  const HandoffForm({super.key, required this.clientId, this.existing});

  @override
  State<HandoffForm> createState() => _HandoffFormState();
}

class _HandoffFormState extends State<HandoffForm> {
  late final _noteCtrl = TextEditingController(text: widget.existing?.note);
  late PickerItem? _partner = widget.existing == null
      ? null
      : PickerItem(
          id: widget.existing!.partnerId, title: widget.existing!.partnerName);
  late DateTime _sentOn = widget.existing?.sentOn ?? _today();
  late PartnerHandoffStatus _status =
      widget.existing?.status ?? PartnerHandoffStatus.sent;
  bool _saving = false;
  String? _error;

  static DateTime _today() {
    final now = AppClock.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPartner() async {
    final picked = await showPartnerPicker(context, selectedId: _partner?.id);
    if (picked == null || !mounted) return;
    setState(() {
      _partner = picked;
      _error = null;
    });
  }

  Future<void> _pickDay() async {
    final today = _today();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sentOn.isAfter(today) ? today : _sentOn,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    setState(() => _sentOn = picked);
  }

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final partner = _partner;
    if (partner == null) {
      setState(() => _error = l10n.partnersPickPartner);
      return;
    }
    final note = _noteCtrl.text.trim();
    final draft = HandoffDraft(
      partnerId: partner.id,
      sentOn: _sentOn,
      status: _status,
      note: note.isEmpty ? null : note,
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = Injector.partnersRepository;
      final existing = widget.existing;
      final saved = existing == null
          ? await repo.createHandoff(widget.clientId, draft)
          : await repo.updateHandoff(widget.clientId, existing.id, draft);
      if (mounted) Navigator.pop(context, saved);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = partnerFailureLabel(l10n, err);
      });
    }
  }

  Future<void> _remove(PartnerHandoff existing) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.partnersHandoffRemove,
      content: l10n.partnersHandoffRemoveConfirm,
      confirmLabel: l10n.partnersHandoffRemove,
      icon: Icons.delete_outline_rounded,
    );
    if (!ok || !mounted) return;
    setState(() => _saving = true);
    try {
      await Injector.partnersRepository
          .deleteHandoff(widget.clientId, existing.id);
      if (mounted) Navigator.pop(context);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = partnerFailureLabel(l10n, err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    const pad = EdgeInsets.symmetric(horizontal: 15, vertical: 9);
    final editing = widget.existing != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelledField(
          label: l10n.partnersHandoffPartner,
          required: true,
          child: PickerField(
            key: const ValueKey('handoff-partner'),
            value: _partner?.title,
            placeholder: l10n.partnersPickPartner,
            // A different partner is another hand-off, not this one moved.
            onTap: editing ? () {} : _pickPartner,
            trailingIcon: Icons.handshake_outlined,
          ),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.partnersHandoffDate,
          child: PickerField(
            key: const ValueKey('handoff-date'),
            value: formatFullDate(_sentOn, locale),
            placeholder: l10n.partnersHandoffDate,
            onTap: _pickDay,
            trailingIcon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.partnersHandoffStatus,
          child: FilterPillWrap(pills: [
            for (final s in PartnerHandoffStatus.values)
              FilterPill(
                key: ValueKey('handoff-status-${s.name}'),
                label: handoffStatusLabel(l10n, s),
                selected: _status == s,
                onCard: true,
                padding: pad,
                onTap: () => setState(() => _status = s),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.partnersNote,
          child: AppTextField(
            key: const ValueKey('handoff-note'),
            controller: _noteCtrl,
            hint: l10n.partnersHandoffNoteHint,
            maxLines: 3,
            minLines: 2,
            keyboardType: TextInputType.multiline,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            key: const ValueKey('handoff-error'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                height: 1.35,
                color: t.dangerText),
          ),
        ],
        const SizedBox(height: 18),
        AppFilledButton(
          key: const ValueKey('handoff-save'),
          label: l10n.partnersSave,
          loading: _saving,
          onPressed: _submit,
        ),
        if (widget.existing case final existing?) ...[
          const SizedBox(height: 9),
          AppGhostButton(
            key: const ValueKey('handoff-remove'),
            label: l10n.partnersHandoffRemove,
            icon: Icons.delete_outline_rounded,
            onPressed: _saving ? null : () => _remove(existing),
          ),
        ],
      ],
    );
  }
}
