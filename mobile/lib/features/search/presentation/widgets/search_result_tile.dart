import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class SearchResultTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String meta;
  final String? trailing;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.leading,
    required this.title,
    required this.meta,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
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
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 11.5,
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                trailing!,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: t.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ClientResultTile extends StatelessWidget {
  final ClientResponse client;
  final VoidCallback onTap;

  const ClientResultTile({
    super.key,
    required this.client,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SearchResultTile(
      leading: InitialAvatar(name: client.fullName, size: 40),
      title: client.fullName,
      meta: [
        clientTypeLabel(l10n, client.type),
        if (client.phone != null && client.phone!.isNotEmpty) client.phone!,
        if (client.email != null && client.email!.isNotEmpty) client.email!,
      ].join(' · '),
      onTap: onTap,
    );
  }
}

class PropertyResultTile extends StatelessWidget {
  final PropertyResponse property;
  final VoidCallback onTap;

  const PropertyResultTile({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final live = property.status != PropertyStatus.SOLD;

    return SearchResultTile(
      leading: _MarkBox(
        icon: propertyTypeIcon(property.type),
        color: live ? t.accent : t.textHint,
      ),
      title: property.title.isEmpty ? property.address : property.title,
      meta: [
        propertyStatusLabel(l10n, property.status),
        if (property.address.isNotEmpty) property.address,
      ].join(' · '),
      trailing: formatPrice(property.price),
      onTap: onTap,
    );
  }
}

class DealResultTile extends StatelessWidget {
  final DealResponse deal;
  final VoidCallback onTap;

  const DealResultTile({super.key, required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return SearchResultTile(
      leading: _MarkBox(
        icon: Icons.handshake_outlined,
        color: dealStageColor(t, deal.status),
      ),
      title: deal.title,
      meta: [
        dealStatusLabel(l10n, deal.status),
        if (deal.clientName.isNotEmpty) deal.clientName,
      ].join(' · '),
      trailing: formatPrice(deal.dealPrice ?? deal.budget ?? 0),
      onTap: onTap,
    );
  }
}

class _MarkBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MarkBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border, width: AppMetrics.borderWidth),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
