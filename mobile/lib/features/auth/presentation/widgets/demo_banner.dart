import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const demoEmailDomain = '@demo.estatecrm.app';

bool isDemoEmail(String? email) =>
    email != null &&
    email.trim().toLowerCase().startsWith('demo-') &&
    email.trim().toLowerCase().endsWith(demoEmailDomain);

class DemoBanner extends StatelessWidget {
  final String? email;
  final VoidCallback onCreateAccount;
  final Widget child;

  const DemoBanner({
    super.key,
    required this.email,
    required this.onCreateAccount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final demo = isDemoEmail(email);
    return Column(children: [
      if (demo) _Strip(onCreateAccount: onCreateAccount),
      Expanded(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: demo,
          child: child,
        ),
      ),
    ]);
  }
}

class _Strip extends StatelessWidget {
  final VoidCallback onCreateAccount;
  const _Strip({required this.onCreateAccount});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final tone = StatusPalette.resolve(t, StatusHue.neutral);

    return Material(
      key: const Key('demo-banner'),
      color: tone.fill,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 4),
          child: Row(children: [
            Icon(Icons.play_circle_outline_rounded,
                size: 16, color: tone.label),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.authDemoBanner,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: AppType.subhead,
                  fontWeight: FontWeight.w600,
                  color: tone.label,
                ),
              ),
            ),
            InkWell(
              key: const Key('demo-banner-create-account'),
              onTap: onCreateAccount,
              borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppMetrics.minHitTarget,
                  minWidth: AppMetrics.minHitTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    widthFactor: 1,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.45,
                      ),
                      child: Text(
                        l10n.authDemoCreateAccount,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: AppType.subhead,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
