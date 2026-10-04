import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/handoff_row.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/handoff_sheet.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A client's partners on their card: the partner who sent them, if one did,
/// and the partners they were sent to, latest first, with a button to send
/// them to another. Reads its hand-offs on its own, so the detail screen
/// only has to place it.
class ClientPartnersCard extends StatefulWidget {
  final ClientResponse client;

  const ClientPartnersCard({super.key, required this.client});

  @override
  State<ClientPartnersCard> createState() => _ClientPartnersCardState();
}

class _ClientPartnersCardState extends State<ClientPartnersCard> {
  List<PartnerHandoff>? _handoffs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<PartnerHandoff> found;
    try {
      found =
          await Injector.partnersRepository.getClientHandoffs(widget.client.id);
    } catch (_) {
      found = const [];
    }
    if (mounted) setState(() => _handoffs = found);
  }

  Future<void> _send([PartnerHandoff? existing]) async {
    await showHandoffSheet(context,
        clientId: widget.client.id, existing: existing);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final handoffs = _handoffs;
    if (handoffs == null) {
      return const ShimmerGroup(
          child: ShimmerInfoCard(rows: 2, heading: true, buttons: 1));
    }

    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final c = widget.client;
    final partnerId = c.referredByPartnerId;
    final partnerName = c.referredByPartnerName?.trim() ?? '';

    return AppCard(
      key: const ValueKey('client-partners'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EyebrowLabel(l10n.partnersClientCard),
          if (partnerId != null && partnerName.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              key: const ValueKey('client-referred-by'),
              nested: true,
              radius: AppMetrics.radiusSm,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              onTap: () => context.push('/partners/$partnerId'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.partnersReferredBy,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 11.5,
                              color: t.textSecondary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          partnerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: t.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: t.textHint),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.partnersSentTo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: t.textSecondary),
          ),
          if (handoffs.isEmpty) ...[
            const SizedBox(height: 6),
            Text(
              l10n.partnersClientNotSent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 12.5,
                  height: 1.4,
                  color: t.textSecondary),
            ),
          ] else
            for (final h in handoffs) ...[
              const SizedBox(height: 8),
              HandoffRow(handoff: h, onTap: () => _send(h)),
            ],
          const SizedBox(height: 12),
          AppGhostButton(
            key: const ValueKey('client-send-to-partner'),
            label: l10n.partnersSendToPartner,
            icon: Icons.handshake_outlined,
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}
