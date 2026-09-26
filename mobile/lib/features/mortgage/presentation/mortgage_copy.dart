import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_presets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String mortgagePresetLabel(AppLocalizations l10n, MortgagePreset p) {
  final name = switch (p.kind) {
    MortgagePresetKind.market => l10n.mortgagePresetMarket,
    MortgagePresetKind.stateProgram => l10n.mortgagePresetStateProgram,
    MortgagePresetKind.housingSavings => l10n.mortgagePresetHousingSavings,
  };
  return '$name ${formatRate(p.ratePercent)}%';
}

String mortgageTypeLabel(AppLocalizations l10n, MortgagePaymentType type) =>
    switch (type) {
      MortgagePaymentType.annuity => l10n.mortgageAnnuity,
      MortgagePaymentType.differentiated => l10n.mortgageDifferentiated,
    };

String formatPercent(double value) => formatRate((value * 10).round() / 10);

String formatCents(int cents) => formatPrice(fromCents(cents));

/// Reads what someone typed as money or a percentage: spaces and thousands
/// separators are ignored, a comma counts as the decimal point.
double? parseAmount(String raw) {
  var s = raw.replaceAll(RegExp(r'[\s$%]'), '');
  if (s.isEmpty) return null;
  if (s.contains(',') && !s.contains('.')) {
    final parts = s.split(',');
    s = parts.length == 2 && parts.last.length <= 2
        ? '${parts.first}.${parts.last}'
        : s.replaceAll(',', '');
  } else {
    s = s.replaceAll(',', '');
  }
  final v = double.tryParse(s);
  return v == null || v.isNaN || v.isInfinite || v < 0 ? null : v;
}

String mortgageShareText({
  required AppLocalizations l10n,
  required MortgageInput input,
  required MortgageResult result,
  String? title,
}) {
  final price = input.price;
  final pct = price > 0 ? result.downPaymentCents / toCents(price) * 100 : 0.0;
  final years = input.termMonths ~/ 12;
  final diff = result.isRange;
  return [
    l10n.mortgageShareHeading,
    if (title != null && title.trim().isNotEmpty) title.trim(),
    '',
    l10n.mortgageSharePrice(formatPrice(price)),
    l10n.mortgageShareDown(
        formatCents(result.downPaymentCents), formatPercent(pct)),
    l10n.mortgageShareRate(formatRate(input.annualRatePercent)),
    l10n.mortgageShareTerm(l10n.mortgageTermYears(years)),
    if (diff)
      l10n.mortgageShareMonthlyRange(formatCents(result.firstPaymentCents),
          formatCents(result.lastPaymentCents))
    else
      l10n.mortgageShareMonthly(formatCents(result.firstPaymentCents)),
    l10n.mortgageShareOverpayment(formatCents(result.overpaymentCents)),
    '',
    l10n.mortgageShareDisclaimer,
  ].join('\n');
}

int? mortgageUserId(BuildContext context) {
  try {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.userId : null;
  } catch (_) {
    return null;
  }
}
