import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Whether a share has been paid out, and on which day: "Paid 9 Oct 2026"
/// or "Unpaid".
class PayoutChip extends StatelessWidget {
  final bool paid;
  final DateTime? paidAt;

  const PayoutChip({super.key, required this.paid, this.paidAt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final at = paidAt;
    final label = !paid
        ? l10n.payoutsUnpaid
        : at == null
            ? l10n.payoutsPaid
            : l10n.payoutsPaidOn(
                formatFullDate(at, Localizations.localeOf(context).toString()));
    return StatusChip(
      label: label,
      hue: paid ? StatusHue.positive : StatusHue.negotiation,
    );
  }
}

/// A small action beside a share's payout: "Mark paid" or "Undo payout".
class PayoutAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const PayoutAction({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: onTap == null ? t.textHint : t.primary),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the manager confirmed when marking a share paid.
class PayoutChoice {
  final String? note;
  const PayoutChoice(this.note);
}

/// Asks the manager to confirm a payout to [name] of [amount], with an
/// optional note. Null when they back out.
Future<PayoutChoice?> showMarkPaidSheet(
  BuildContext context, {
  required String name,
  double? amount,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<PayoutChoice>(
    context,
    title: l10n.payoutsMarkTitle,
    subtitle: l10n.payoutsMarkSubtitle,
    builder: (sheet) => MarkPaidForm(
      name: name,
      amount: amount,
      onConfirm: (choice) => Navigator.pop(sheet, choice),
    ),
  );
}

class MarkPaidForm extends StatefulWidget {
  final String name;
  final double? amount;
  final ValueChanged<PayoutChoice> onConfirm;

  const MarkPaidForm({
    super.key,
    required this.name,
    required this.onConfirm,
    this.amount,
  });

  @override
  State<MarkPaidForm> createState() => _MarkPaidFormState();
}

class _MarkPaidFormState extends State<MarkPaidForm> {
  static const _noteMax = 500;

  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    var note = _noteCtrl.text.trim();
    if (note.length > _noteMax) note = note.substring(0, _noteMax);
    widget.onConfirm(PayoutChoice(note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = widget.amount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoRow(label: l10n.payoutsPaidTo, value: widget.name),
        const SizedBox(height: 10),
        InfoRow(
          label: l10n.payoutsAmount,
          value: amount == null ? l10n.payoutsNoAmount : formatPrice(amount),
        ),
        const SizedBox(height: 16),
        LabelledField(
          label: l10n.payoutsNote,
          child: AppTextField(
            key: const Key('payout-note'),
            controller: _noteCtrl,
            hint: l10n.payoutsNoteHint,
            maxLines: 3,
            minLines: 2,
          ),
        ),
        const SizedBox(height: 16),
        AppFilledButton(
          key: const Key('payout-confirm'),
          label: l10n.payoutsMarkPaid,
          onPressed: _confirm,
        ),
      ],
    );
  }
}

/// A payout rule the server refused by, in words; null for any other
/// refusal.
String? payoutFailureLabel(AppLocalizations l10n, ApiFailure failure) =>
    switch (failure.serverCode) {
      'ALREADY_PAID' => l10n.payoutsAlreadyPaid,
      'NOT_PAID' => l10n.payoutsNotPaid,
      'DEAL_NOT_WON' => l10n.payoutsDealNotWon,
      'SHARE_PAID' => l10n.payoutsSharePaidLocked,
      'MANAGER_ONLY' => l10n.payoutsManagerOnly,
      _ => null,
    };
