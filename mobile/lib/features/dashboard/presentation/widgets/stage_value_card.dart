import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Money per stage as horizontal bars.
///
/// The pipeline card next to this one counts *deals*; this one counts money,
/// which ranks the stages very differently when a single large deal sits in
/// negotiation. Bars are scaled to the largest stage, not to the total, so a
/// small stage still reads as a visible sliver.
class StageValueCard extends StatelessWidget {
  final PipelineBreakdown pipeline;
  final void Function(DealStatus status) onStageTap;

  const StageValueCard(
      {super.key, required this.pipeline, required this.onStageTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final peak = pipeline.peakStageValue;

    final rows = <_StageValue>[
      _StageValue(DealStatus.LEAD, l10n.coreStatusLead, pipeline.leadValue,
          pipeline.leads, t.chartLead),
      _StageValue(DealStatus.NEGOTIATION, l10n.coreStatusNegotiation,
          pipeline.negotiationValue, pipeline.negotiation, t.chartNegotiation),
      _StageValue(DealStatus.CLOSED_WON, l10n.coreStatusWon, pipeline.wonValue,
          pipeline.won, t.chartWon),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.dashboardValueByStage),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _Bar(row: rows[i], peak: peak, onTap: () => onStageTap(rows[i].status)),
          ],
        ],
      ),
    );
  }
}

class _StageValue {
  final DealStatus status;
  final String label;
  final double value;
  final int count;
  final Color color;
  const _StageValue(
      this.status, this.label, this.value, this.count, this.color);
}

class _Bar extends StatelessWidget {
  final _StageValue row;
  final double peak;
  final VoidCallback onTap;
  const _Bar({required this.row, required this.peak, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // A stage with money always keeps a visible stub, so "small" never reads
    // as "none".
    final fraction = peak <= 0 ? 0.0 : (row.value / peak).clamp(0.0, 1.0);
    final drawn = row.value > 0 ? fraction.clamp(0.04, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.count > 0 ? '${row.label} · ${row.count}' : row.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: t.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  formatPrice(row.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: t.chartTrack)),
                  FractionallySizedBox(
                    widthFactor: drawn,
                    child: ColoredBox(color: row.color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
