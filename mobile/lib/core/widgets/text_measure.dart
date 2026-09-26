import 'package:flutter/widgets.dart';

/// The width [text] takes on one line in [style], at the text scale and
/// direction in force at [context]. For rows that must decide whether a label
/// still fits beside its neighbour or should move to a line of its own.
double singleLineTextWidth(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}
