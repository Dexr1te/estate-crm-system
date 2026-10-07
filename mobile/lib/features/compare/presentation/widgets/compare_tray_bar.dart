import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/domain/comparison.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Under the properties list: once the comparison tray holds two or more
/// listings set aside from their pages, the way back to comparing them.
/// Nothing at all while the tray is short of two.
class CompareTrayBar extends StatefulWidget {
  final double pad;
  const CompareTrayBar({super.key, required this.pad});

  @override
  State<CompareTrayBar> createState() => _CompareTrayBarState();
}

class _CompareTrayBarState extends State<CompareTrayBar> {
  @override
  void initState() {
    super.initState();
    Injector.comparisonTray.load();
  }

  @override
  Widget build(BuildContext context) {
    final tray = Injector.comparisonTray;
    return ListenableBuilder(
      listenable: tray,
      builder: (context, _) {
        if (tray.length < 2) return const SizedBox.shrink();
        final t = context.tokens;
        return Padding(
          key: const ValueKey('compare-tray-bar'),
          padding: EdgeInsets.fromLTRB(
              widget.pad, 8, widget.pad, 8 + AppMetrics.navClearance(context)),
          child: GlassSurface(
            blur: AppMetrics.glassBlur,
            fill: t.glassFillStrong,
            borderRadius: BorderRadius.circular(AppMetrics.radiusLg),
            shadow: GlassShadow.floating,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AppGhostButton(
                key: const ValueKey('compare-tray-bar-open'),
                label:
                    AppLocalizations.of(context).compareBarButton(tray.length),
                icon: Icons.compare_arrows_rounded,
                onPressed: () => context.push(compareLocation(tray.ids)),
              ),
            ),
          ),
        );
      },
    );
  }
}
