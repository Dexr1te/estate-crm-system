import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_cover.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

String composeMatchesMessage(
    AppLocalizations l10n, List<PropertyResponse> properties,
    {Map<int, String> links = const {}}) {
  final buffer = StringBuffer(l10n.clientsSendGreeting);
  for (var i = 0; i < properties.length; i++) {
    final p = properties[i];
    final place = [
      if (p.address.trim().isNotEmpty) p.address.trim(),
      if (p.city != null && p.city!.trim().isNotEmpty) p.city!.trim(),
    ].join(', ');
    final type = propertyTypeLabel(l10n, p.type);
    final specs = propertySpecs(l10n, p);
    buffer
      ..write('\n\n${i + 1}. ${p.title.trim()}')
      ..write(specs == type ? '\n$type' : '\n$type · $specs');
    if (place.isNotEmpty) buffer.write('\n$place');
    if (p.price > 0) buffer.write('\n${formatPrice(p.price)}');
    final link = links[p.id];
    if (link != null && link.isNotEmpty) buffer.write('\n$link');
  }
  buffer.write('\n\n${l10n.clientsSendClosing}');
  return buffer.toString();
}

Future<void> showSendMatchesSheet(
  BuildContext context, {
  required ClientResponse client,
  required List<PropertyMatch> matches,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<void>(
    context,
    title: l10n.clientsSendMatches,
    subtitle: client.fullName,
    builder: (_) => SendMatchesSheet(client: client, matches: matches),
  );
}

class SendMatchesSheet extends StatefulWidget {
  final ClientResponse client;
  final List<PropertyMatch> matches;
  const SendMatchesSheet(
      {super.key, required this.client, required this.matches});

  @override
  State<SendMatchesSheet> createState() => _SendMatchesSheetState();
}

class _SendMatchesSheetState extends State<SendMatchesSheet> {
  late final Set<int> _selected = {
    for (final m in widget.matches) m.property.id,
  };
  bool _withPhotos = true;
  bool _withLinks = true;
  bool _sending = false;

  List<PropertyResponse> get _chosen => [
        for (final m in widget.matches)
          if (_selected.contains(m.property.id)) m.property,
      ];

  bool get _hasPhone =>
      (widget.client.phone ?? '').replaceAll(RegExp(r'\D'), '').isNotEmpty;

  void _toggle(int id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  Future<String> _message(
      AppLocalizations l10n, List<PropertyResponse> chosen) async {
    if (!_withLinks || chosen.isEmpty) {
      return composeMatchesMessage(l10n, chosen);
    }
    setState(() => _sending = true);
    final urls = await Future.wait(chosen.map((p) => Injector
        .propertiesRepository
        .createShareLink(p.id)
        .then<String?>((link) => link.url)
        .catchError((Object _) => null)));
    if (mounted) setState(() => _sending = false);
    return composeMatchesMessage(l10n, chosen, links: {
      for (var i = 0; i < chosen.length; i++)
        if (urls[i] != null) chosen[i].id: urls[i]!,
    });
  }

  Future<void> _whatsApp() async {
    final l10n = AppLocalizations.of(context);
    final text = await _message(l10n, _chosen);
    if (!mounted) return;
    final ok = await ContactActions.whatsApp(widget.client.phone, text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      showActionUnavailable(context, l10n.clientsSendFailed);
    }
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final chosen = _chosen;
    final text = await _message(l10n, chosen);
    if (!mounted) return;
    setState(() => _sending = true);
    final images = <SharedImage>[];
    if (_withPhotos) {
      final covers =
          await Future.wait(chosen.map((p) => PropertyCovers.of(p.id)));
      for (var i = 0; i < chosen.length; i++) {
        final bytes = covers[i];
        if (bytes != null && bytes.isNotEmpty) {
          images
              .add(SharedImage(name: 'listing-${chosen[i].id}', bytes: bytes));
        }
      }
    }
    final outcome = await Injector.shareGateway.share(
      text: text,
      subject: l10n.clientsSendMatches,
      images: images,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    switch (outcome) {
      case ShareOutcome.shared:
        Navigator.of(context).pop();
      case ShareOutcome.dismissed:
        break;
      case ShareOutcome.failed:
        showActionUnavailable(context, l10n.clientsSendFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final nothing = _selected.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EyebrowLabel(l10n.clientsSendSelected(_selected.length)),
        const SizedBox(height: 10),
        for (var i = 0; i < widget.matches.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _PickRow(
            property: widget.matches[i].property,
            selected: _selected.contains(widget.matches[i].property.id),
            onTap: () => _toggle(widget.matches[i].property.id),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.clientsSendPhotos,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: t.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.clientsSendPhotosHint,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        height: 1.35,
                        color: t.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppSwitch(
              value: _withPhotos,
              onChanged: (v) => setState(() => _withPhotos = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _OptionRow(
          key: const ValueKey('send-links'),
          title: l10n.clientsSendLinks,
          hint: l10n.clientsSendLinksHint,
          value: _withLinks,
          onChanged: (v) => setState(() => _withLinks = v),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AppGhostButton(
                label: l10n.clientsSendWhatsApp,
                onPressed: nothing || _sending || !_hasPhone ? null : _whatsApp,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppFilledButton(
                label: l10n.clientsSendShare,
                loading: _sending,
                onPressed: nothing || _sending ? null : _share,
              ),
            ),
          ],
        ),
        if (!_hasPhone) ...[
          const SizedBox(height: 10),
          Text(
            l10n.clientsNoWhatsApp,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11.5, color: t.textHint),
          ),
        ],
      ],
    );
  }
}

class _PickRow extends StatelessWidget {
  final PropertyResponse property;
  final bool selected;
  final VoidCallback onTap;
  const _PickRow(
      {required this.property, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          PropertyCover.of(property, size: 36, radius: 10),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  '${propertySpecs(l10n, property)} · ${formatPrice(property.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: selected ? t.accent : t.textHint,
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String title;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _OptionRow({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: t.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                hint,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    height: 1.35,
                    color: t.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        AppSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
