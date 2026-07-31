import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

/// Opens a modal bottom sheet with the handoff's chrome: radius 24 top
/// corners, a 38×4 grab handle, an optional 700/19 title over a helper line,
/// and a `rgba(15,30,60,.42)` scrim.
///
/// The sheet follows the app theme — dark in dark mode, per screens 5n/5o.
/// (It used to be forced light in both themes; that predates this design.)
///
/// The content is wrapped so it scrolls and clears the keyboard, which is what
/// the invite and picker sheets need.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  String? subtitle,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: AppTokens.of(context).sheetScrim,
    builder: (ctx) => AppSheetShell(title: title, subtitle: subtitle, child: builder(ctx)),
  );
}

/// The sheet body: grab handle, optional heading, then the caller's content.
class AppSheetShell extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;

  const AppSheetShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final mq = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.9),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 26 + mq.viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: t.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: t.textPrimary),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 12,
                      height: 1.5,
                      color: t.textSecondary),
                ),
              ],
              if (title != null || subtitle != null)
                SizedBox(height: AppMetrics.blockGap(context) + 4),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
