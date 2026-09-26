import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/mortgage/data/mortgage_memory.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_presets.dart';
import 'package:real_estate_crm/features/mortgage/presentation/mortgage_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String mortgageRoute(int propertyId, double price, String title) => Uri(
      path: '/properties/$propertyId/mortgage',
      queryParameters: {'price': price.toStringAsFixed(2), 'title': title},
    ).toString();

/// "What would it cost a month?" on a listing: one line until it is asked,
/// the essentials when opened, and the full calculator a tap away.
class PropertyMortgageCard extends StatefulWidget {
  final int propertyId;
  final double price;
  final String title;

  const PropertyMortgageCard({
    super.key,
    required this.propertyId,
    required this.price,
    required this.title,
  });

  @override
  State<PropertyMortgageCard> createState() => _PropertyMortgageCardState();
}

class _PropertyMortgageCardState extends State<PropertyMortgageCard> {
  MortgageSettings _s = const MortgageSettings();
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await MortgageMemory.read(mortgageUserId(context));
    if (saved != null && mounted) setState(() => _s = saved);
  }

  Future<void> _openCalculator() async {
    await context
        .push(mortgageRoute(widget.propertyId, widget.price, widget.title));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final r = calculateMortgage(_s.inputFor(widget.price));
    final summary = !r.hasLoan
        ? l10n.mortgageNoLoan
        : r.isRange
            ? l10n.mortgageRangePerMonth(formatCents(r.firstPaymentCents),
                formatCents(r.lastPaymentCents))
            : l10n.mortgageFromPerMonth(formatCents(r.firstPaymentCents));

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const ValueKey('mortgage-card-toggle'),
            borderRadius: BorderRadius.circular(AppMetrics.radiusMd),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EyebrowLabel(l10n.mortgageTitle),
                        const SizedBox(height: 6),
                        Text(
                          summary,
                          key: const ValueKey('mortgage-card-summary'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: t.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: t.textHint,
                  ),
                ],
              ),
            ),
          ),
          if (_open) _Details(settings: _s, result: r, onOpen: _openCalculator),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final MortgageSettings settings;
  final MortgageResult result;
  final VoidCallback onOpen;
  const _Details(
      {required this.settings, required this.result, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final muted = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11.5, color: t.textSecondary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            [
              l10n.mortgageDownSummary(
                formatPercent(settings.downPercent),
                formatRate(settings.ratePercent),
                l10n.mortgageTermYears(settings.termYears),
              ),
              mortgageTypeLabel(l10n, settings.type),
            ].join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
          if (result.hasLoan) ...[
            const SizedBox(height: 10),
            _Line(
                label: l10n.mortgageLoan, value: formatCents(result.loanCents)),
            _Line(
                label: l10n.mortgageOverpayment,
                value: formatCents(result.overpaymentCents)),
            _Line(
                label: l10n.mortgageIncomeNeeded,
                value: formatCents(result.requiredIncomeCents)),
          ],
          const SizedBox(height: 8),
          Text(l10n.mortgagePresetsNote,
              maxLines: 3, overflow: TextOverflow.ellipsis, style: muted),
          const SizedBox(height: 12),
          AppGhostButton(
            key: const ValueKey('mortgage-open-calculator'),
            label: l10n.mortgageOpenCalculator,
            icon: Icons.calculate_outlined,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    color: t.textSecondary)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary)),
          ),
        ],
      ),
    );
  }
}
