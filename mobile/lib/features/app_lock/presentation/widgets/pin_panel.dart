import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/app_lock/presentation/widgets/pin_pad.dart';

/// A title, the dots, a line under them, the pad, and whatever goes below —
/// the one layout the lock screen and every step of the setup share. The pad
/// is sized from the room it has, never below [PinPad.minKey].
class PinPanel extends StatelessWidget {
  final Widget? header;
  final String title;
  final String? message;
  final bool messageIsError;
  final int dots;
  final int filled;
  final int errorTick;
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final List<Widget> footer;

  const PinPanel({
    super.key,
    this.header,
    required this.title,
    this.message,
    this.messageIsError = false,
    required this.dots,
    required this.filled,
    this.errorTick = 0,
    this.enabled = true,
    required this.onDigit,
    required this.onDelete,
    this.footer = const [],
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return LayoutBuilder(builder: (context, box) {
      final byWidth = (box.maxWidth - 40 - PinPad.gap * 3.2) / 3;
      final byHeight = (box.maxHeight * 0.52 - PinPad.gap * 3) / 4;
      final keySize = math.max(
          PinPad.minKey, math.min(PinPad.maxKey, math.min(byWidth, byHeight)));

      return Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (header != null) ...[
                      header!,
                      const SizedBox(height: 16)
                    ],
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary),
                    ),
                    const SizedBox(height: 18),
                    PinDots(length: dots, filled: filled, errorTick: errorTick),
                    const SizedBox(height: 14),
                    Text(
                      message ?? '',
                      key: const ValueKey('pin-message'),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12.5,
                          color:
                              messageIsError ? t.dangerText : t.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PinPad(
            keySize: keySize,
            enabled: enabled,
            onDigit: onDigit,
            onDelete: onDelete,
          ),
          if (footer.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < footer.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    footer[i],
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      );
    });
  }
}

/// A plain text button under the pad, at least 44 tall.
class PinTextAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const PinTextAction(
      {super.key, required this.label, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: color ?? t.textSecondary),
      ),
    );
  }
}
