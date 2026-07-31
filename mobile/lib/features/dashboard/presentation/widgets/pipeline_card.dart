import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
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
      _Stage(
          DealStatus.LEAD, l10n.coreStatusLead, pipeline.leads, AppColors.lead),
      _Stage(DealStatus.NEGOTIATION, l10n.coreStatusNegotiation,
          pipeline.negotiation, AppColors.negotiation),
      _Stage(DealStatus.CLOSED_WON, l10n.coreStatusWon, pipeline.won,
          AppColors.closedWon),
    ];
    final visible = stages.where((s) => s.count > 0).toList();

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
            height: 9,
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
          const SizedBox(height: 11),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              for (final s in stages)
                _LegendChip(
                  label: '${s.label} ${s.count}',
                  color: s.color,
                  onTap: () => onStageTap(s.status),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stage {
  final DealStatus status;
  final String label;
  final int count;
  final Color color;
  const _Stage(this.status, this.label, this.count, this.color);
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

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _LegendChip(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11,
                color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}
