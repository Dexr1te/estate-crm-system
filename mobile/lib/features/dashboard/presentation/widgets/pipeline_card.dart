import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class PipelineCard extends StatelessWidget {
  final PipelineBreakdown pipeline;
  final void Function(DealStatus status) onStageTap;

  const PipelineCard(
      {super.key, required this.pipeline, required this.onStageTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    final stages = <_Stage>[
      _Stage(DealStatus.LEAD, l10n.coreStatusLead, pipeline.leads,
          pipeline.leadValue, t.chartLead),
      _Stage(DealStatus.NEGOTIATION, l10n.coreStatusNegotiation,
          pipeline.negotiation, pipeline.negotiationValue, t.chartNegotiation),
      _Stage(DealStatus.CLOSED_WON, l10n.coreStatusWon, pipeline.won,
          pipeline.wonValue, t.chartWon),
    ];
    final visible = stages.where((s) => s.count > 0).toList();
    final rate = pipeline.winRate;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardTeamPipeline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatPrice(pipeline.totalValue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 10,
            child: Row(
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Expanded(
                    flex: visible[i].count,
                    child: _Segment(
                      color: visible[i].color,
                      onTap: () => onStageTap(visible[i].status),
                    ),
                  ),
                ],
                if (pipeline.lost > 0) ...[
                  if (visible.isNotEmpty) const SizedBox(width: 3),
                  Expanded(
                    flex: pipeline.lost,
                    child: _Segment(color: t.border, onTap: null),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < stages.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _StageColumn(
                    stage: stages[i],
                    onTap: () => onStageTap(stages[i].status),
                  ),
                ),
              ],
            ],
          ),
          if (rate != null) ...[
            const SizedBox(height: 13),
            Container(height: 1, color: t.border),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.dashboardConversion,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11,
                      color: t.textSecondary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: ColoredBox(color: t.chartTrack)),
                          FractionallySizedBox(
                            widthFactor: rate.clamp(0.0, 1.0),
                            child: ColoredBox(color: t.chartWon),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(rate * 100).round()}%',
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stage {
  final DealStatus status;
  final String label;
  final int count;
  final double value;
  final Color color;
  const _Stage(this.status, this.label, this.count, this.value, this.color);
}

class _StageColumn extends StatelessWidget {
  final _Stage stage;
  final VoidCallback onTap;
  const _StageColumn({required this.stage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: stage.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  stage.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 10.5,
                      color: t.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${stage.count}',
            maxLines: 1,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 15,
                height: 1,
                fontWeight: FontWeight.w700,
                color: t.textPrimary),
          ),
          const SizedBox(height: 3),
          Text(
            formatPrice(stage.value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 10.5, color: t.textHint),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;
  const _Segment({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
}
