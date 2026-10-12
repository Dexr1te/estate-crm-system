import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

class RowChevron extends StatelessWidget {
  final Color? color;

  const RowChevron({super.key, this.color});

  static const double size = 18;
  static const double _sideBearing = 5;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Transform.translate(
      offset: Offset(rtl ? -_sideBearing : _sideBearing, 0),
      child: Icon(
        rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        size: size,
        color: color ?? context.tokens.textHint,
      ),
    );
  }
}
