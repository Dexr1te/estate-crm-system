import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class GoalRingCard extends StatelessWidget {
  final double achieved;
  final double? target;
  final VoidCallback onEdit;

  const GoalRingCard({
    super.key,
    required this.achieved,
    required this.target,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final hasTarget = target != null && target! > 0;
    final fraction = hasTarget ? (achieved / target!).clamp(0.0, 1.0) : 0.0;
    final percent = (fraction * 100).round();

    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: CustomPaint(
                painter: _RingPainter(
                  fraction: fraction,
                  sweep: t.accent,
                  track: t.chartTrack,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasTarget)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$percent',
                              style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  fontSize: 24,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  color: t.textPrimary),
                            ),
                            Text(
                              '%',
                              style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: t.textPrimary),
                            ),
                          ],
                        )
                      else
                        Icon(Icons.add_rounded, size: 22, color: t.textHint),
                      const SizedBox(height: 3),
                      Text(
                        l10n.dashboardGoalEyebrow,
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
                    l10n.dashboardGoalTitle,
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
                          formatPrice(achieved),
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 20,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: t.textPrimary),
                        ),
                        if (hasTarget) ...[
                          const SizedBox(width: 5),
                          Text(
                            '/ ${formatPrice(target!)}',
                            style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontSize: 11.5,
                                color: t.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasTarget
                        ? (achieved >= target!
                            ? l10n.dashboardGoalReached
                            : l10n.dashboardGoalRemaining(
                                formatPrice(target! - achieved)))
                        : l10n.dashboardGoalUnset,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        height: 1.35,
                        color: t.textSecondary),
                  ),
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

Future<double?> showGoalSheet(BuildContext context, double? current) {
  final controller = TextEditingController(
      text: current == null ? '' : current.round().toString());
  final l10n = AppLocalizations.of(context);

  return showAppBottomSheet<double?>(
    context,
    title: l10n.dashboardGoalSheetTitle,
    subtitle: l10n.dashboardGoalSheetHint,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: controller,
          hint: l10n.dashboardGoalSheetField,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        const SizedBox(height: 14),
        AppFilledButton(
          label: l10n.coreSave,
          onPressed: () =>
              Navigator.of(ctx).pop(double.tryParse(controller.text.trim())),
        ),
        const SizedBox(height: 9),
        AppGhostButton(
          label: l10n.dashboardGoalClear,
          onPressed: () => Navigator.of(ctx).pop(0),
        ),
      ],
    ),
  );
}
