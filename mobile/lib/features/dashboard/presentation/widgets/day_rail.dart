import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';

const _startHour = 8;
const _endHour = 22;

class DayRail extends StatelessWidget {
  final List<MeetingResponse> meetings;
  final DateTime now;
  final int? focusId;

  const DayRail({
    super.key,
    required this.meetings,
    required this.now,
    this.focusId,
  });

  static double _position(DateTime at) {
    final hours = at.hour + at.minute / 60.0;
    return ((hours - _startHour) / (_endHour - _startHour)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final onHero = t.heroText;
    final elapsed = _position(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(height: 1, color: onHero.withValues(alpha: 0.12)),
        const SizedBox(height: 14),
        SizedBox(
          height: 22,
          child: LayoutBuilder(
            builder: (ctx, box) {
              final width = box.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 10,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: onHero.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 10,
                    child: Container(
                      height: 2,
                      width: width * elapsed,
                      decoration: BoxDecoration(
                        color: t.accent.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  for (final m in meetings)
                    _Dot(
                      left: width * _position(m.scheduledAt),
                      focused: m.id == focusId,
                      past: m.scheduledAt.isBefore(now),
                      onHero: onHero,
                      accent: t.accent,
                      ring: t.heroSurface,
                      muted: t.heroTextMuted,
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text('$_startHour:00', style: _edgeStyle(t)),
            Expanded(
              child: Text(
                formatTimeOfDay(now),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: t.accent),
              ),
            ),
            Text('$_endHour:00', style: _edgeStyle(t)),
          ],
        ),
      ],
    );
  }

  TextStyle _edgeStyle(AppTokens t) => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 9.5,
        fontWeight: FontWeight.w500,
        color: t.heroTextMuted,
      );
}

class _Dot extends StatelessWidget {
  final double left;
  final bool focused;
  final bool past;
  final Color onHero;
  final Color accent;
  final Color ring;
  final Color muted;

  const _Dot({
    required this.left,
    required this.focused,
    required this.past,
    required this.onHero,
    required this.accent,
    required this.ring,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final size = focused ? 18.0 : 10.0;
    return Positioned(
      left: (left - size / 2).clamp(0.0, double.infinity),
      top: 11 - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: focused
              ? accent
              : (past ? muted : onHero.withValues(alpha: 0.35)),
          shape: BoxShape.circle,
          border: focused ? Border.all(color: ring, width: 3) : null,
        ),
      ),
    );
  }
}
