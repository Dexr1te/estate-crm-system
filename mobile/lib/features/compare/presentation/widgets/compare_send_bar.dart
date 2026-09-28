import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_rows.dart';
import 'package:real_estate_crm/features/compare/presentation/compare_share.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// "Send comparison", with the choice to put each listing's public page
/// under it — the same choice the send-listings sheet offers.
class CompareSendBar extends StatefulWidget {
  final List<ComparedListing> listings;
  const CompareSendBar({super.key, required this.listings});

  @override
  State<CompareSendBar> createState() => _CompareSendBarState();
}

class _CompareSendBarState extends State<CompareSendBar> {
  bool _withLinks = true;
  bool _sending = false;

  Future<Map<int, String>> _links() async {
    if (!_withLinks) return const {};
    final ids = [for (final l in widget.listings) l.property.id];
    final urls = await Future.wait(ids.map((id) => Injector.propertiesRepository
        .createShareLink(id)
        .then<String?>((link) => link.url)
        .catchError((Object _) => null)));
    return {
      for (var i = 0; i < ids.length; i++)
        if (urls[i] != null && urls[i]!.isNotEmpty) ids[i]: urls[i]!,
    };
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    final links = await _links();
    final text = composeComparisonMessage(l10n, widget.listings, AppClock.now(),
        links: links);
    final outcome = await Injector.shareGateway
        .share(text: text, subject: l10n.compareTitle);
    if (!mounted) return;
    setState(() => _sending = false);
    if (outcome == ShareOutcome.failed) {
      showActionUnavailable(context, l10n.compareSendFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final pad = AppMetrics.pagePadding(context);

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppMetrics.wideMaxContentWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 10, pad, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.compareLinks,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: t.textPrimary),
                            ),
                            Text(
                              l10n.compareLinksHint,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  fontSize: 11,
                                  height: 1.3,
                                  color: t.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppSwitch(
                        key: const ValueKey('compare-links'),
                        value: _withLinks,
                        onChanged: (v) => setState(() => _withLinks = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppFilledButton(
                    key: const ValueKey('compare-send'),
                    label: l10n.compareSend,
                    loading: _sending,
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
