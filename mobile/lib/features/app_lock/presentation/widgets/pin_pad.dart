import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Ten digits and a delete key, each a circle no smaller than [minKey].
class PinPad extends StatelessWidget {
  final double keySize;
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  static const double minKey = 48;
  static const double maxKey = 72;
  static const double gap = 14;

  const PinPad({
    super.key,
    required this.keySize,
    required this.onDigit,
    required this.onDelete,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var c = 0; c < 3; c++) ...[
                if (c > 0) const SizedBox(width: gap * 1.6),
                _key(context, rows[r][c]),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _key(BuildContext context, String value) {
    final t = context.tokens;
    if (value.isEmpty) return SizedBox.square(dimension: keySize);
    final delete = value == '<';

    return SizedBox.square(
      dimension: keySize,
      child: Material(
        color: delete ? Colors.transparent : t.surfaceVariant,
        shape: const CircleBorder(),
        child: InkWell(
          key: ValueKey('pin-key-$value'),
          customBorder: const CircleBorder(),
          onTap: enabled ? () => delete ? onDelete() : onDigit(value) : null,
          child: Center(
            child: delete
                ? Icon(Icons.backspace_outlined,
                    size: 22,
                    color: t.textSecondary,
                    semanticLabel: AppLocalizations.of(context).lockDelete)
                : Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: MediaQuery.textScalerOf(context)
                        .clamp(maxScaleFactor: 1.3),
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: keySize * 0.36,
                        fontWeight: FontWeight.w600,
                        color: enabled ? t.textPrimary : t.textHint),
                  ),
          ),
        ),
      ),
    );
  }
}

/// A dot per digit, filled as they are typed. Shakes when [errorTick] moves.
class PinDots extends StatefulWidget {
  final int length;
  final int filled;
  final int errorTick;

  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.errorTick = 0,
  });

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots> with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(PinDots old) {
    super.didUpdateWidget(old);
    if (old.errorTick != widget.errorTick) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final v = _shake.value;
        final dx = math.sin(v * math.pi * 6) * 10 * (1 - v);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Row(
        key: const ValueKey('pin-dots'),
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < widget.filled ? t.textPrimary : Colors.transparent,
                border: Border.all(color: t.textSecondary, width: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
