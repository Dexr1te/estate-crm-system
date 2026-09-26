import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class PropertyShareLinkCard extends StatefulWidget {
  final int propertyId;
  final String title;
  final bool canRevoke;

  const PropertyShareLinkCard({
    super.key,
    required this.propertyId,
    required this.title,
    required this.canRevoke,
  });

  @override
  State<PropertyShareLinkCard> createState() => _PropertyShareLinkCardState();
}

class _PropertyShareLinkCardState extends State<PropertyShareLinkCard> {
  PropertyShareLink? _link;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    PropertyShareLink link;
    try {
      link =
          await Injector.propertiesRepository.getShareLink(widget.propertyId);
    } catch (_) {
      link = const PropertyShareLink();
    }
    if (mounted) setState(() => _link = link);
  }

  Future<void> _run(Future<PropertyShareLink> Function() action) async {
    setState(() => _busy = true);
    try {
      final link = await action();
      if (mounted) setState(() => _link = link);
    } catch (err) {
      if (mounted) {
        showActionUnavailable(
            context,
            apiFailureLabel(
                AppLocalizations.of(context), ApiFailure.from(err)));
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _create() => _run(
      () => Injector.propertiesRepository.createShareLink(widget.propertyId));

  Future<void> _revoke() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l10n.propertiesLinkRevokeTitle,
      content: l10n.propertiesLinkRevokeConfirm,
      confirmLabel: l10n.propertiesLinkRevoke,
      icon: Icons.link_off_rounded,
    );
    if (!ok || !mounted) return;
    await _run(() async {
      await Injector.propertiesRepository.revokeShareLink(widget.propertyId);
      return const PropertyShareLink();
    });
  }

  void _copy(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).propertiesLinkCopied,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          duration: const Duration(seconds: 1)));
  }

  Future<void> _share(String url) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await Injector.shareGateway
        .share(text: '${widget.title.trim()}\n$url', subject: widget.title);
    if (mounted && outcome == ShareOutcome.failed) {
      showActionUnavailable(context, l10n.clientsSendFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = _link;
    if (link == null) {
      return const ShimmerGroup(
          child: ShimmerInfoCard(rows: 1, heading: true, buttons: 1));
    }

    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final url = link.url;

    return AppCard(
      key: const ValueKey('share-link-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.propertiesLink),
          const SizedBox(height: 10),
          if (url == null) ...[
            _Line(l10n.propertiesLinkHint, color: t.textSecondary, lines: 3),
            const SizedBox(height: 12),
            AppFilledButton(
              key: const ValueKey('share-link-create'),
              label: l10n.propertiesLinkCreate,
              loading: _busy,
              onPressed: _busy ? null : _create,
            ),
          ] else ...[
            AppCard(
              nested: true,
              radius: AppMetrics.radiusSm,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: _Line(url,
                  color: t.textPrimary, weight: FontWeight.w600, lines: 2),
            ),
            const SizedBox(height: 8),
            _Line(_viewsLine(l10n, link), color: t.textSecondary, lines: 2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppGhostButton(
                    key: const ValueKey('share-link-copy'),
                    label: l10n.propertiesLinkCopy,
                    icon: Icons.copy_rounded,
                    onPressed: _busy ? null : () => _copy(url),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppFilledButton(
                    key: const ValueKey('share-link-share'),
                    label: l10n.propertiesLinkShare,
                    onPressed: _busy ? null : () => _share(url),
                  ),
                ),
              ],
            ),
            if (widget.canRevoke) ...[
              const SizedBox(height: 8),
              AppGhostButton(
                key: const ValueKey('share-link-revoke'),
                label: l10n.propertiesLinkRevoke,
                icon: Icons.link_off_rounded,
                labelColor: t.dangerText,
                loading: _busy,
                onPressed: _busy ? null : _revoke,
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _viewsLine(AppLocalizations l10n, PropertyShareLink link) {
    final views = l10n.propertiesLinkViews(link.viewCount);
    final last = link.lastViewedAt;
    if (link.viewCount == 0 || last == null) return views;
    final date = formatFullDate(last.toLocal(), l10n.localeName);
    return '$views · ${l10n.propertiesLinkLastViewed(date)}';
  }
}

class _Line extends StatelessWidget {
  final String text;
  final Color color;
  final FontWeight weight;
  final int lines;
  const _Line(this.text,
      {required this.color, this.weight = FontWeight.w400, this.lines = 1});

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: lines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 12.5,
            height: 1.35,
            fontWeight: weight,
            color: color),
      );
}
