import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_buttons.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String? confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.delete_outline_rounded,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: AppTokens.of(context).dialogScrim,
    builder: (ctx) {
      final t = ctx.tokens;
      final l10n = AppLocalizations.of(ctx);

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: t.dangerFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: t.dangerBorder, width: AppMetrics.borderWidth),
                ),
                child: Icon(icon, size: 22, color: t.dangerText),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: t.textPrimary),
              ),
              const SizedBox(height: 9),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 12.5,
                    height: 1.6,
                    color: t.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppGhostButton(
                      label: cancelLabel ?? l10n.coreCancel,
                      height: 48,
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: AppFilledButton(
                      label: confirmLabel ?? l10n.coreDelete,
                      height: 48,
                      fontSize: 13.5,
                      fill: t.dangerSolid,
                      labelColor: Colors.white,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
