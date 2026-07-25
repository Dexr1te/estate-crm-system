import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_crm/core/models/admin_models.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Shows the result of an invite: the one-time invite token for [user], with a
/// copy button and instructions for the admin to pass it on. Because there is
/// no email delivery, this dialog IS the delivery mechanism.
Future<void> showInviteResultDialog(BuildContext context, AgentResponse user) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _InviteResultDialog(user: user),
  );
}

class _InviteResultDialog extends StatelessWidget {
  const _InviteResultDialog({required this.user});
  final AgentResponse user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final token = user.inviteToken;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.mark_email_read_outlined, color: cs.primary),
          const SizedBox(width: 10),
          Text(l10n.adminInviteCreated),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminInvitedAs(
              user.fullName, user.email, user.role.name)),
          const SizedBox(height: 16),
          if (token == null || token.isEmpty)
            Text(
              l10n.adminNoInviteToken,
              style: tt.bodySmall?.copyWith(color: cs.error),
            )
          else ...[
            Text(l10n.adminShareInviteCode, style: tt.bodySmall),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: SelectableText(
                token,
                style: tt.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.adminInviteInstructions,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
      actions: [
        if (token != null && token.isNotEmpty)
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l10n.adminCopyCode),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: token));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.adminInviteCodeCopied)),
                );
                Navigator.of(context).pop();
              }
            },
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.adminDone),
        ),
      ],
    );
  }
}
