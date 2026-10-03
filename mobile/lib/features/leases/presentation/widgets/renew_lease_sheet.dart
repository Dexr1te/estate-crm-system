import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/leases/domain/lease.dart';
import 'package:real_estate_crm/features/leases/presentation/widgets/lease_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Asks for the lease's new last day — a year on from the current one to
/// start with — and the rent, which stays as it was unless changed; null when
/// dismissed.
Future<LeaseRenewal?> showRenewLeaseSheet(
    BuildContext context, DealResponse deal) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<LeaseRenewal>(
    context,
    title: l10n.leasesRenewTitle,
    builder: (sheet) => RenewLeaseForm(
      deal: deal,
      onConfirm: (renewal) => Navigator.pop(sheet, renewal),
    ),
  );
}

class RenewLeaseForm extends StatefulWidget {
  final DealResponse deal;
  final ValueChanged<LeaseRenewal> onConfirm;

  const RenewLeaseForm(
      {super.key, required this.deal, required this.onConfirm});

  @override
  State<RenewLeaseForm> createState() => _RenewLeaseFormState();
}

class _RenewLeaseFormState extends State<RenewLeaseForm> {
  late final DateTime _currentEnd = widget.deal.leaseEnd!;
  late DateTime _end =
      DateTime(_currentEnd.year + 1, _currentEnd.month, _currentEnd.day);
  late final _rent = TextEditingController(
      text: widget.deal.monthlyRent == null
          ? ''
          : formatRate(widget.deal.monthlyRent!));

  @override
  void dispose() {
    _rent.dispose();
    super.dispose();
  }

  double? get _rentValue =>
      double.tryParse(_rent.text.replaceAll(RegExp(r'[\s,]'), ''));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = AppClock.now();
    final notLater = !_end.isAfter(_currentEnd);
    final rent = _rentValue;
    final rentOk = rent != null && rent > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.leasesRenewHint,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12.5,
              height: 1.4,
              color: t.textSecondary),
        ),
        const SizedBox(height: 14),
        InfoRow(
            label: l10n.leasesEnd,
            value: leaseDateLabel(_currentEnd, now, locale)),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.leasesRenewNewEnd,
          child: PickerField(
            key: const Key('lease-renew-end'),
            value: leaseDateLabel(_end, now, locale),
            placeholder: l10n.leasesPickDate,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _end,
                firstDate: DateTime(_currentEnd.year - 1),
                lastDate: DateTime(_currentEnd.year + 10),
              );
              if (d != null && mounted) setState(() => _end = d);
            },
          ),
        ),
        if (notLater) ...[
          const SizedBox(height: 6),
          Text(
            l10n.leasesRenewEndNotLater,
            key: const Key('lease-renew-not-later'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11.5, color: t.dangerText),
          ),
        ],
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.leasesMonthlyRent,
          required: true,
          child: AppTextField(
            key: const Key('lease-renew-rent'),
            controller: _rent,
            hint: '350 000',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 16),
        AppFilledButton(
          key: const Key('lease-renew-save'),
          label: l10n.leasesRenew,
          onPressed: notLater || !rentOk
              ? null
              : () => widget.onConfirm(LeaseRenewal(
                    leaseEnd: _end,
                    monthlyRent: rent == widget.deal.monthlyRent ? null : rent,
                  )),
        ),
      ],
    );
  }
}
