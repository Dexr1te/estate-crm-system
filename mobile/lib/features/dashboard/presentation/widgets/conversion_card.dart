import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class ConversionCard extends StatelessWidget {
  final PipelineBreakdown pipeline;
  final void Function(DealStatus status) onStageTap;

  const ConversionCard(
      {super.key, required this.pipeline, required this.onStageTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final rate = pipeline.winRate;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(l10n.dashboardConversion),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: CustomPaint(
                  painter: _RingPainter(
                    fraction: rate ?? 0,
                    fill: t.chartWon,
                    track: rate == null ? t.chartTrack : t.chartLost,
                  ),
                  child: Center(
                    child: Text(
                      rate == null ? '—' : '${(rate * 100).round()}%',
                      maxLines: 1,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 21,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Legend(
                      color: t.chartWon,
                      label: l10n.coreStatusWon,
                      count: pipeline.won,
                      onTap: () => onStageTap(DealStatus.CLOSED_WON),
                    ),
                    const SizedBox(height: 9),
                    _Legend(
                      color: t.chartLost,
                      label: l10n.coreStatusLost,
                      count: pipeline.lost,
                      onTap: () => onStageTap(DealStatus.CLOSED_LOST),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      l10n.dashboardDecidedDeals(pipeline.decided),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 11,
                          color: t.textHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final VoidCallback onTap;
  const _Legend({
    required this.color,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Expanded(
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
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: t.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color fill;
  final Color track;
  const _RingPainter(
      {required this.fraction, required this.fill, required this.track});

  static const _stroke = 9.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Rect.fromLTWH(0, 0, size.width, size.height).deflate(_stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    if (fraction <= 0) return;
    final sweep = math.pi * 2 * fraction.clamp(0.0, 1.0);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = fill;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.fill != fill || old.track != track;
}
