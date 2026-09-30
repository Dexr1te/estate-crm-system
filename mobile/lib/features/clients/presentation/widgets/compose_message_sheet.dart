import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/message_templates/domain/template_filler.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_card.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Told what went out, as sent, and the listing it was about if one was
/// chosen — once WhatsApp or the messages app has taken it.
typedef ComposeSent = void Function(String text, int? propertyId);

Future<void> showComposeMessageSheet(
  BuildContext context, {
  required ClientResponse client,
  String? agentName,
  List<PropertyResponse> suggested = const [],
  ComposeSent? onSent,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<void>(
    context,
    title: l10n.clientsComposeTitle,
    subtitle: client.fullName,
    builder: (_) => ComposeMessageSheet(
      client: client,
      agentName: agentName,
      suggested: suggested,
      onSent: onSent,
    ),
  );
}

/// A message to a client over WhatsApp or SMS: typed, or started from one of
/// the agency's templates and filled in for this client, the agent and — if
/// one is chosen — a listing. The agent edits it freely before sending, and
/// what is sent is what the history records.
class ComposeMessageSheet extends StatefulWidget {
  final ClientResponse client;
  final String? agentName;

  /// Listings offered first in the picker: the client's matches.
  final List<PropertyResponse> suggested;
  final ComposeSent? onSent;

  const ComposeMessageSheet({
    super.key,
    required this.client,
    this.agentName,
    this.suggested = const [],
    this.onSent,
  });

  @override
  State<ComposeMessageSheet> createState() => _ComposeMessageSheetState();
}

class _ComposeMessageSheetState extends State<ComposeMessageSheet> {
  final _text = TextEditingController();
  MessageTemplate? _template;
  PropertyResponse? _listing;
  String? _link;

  /// The text as the template last filled it; while the field still says
  /// exactly this, choosing another listing fills the template again.
  String? _filled;
  bool _busy = false;

  bool get _hasPhone =>
      (widget.client.phone ?? '').replaceAll(RegExp(r'\D'), '').isNotEmpty;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Map<String, String> get _values => templateValues(
        clientName: widget.client.fullName,
        agentName: widget.agentName ?? widget.client.agentName,
        listing: _listing,
        link: _link,
      );

  /// What would go out now: the field as typed, with any placeholder still
  /// in it filled or dropped, so nothing in braces reaches the client.
  String get _outgoing => fillTemplate(_text.text, _values);

  void _fill() {
    final template = _template;
    if (template == null) return;
    final text = fillTemplate(template.body, _values);
    _text.value = TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
    _filled = text;
  }

  Future<T?> _loading<T>(Future<T> Function() load) async {
    setState(() => _busy = true);
    try {
      return await load();
    } catch (_) {
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickTemplate() async {
    final l10n = AppLocalizations.of(context);
    final templates =
        await _loading(Injector.messageTemplatesRepository.getTemplates);
    if (!mounted) return;
    if (templates == null) {
      showActionUnavailable(context, l10n.templatesLoadFailed);
      return;
    }
    final picked = await showEntityPicker(
      context,
      title: l10n.clientsComposePickTemplate,
      searchHint: l10n.clientsComposeSearchTemplates,
      emptyLabel: l10n.clientsComposeNoTemplates,
      selectedId: _template?.id,
      items: [
        for (final t in templates)
          PickerItem(
              id: t.id, title: t.title, subtitle: t.body.replaceAll('\n', ' ')),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _template = templates.firstWhere((t) => t.id == picked.id);
      _fill();
    });
  }

  Future<void> _pickListing() async {
    final l10n = AppLocalizations.of(context);
    final all = await _loading(Injector.propertiesRepository.getAllProperties);
    if (!mounted) return;
    final suggested = {for (final p in widget.suggested) p.id};
    final listings = [
      ...widget.suggested,
      ...?all?.where((p) => !suggested.contains(p.id)),
    ];
    final picked = await showEntityPicker(
      context,
      title: l10n.clientsComposePickListing,
      searchHint: l10n.clientsComposeSearchListings,
      emptyLabel: l10n.clientsComposeNoListings,
      selectedId: _listing?.id,
      items: [
        for (final p in listings)
          PickerItem(
              id: p.id,
              title: p.title,
              subtitle: '${propertySpecs(l10n, p)} · ${formatPrice(p.price)}'),
      ],
    );
    if (picked == null || !mounted) return;
    final listing = listings.firstWhere((p) => p.id == picked.id);
    final link = await _loading(() => Injector.propertiesRepository
        .getShareLink(listing.id)
        .then((l) => l.url));
    if (!mounted) return;
    _choose(listing, link);
  }

  void _choose(PropertyResponse? listing, String? link) {
    final untouched = _filled != null && _text.text == _filled;
    setState(() {
      _listing = listing;
      _link = link;
      if (untouched) _fill();
    });
  }

  Future<void> _send(
      Future<bool> Function(String? phone, String text) open) async {
    final l10n = AppLocalizations.of(context);
    final text = _outgoing;
    if (text.isEmpty) return;
    final ok = await open(widget.client.phone, text);
    if (!mounted) return;
    if (!ok) {
      showActionUnavailable(context, l10n.clientsSendFailed);
      return;
    }
    widget.onSent?.call(text, _listing?.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final listing = _listing;
    final canSend = _hasPhone && !_busy && _text.text.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        AppGhostButton(
          key: const Key('compose-use-template'),
          label: _template?.title ?? l10n.clientsComposeUseTemplate,
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: _busy ? null : _pickTemplate,
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.clientsComposeListing,
          child: PickerField(
            key: const Key('compose-listing'),
            value: listing?.title,
            placeholder: l10n.clientsComposeListingNone,
            onTap: _busy ? () {} : _pickListing,
          ),
        ),
        const SizedBox(height: 6),
        if (listing == null)
          Text(
            l10n.clientsComposeListingHint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 11.5, color: t.textHint),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const Key('compose-clear-listing'),
              onPressed: () => _choose(null, null),
              child: Text(
                l10n.clientsComposeClearListing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: t.textSecondary),
              ),
            ),
          ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.clientsComposeText,
          child: AppTextField(
            key: const Key('compose-text'),
            controller: _text,
            hint: l10n.clientsComposeTextHint,
            minLines: 5,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.clientsComposeHint,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 11.5,
              height: 1.35,
              color: t.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppGhostButton(
                key: const Key('compose-whatsapp'),
                label: l10n.clientsSendWhatsApp,
                onPressed:
                    canSend ? () => _send(ContactActions.whatsApp) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppFilledButton(
                key: const Key('compose-sms'),
                label: l10n.clientsComposeSms,
                loading: _busy,
                onPressed: canSend ? () => _send(ContactActions.sms) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
