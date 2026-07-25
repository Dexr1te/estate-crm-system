import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// List-item card for a single client, showing avatar, name/email and a
/// deal-count badge. Navigation and delete are delegated via callbacks.
class ClientCard extends StatelessWidget {
  final ClientListItem client;
  final int dealCount;
  final VoidCallback onTap, onEdit, onDelete;

  /// Whether to show the delete action (client delete is admin-only server-side).
  final bool canDelete;

  const ClientCard({
    super.key,
    required this.client,
    required this.dealCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: avatar + name/email + menu ──
              Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.primary.withAlpha(26),
                  child: Text(
                    client.fullName.isNotEmpty
                        ? client.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sora'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.fullName,
                          style: tt.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      if (client.email != null)
                        Text(client.email!, style: tt.bodySmall),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          const Icon(Icons.edit_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(l10n.clientsEdit)
                        ])),
                    if (canDelete)
                      PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            const Icon(Icons.delete_outline,
                                size: 16, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(l10n.clientsDelete,
                                style: const TextStyle(color: AppColors.error))
                          ])),
                  ],
                  child: Icon(Icons.more_vert,
                      color: tt.bodySmall?.color, size: 20),
                ),
              ]),

              // ── Deal count badge ──
              if (dealCount > 0) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.handshake_outlined, size: 14, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.clientsDealCount(dealCount),
                    style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
