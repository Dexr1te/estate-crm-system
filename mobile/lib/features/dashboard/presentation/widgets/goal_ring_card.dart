import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/goals/domain/goal_pace.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The month's target on the dashboard: a ring with how much of it is done,
/// the commission and the deals won against it, the days left and what each
/// of them has to bring. Without a target it still shows what the month has
/// brought, and says how to set one when [onTap] is given.
class GoalRingCard extends StatelessWidget {
  final GoalProgress goal;
  final VoidCallback? onTap;

  const GoalRingCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final hasTarget = goal.hasTarget;
    final percent = goalPercent(goal);
    final commissionTarget = goal.commissionTarget;
    final dealsTarget = goal.dealsTarget;

    final String status;
    if (!hasTarget) {
      status = onTap != null ? l10n.goalsNoneHint : l10n.goalsNone;
    } else if (goalReached(goal)) {
      status = l10n.goalsReached;
    } else {
      status = goalPace(l10n, goal);
    }

    final secondary = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11.5,
        height: 1.35,
        color: t.textSecondary);

    return GestureDetector(
      key: const ValueKey('goal-card'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: CustomPaint(
                painter: _RingPainter(
                  fraction: goalFraction(goal),
                  sweep: t.accent,
                  track: t.chartTrack,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (percent != null)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$percent',
                                maxLines: 1,
                                style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    fontSize: 24,
                                    height: 1,
                                    fontWeight: FontWeight.w700,
                                    color: t.textPrimary),
                              ),
                              Text(
                                '%',
                                maxLines: 1,
                                style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: t.textPrimary),
                              ),
                            ],
                          ),
                        )
                      else
                        Icon(Icons.flag_outlined, size: 22, color: t.textHint),
                      const SizedBox(height: 3),
                      Text(
                        l10n.goalsEyebrow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.6,
                            color: t.textHint),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.goalsCardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatPrice(goal.commissionAchieved),
                          key: const ValueKey('goal-achieved'),
                          maxLines: 1,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 20,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: t.textPrimary),
                        ),
                        if (commissionTarget != null) ...[
                          const SizedBox(width: 5),
                          Text(
                            '/ ${formatPrice(commissionTarget)}',
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: 11.5,
                                color: t.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dealsTarget != null
                        ? l10n.goalsDealsOf(goal.dealsWon, dealsTarget)
                        : l10n.goalsDealsWon(goal.dealsWon),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: t.textPrimary),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    status,
                    key: const ValueKey('goal-status'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: secondary,
                  ),
                  if (hasTarget) ...[
                    const SizedBox(height: 5),
                    Text(
                      goal.setByManager ? l10n.goalsManagerSet : l10n.goalsOwn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 10.5,
                          color: t.textHint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color sweep;
  final Color track;
  const _RingPainter(
      {required this.fraction, required this.sweep, required this.track});

  static const _stroke = 11.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Rect.fromLTWH(0, 0, size.width, size.height).deflate(_stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = track,
    );

    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = sweep,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.sweep != sweep || old.track != track;
}

class GoalRingCardBone extends StatelessWidget {
  const GoalRingCardBone({super.key});

  @override
  Widget build(BuildContext context) => ShimmerCard(
        radius: AppMetrics.radiusMd,
        padding: EdgeInsets.all(AppMetrics.cardPadding(context)),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: CustomPaint(painter: _RingBonePainter()),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBar(widthFactor: 0.52, height: 11),
                  SizedBox(height: 12),
                  ShimmerBar(widthFactor: 0.74, height: 18),
                  SizedBox(height: 11),
                  ShimmerBar(widthFactor: 0.62, height: 10),
                ],
              ),
            ),
          ],
        ),
      );
}

class _RingBonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height).deflate(5),
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
