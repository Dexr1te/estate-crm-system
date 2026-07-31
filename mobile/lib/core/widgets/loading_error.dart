import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_buttons.dart';
import 'package:real_estate_crm/core/widgets/empty_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(color: context.tokens.primary));
}

/// The failure state — the same shape as [EmptyState], with a red-tinted icon
/// tile and a ghost retry button. No card, no shadow.
class ErrorWidget2 extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorWidget2({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: message,
      action: onRetry == null
          ? null
          : SizedBox(
              width: 160,
              child: AppGhostButton(label: l10n.coreRetry, onPressed: onRetry),
            ),
    );
  }
}
