import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/presentation/mortgage_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MortgageResultHero extends StatelessWidget {
  final MortgageResult result;
  const MortgageResultHero({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final range = result.isRange;
    final value = !result.hasLoan
        ? formatCents(0)
        : range
            ? '${formatCents(result.firstPaymentCents)} → '
                '${formatCents(result.lastPaymentCents)}'
            : formatCents(result.firstPaymentCents);
    final muted = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11.5, color: t.heroTextMuted);

    return AppHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.mortgageMonthly, color: t.heroTextMuted),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              key: const ValueKey('mortgage-monthly'),
              maxLines: 1,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: t.heroText),
            ),
          ),
          if (range) ...[
            const SizedBox(height: 4),
            Text(l10n.mortgageMonthlyRange,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
          ],
          const SizedBox(height: 6),
          Text(
            result.hasLoan
                ? '${l10n.mortgageIncomeNeeded}: '
                    '${formatCents(result.requiredIncomeCents)} · '
                    '${l10n.mortgageIncomeHint(formatPercent(kMaxPaymentToIncome * 100))}'
                : l10n.mortgageNoLoan,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
        ],
      ),
    );
  }
}

class MortgageMetrics extends StatelessWidget {
  final MortgageResult result;
  const MortgageMetrics({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MetricsCard(metrics: [
      Metric(value: formatCents(result.loanCents), caption: l10n.mortgageLoan),
      Metric(
          value: formatCents(result.downPaymentCents),
          caption: l10n.mortgageDownPayment),
      Metric(
          value: formatCents(result.totalRepaidCents),
          caption: l10n.mortgageTotalRepaid),
      Metric(
          value: formatCents(result.overpaymentCents),
          caption: l10n.mortgageOverpayment),
    ]);
  }
}
