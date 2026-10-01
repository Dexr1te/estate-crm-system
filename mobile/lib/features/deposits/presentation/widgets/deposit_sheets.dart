import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/deposits/domain/deposit.dart';
import 'package:real_estate_crm/features/deposits/presentation/widgets/deposit_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

DateTime _today() {
  final now = AppClock.now();
  return DateTime(now.year, now.month, now.day);
}

Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
  final today = _today();
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(today.year - 5),
    lastDate: DateTime(today.year + 5),
  );
}

/// Records a deposit, or corrects [initial]; null when dismissed.
Future<DepositDraft?> showDepositSheet(BuildContext context,
    {DealDeposit? initial}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<DepositDraft>(
    context,
    title: initial == null ? l10n.depositsRecordTitle : l10n.depositsEditTitle,
    builder: (sheet) => DepositForm(
      initial: initial,
      onConfirm: (draft) => Navigator.pop(sheet, draft),
    ),
  );
}

class DepositForm extends StatefulWidget {
  final DealDeposit? initial;
  final ValueChanged<DepositDraft> onConfirm;

  const DepositForm({super.key, this.initial, required this.onConfirm});

  @override
  State<DepositForm> createState() => _DepositFormState();
}

class _DepositFormState extends State<DepositForm> {
  late final _amount = TextEditingController(
      text: widget.initial == null ? '' : formatRate(widget.initial!.amount));
  late final _note = TextEditingController(text: widget.initial?.note ?? '');
  late DateTime _received = widget.initial?.receivedOn ?? _today();
  late DateTime _until =
      widget.initial?.holdUntil ?? _today().add(const Duration(days: 14));
  late DepositHolder _holder = widget.initial?.holder ?? DepositHolder.AGENCY;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  DepositDraft get _draft => DepositDraft(
        amount:
            double.tryParse(_amount.text.replaceAll(RegExp(r'[\s,]'), '')) ?? 0,
        receivedOn: _received,
        holdUntil: _until,
        holder: _holder,
        note: _note.text,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final draft = _draft;
    final datesWrong = draft.holdUntil.isBefore(draft.receivedOn);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        LabelledField(
          label: l10n.depositsAmount,
          required: true,
          child: AppTextField(
            key: const Key('deposit-amount'),
            controller: _amount,
            hint: l10n.depositsAmountHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.depositsReceivedOn,
          child: PickerField(
            key: const Key('deposit-received'),
            value: depositDateLabel(_received, now, locale),
            placeholder: l10n.depositsReceivedOn,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: () async {
              final d = await _pickDate(context, _received);
              if (d != null && mounted) setState(() => _received = d);
            },
          ),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.depositsHoldUntil,
          child: PickerField(
            key: const Key('deposit-until'),
            value: depositDateLabel(_until, now, locale),
            placeholder: l10n.depositsHoldUntil,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: () async {
              final d = await _pickDate(context, _until);
              if (d != null && mounted) setState(() => _until = d);
            },
          ),
        ),
        if (datesWrong) ...[
          const SizedBox(height: 6),
          Text(
            l10n.depositsHoldBeforeReceived,
            key: const Key('deposit-dates-wrong'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11.5, color: t.dangerText),
          ),
        ],
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.depositsHolder,
          child: FilterPillWrap(pills: [
            for (final h in DepositHolder.values)
              FilterPill(
                key: Key('deposit-holder-${h.name}'),
                label: depositHolderLabel(l10n, h),
                selected: _holder == h,
                onTap: () => setState(() => _holder = h),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.depositsNote,
          child: AppTextField(
            key: const Key('deposit-note'),
            controller: _note,
            hint: l10n.depositsNoteHint,
            maxLines: 3,
            minLines: 1,
          ),
        ),
        const SizedBox(height: 16),
        AppFilledButton(
          key: const Key('deposit-save'),
          label: l10n.coreSave,
          onPressed: draft.isValid ? () => widget.onConfirm(_draft) : null,
        ),
      ],
    );
  }
}

/// How [deposit] ended, and when; null when dismissed.
Future<DepositClosing?> showCloseDepositSheet(
    BuildContext context, DealDeposit deposit) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<DepositClosing>(
    context,
    title: l10n.depositsCloseTitle,
    builder: (sheet) => CloseDepositForm(
      deposit: deposit,
      onConfirm: (closing) => Navigator.pop(sheet, closing),
    ),
  );
}

class CloseDepositForm extends StatefulWidget {
  final DealDeposit deposit;
  final ValueChanged<DepositClosing> onConfirm;

  const CloseDepositForm(
      {super.key, required this.deposit, required this.onConfirm});

  @override
  State<CloseDepositForm> createState() => _CloseDepositFormState();
}

class _CloseDepositFormState extends State<CloseDepositForm> {
  DepositOutcome? _outcome;
  DateTime _on = _today();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final early = _on.isBefore(widget.deposit.receivedOn);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        for (final o in DepositOutcome.values) ...[
          FilterPill(
            key: Key('deposit-outcome-${o.name}'),
            label: depositOutcomeLabel(l10n, o),
            selected: _outcome == o,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _outcome = o);
            },
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 6),
        LabelledField(
          label: l10n.depositsClosedOn,
          child: PickerField(
            key: const Key('deposit-closed-on'),
            value: depositDateLabel(_on, AppClock.now(), locale),
            placeholder: l10n.depositsClosedOn,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: () async {
              final d = await _pickDate(context, _on);
              if (d != null && mounted) setState(() => _on = d);
            },
          ),
        ),
        if (early) ...[
          const SizedBox(height: 6),
          Text(
            l10n.depositsClosedBeforeReceived,
            key: const Key('deposit-closed-early'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11.5, color: t.dangerText),
          ),
        ],
        const SizedBox(height: 16),
        AppFilledButton(
          key: const Key('deposit-close-confirm'),
          label: l10n.depositsCloseAction,
          onPressed: _outcome == null || early
              ? null
              : () => widget.onConfirm(DepositClosing(_outcome!, _on)),
        ),
      ],
    );
  }
}
