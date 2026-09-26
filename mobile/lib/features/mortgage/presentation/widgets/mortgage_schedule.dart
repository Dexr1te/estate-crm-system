import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/presentation/mortgage_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MortgageScheduleCard extends StatefulWidget {
  final MortgageResult result;
  const MortgageScheduleCard({super.key, required this.result});

  @override
  State<MortgageScheduleCard> createState() => _MortgageScheduleCardState();
}

class _MortgageScheduleCardState extends State<MortgageScheduleCard> {
  final _open = <int>{};

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final years = widget.result.years;
    final peak = years.fold<int>(0, (m, y) => math.max(m, y.paymentCents));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.mortgageAmortisation),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _Legend(color: t.primary, label: l10n.mortgagePrincipal),
              _Legend(color: t.accent, label: l10n.mortgageInterest),
            ],
          ),
          const SizedBox(height: 12),
          for (final y in years) ...[
            _YearRow(
              year: y,
              peak: peak,
              open: _open.contains(y.number),
              onTap: () => setState(() => _open.contains(y.number)
                  ? _open.remove(y.number)
                  : _open.add(y.number)),
            ),
            if (_open.contains(y.number))
              for (final m in y.months) _MonthRow(month: m),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                color: t.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _YearRow extends StatelessWidget {
  final MortgageYear year;
  final int peak;
  final bool open;
  final VoidCallback onTap;
  const _YearRow({
    required this.year,
    required this.peak,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final share = peak == 0 ? 0.0 : year.paymentCents / peak;
    final paid = math.max(1, year.paymentCents);
    final interest = (year.interestCents / paid * 1000).round().clamp(0, 999);
    final principal = 1000 - interest;
    final strong = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: t.textPrimary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('mortgage-year-${year.number}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: t.textHint,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(l10n.mortgageYearLabel(year.number),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: strong),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(formatCents(year.paymentCents),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: strong),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FractionallySizedBox(
                widthFactor: share.clamp(0.04, 1.0).toDouble(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                            flex: principal,
                            child: ColoredBox(color: t.primary)),
                        if (interest > 0)
                          Expanded(
                              flex: interest,
                              child: ColoredBox(color: t.accent)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${l10n.mortgagePrincipal} ${formatCents(year.principalCents)}'
                ' · ${l10n.mortgageInterest} ${formatCents(year.interestCents)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11,
                    color: t.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  final MortgageMonth month;
  const _MonthRow({required this.month});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final muted = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11, color: t.textSecondary);
    final strong = muted.copyWith(color: t.textPrimary, fontSize: 12);

    return Padding(
      key: ValueKey('mortgage-month-${month.number}'),
      padding: const EdgeInsets.fromLTRB(22, 3, 0, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.mortgageMonthLabel(month.number),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: strong),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(formatCents(month.paymentCents),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: strong.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Text(
            '${formatCents(month.principalCents)} + '
            '${formatCents(month.interestCents)} · '
            '${formatCents(month.balanceCents)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
        ],
      ),
    );
  }
}
