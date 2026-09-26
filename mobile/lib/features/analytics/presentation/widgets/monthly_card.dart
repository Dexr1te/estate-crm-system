import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MonthlyCard extends StatelessWidget {
  final List<FunnelMonth> months;
  const MonthlyCard({super.key, required this.months});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final won = StatusPalette.resolve(t, StatusHue.positive).label;
    final lost = StatusPalette.resolve(t, StatusHue.danger).label;
    final peak = months.fold<int>(
        0,
        (m, p) =>
            [m, p.created, p.won, p.lost].reduce((a, b) => a > b ? a : b));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.analyticsMonthly),
          const SizedBox(height: 14),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < months.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Bar(months[i].created, peak, t.textSecondary),
                        const SizedBox(width: 2),
                        _Bar(months[i].won, peak, won),
                        const SizedBox(width: 2),
                        _Bar(months[i].lost, peak, lost),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < months.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatMonthShort(months[i].month, locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 10.5,
                        color: t.textSecondary),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _Legend(l10n.analyticsCreated, t.textSecondary),
              _Legend(dealStatusLabel(l10n, DealStatus.CLOSED_WON), won),
              _Legend(dealStatusLabel(l10n, DealStatus.CLOSED_LOST), lost),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final int value;
  final int peak;
  final Color color;
  const _Bar(this.value, this.peak, this.color);

  @override
  Widget build(BuildContext context) {
    final f = peak == 0 ? 0.0 : value / peak;
    return Expanded(
      child: FractionallySizedBox(
        alignment: Alignment.bottomCenter,
        heightFactor: value == 0 ? 0.02 : f.clamp(0.04, 1.0).toDouble(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: value == 0 ? context.tokens.chartTrack : color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11,
                color: context.tokens.textSecondary),
          ),
        ),
      ],
    );
  }
}
