import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/my_team_bloc.dart';
import 'package:real_estate_crm/features/teams/presentation/bloc/my_team_event.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "Tenge (₸)", "Тенге (₸)", "Теңге (₸)": the currency's own name, its sign.
String currencyLabel(AppLocalizations l10n, Currency currency) {
  switch (currency) {
    case Currency.kzt:
      return l10n.teamsCurrencyKzt;
    case Currency.rub:
      return l10n.teamsCurrencyRub;
    case Currency.usd:
      return l10n.teamsCurrencyUsd;
    case Currency.eur:
      return l10n.teamsCurrencyEur;
    case Currency.uzs:
      return l10n.teamsCurrencyUzs;
    case Currency.kgs:
      return l10n.teamsCurrencyKgs;
  }
}

/// The "Agency currency" row of the manager's team screen.
class CurrencySettingsRow extends StatelessWidget {
  final Currency current;
  final VoidCallback onTap;

  const CurrencySettingsRow({
    super.key,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(rows: [
      SettingsRow(
        key: const Key('currency-row'),
        label: l10n.teamsCurrency,
        subLabel: l10n.teamsCurrencyHint,
        value: currencyLabel(l10n, current),
        showChevron: true,
        onTap: onTap,
      ),
    ]);
  }
}

/// Picks a currency, says plainly that nothing is converted, and only then
/// asks [bloc] to change it.
Future<void> changeAgencyCurrency(
  BuildContext context,
  MyTeamBloc bloc,
  Currency current,
) async {
  final l10n = AppLocalizations.of(context);
  final picked = await showAppBottomSheet<Currency>(
    context,
    title: l10n.teamsCurrency,
    subtitle: l10n.teamsCurrencyHint,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < Currency.values.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _CurrencyOption(
            label: currencyLabel(l10n, Currency.values[i]),
            selected: Currency.values[i] == current,
            onTap: () => Navigator.pop(ctx, Currency.values[i]),
          ),
        ],
      ],
    ),
  );
  if (picked == null || picked == current || !context.mounted) return;

  final locale = Localizations.localeOf(context).languageCode;
  const example = 12500000.0;
  final ok = await showConfirmDialog(
    context,
    title: l10n.teamsCurrencyConfirmTitle,
    content: l10n.teamsCurrencyConfirmBody(
      currencyLabel(l10n, picked),
      formatMoney(example, current, locale),
      formatMoney(example, picked, locale),
    ),
    confirmLabel: l10n.teamsCurrencyConfirm,
    icon: Icons.currency_exchange_rounded,
  );
  if (ok && !bloc.isClosed) bloc.add(MyTeamChangeCurrencyEvent(picked));
}

class _CurrencyOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: t.textPrimary),
            ),
          ),
          if (selected) Icon(Icons.check_rounded, size: 18, color: t.accent),
        ],
      ),
    );
  }
}
