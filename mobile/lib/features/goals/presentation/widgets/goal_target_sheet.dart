import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What the target sheet answers: the figures to save, or [remove].
class GoalDraft {
  final double? commissionTarget;
  final int? dealsTarget;
  final bool remove;

  const GoalDraft({this.commissionTarget, this.dealsTarget}) : remove = false;
  const GoalDraft.remove()
      : commissionTarget = null,
        dealsTarget = null,
        remove = true;
}

/// "1 500 000", "1,500,000" and "1500000,50" all read as the amount they
/// mean; anything else is null.
double? parseGoalAmount(String text) {
  var s = text.trim().replaceAll(RegExp(r'[\s ]'), '');
  if (s.isEmpty) return null;
  if (!s.contains('.') && RegExp(r',\d{1,2}$').hasMatch(s)) {
    final i = s.lastIndexOf(',');
    s = '${s.substring(0, i).replaceAll(',', '')}.${s.substring(i + 1)}';
  } else {
    s = s.replaceAll(',', '');
  }
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(s)) return null;
  return double.tryParse(s);
}

/// The editor for a month's target: commission, deals won, or both. Answers
/// null when dismissed.
Future<GoalDraft?> showGoalTargetSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  double? commissionTarget,
  int? dealsTarget,
  bool canRemove = false,
}) {
  return showAppBottomSheet<GoalDraft>(
    context,
    title: title,
    subtitle: subtitle,
    builder: (_) => _GoalTargetForm(
      commissionTarget: commissionTarget,
      dealsTarget: dealsTarget,
      canRemove: canRemove,
    ),
  );
}

class _GoalTargetForm extends StatefulWidget {
  final double? commissionTarget;
  final int? dealsTarget;
  final bool canRemove;

  const _GoalTargetForm({
    required this.commissionTarget,
    required this.dealsTarget,
    required this.canRemove,
  });

  @override
  State<_GoalTargetForm> createState() => _GoalTargetFormState();
}

class _GoalTargetFormState extends State<_GoalTargetForm> {
  late final _commission = TextEditingController(
      text: widget.commissionTarget == null
          ? ''
          : _plain(widget.commissionTarget!));
  late final _deals =
      TextEditingController(text: widget.dealsTarget?.toString() ?? '');
  String? _error;

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  @override
  void dispose() {
    _commission.dispose();
    _deals.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final commissionText = _commission.text.trim();
    final dealsText = _deals.text.trim();
    final commission =
        commissionText.isEmpty ? null : parseGoalAmount(commissionText);
    final deals = dealsText.isEmpty ? null : int.tryParse(dealsText);

    String? error;
    if (commissionText.isEmpty && dealsText.isEmpty) {
      error = l10n.goalsNeedOne;
    } else if (commissionText.isNotEmpty &&
        (commission == null || commission <= 0)) {
      error = l10n.goalsInvalidCommission;
    } else if (dealsText.isNotEmpty &&
        (deals == null || deals < 1 || deals > 1000)) {
      error = l10n.goalsInvalidDeals;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context)
        .pop(GoalDraft(commissionTarget: commission, dealsTarget: deals));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelledField(
          label: l10n.goalsCommissionLabel,
          child: AppTextField(
            key: const Key('goal-commission'),
            controller: _commission,
            hint: l10n.goalsFieldHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: 12),
        LabelledField(
          label: l10n.goalsDealsLabel,
          child: AppTextField(
            key: const Key('goal-deals'),
            controller: _deals,
            hint: l10n.goalsFieldHint,
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _save(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            key: const Key('goal-error'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 12, color: t.dangerText),
          ),
        ],
        const SizedBox(height: 14),
        AppFilledButton(
          key: const Key('goal-save'),
          label: l10n.coreSave,
          onPressed: _save,
        ),
        if (widget.canRemove) ...[
          const SizedBox(height: 9),
          AppGhostButton(
            key: const Key('goal-remove'),
            label: l10n.goalsRemove,
            onPressed: () =>
                Navigator.of(context).pop(const GoalDraft.remove()),
          ),
        ],
      ],
    );
  }
}
