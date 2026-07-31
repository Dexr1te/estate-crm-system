import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

export 'package:real_estate_crm/core/theme/app_fonts.dart';

class AppTokens {
  final bool isDark;

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  final Color primary;

  final Color onPrimary;

  final Color accent;

  final Color onAccent;

  const AppTokens._({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
  });

  static const light = AppTokens._(
    isDark: false,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    border: AppColors.border,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textHint: AppColors.textHint,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    accent: AppColors.accent,
    onAccent: AppColors.primary,
  );

  static const dark = AppTokens._(
    isDark: true,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textHint: AppColors.darkTextHint,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.onDarkPrimary,
    accent: AppColors.accent,
    onAccent: AppColors.onDarkPrimary,
  );

  static AppTokens of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  Color get heroSurface => isDark ? AppColors.darkSurface : AppColors.primary;
  Color get heroText => isDark ? AppColors.darkTextPrimary : Colors.white;
  Color get heroTextMuted => AppColors.darkTextSecondary;
  Color? get heroBorder => isDark ? AppColors.darkBorder : null;

  Color get heroActionFill => isDark ? AppColors.accent : Colors.white;
  Color get heroActionLabel => AppColors.primary;

  Color get heroGhostBorder =>
      isDark ? AppColors.darkBorder : Colors.white.withValues(alpha: 0.28);

  Color get dangerFill => isDark
      ? AppColors.error.withValues(alpha: 0.12)
      : const Color(0xFFFEF2F2);
  Color get dangerBorder => isDark
      ? AppColors.error.withValues(alpha: 0.32)
      : const Color(0xFFFEE2E2);
  Color get dangerText =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  Color get dangerSolid => isDark ? AppColors.error : const Color(0xFFDC2626);

  Color get sheetScrim => AppColors.primary.withValues(alpha: 0.42);
  Color get dialogScrim => AppColors.primary.withValues(alpha: 0.5);

  Color get chartLead => isDark ? const Color(0xFFA78BFA) : AppColors.lead;
  Color get chartNegotiation =>
      isDark ? const Color(0xFFFBBF24) : AppColors.negotiation;
  Color get chartWon => isDark ? const Color(0xFF4ADE80) : AppColors.closedWon;
  Color get chartLost =>
      isDark ? const Color(0xFFF87171) : AppColors.closedLost;

  Color get chartTrack => surfaceVariant;

  Color statusText(StatusHue hue) => StatusPalette.resolve(this, hue).label;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => AppTokens.of(this);
}

enum StatusHue { lead, negotiation, positive, danger, neutral }

class StatusPalette {
  final Color fill;
  final Color label;
  const StatusPalette(this.fill, this.label);

  static StatusPalette resolve(AppTokens t, StatusHue hue) {
    switch (hue) {
      case StatusHue.lead:
        return t.isDark
            ? StatusPalette(
                AppColors.lead.withValues(alpha: 0.18), const Color(0xFFA78BFA))
            : const StatusPalette(Color(0xFFF5F0FF), Color(0xFF7C3AED));
      case StatusHue.negotiation:
        return t.isDark
            ? StatusPalette(AppColors.negotiation.withValues(alpha: 0.15),
                const Color(0xFFFBBF24))
            : const StatusPalette(Color(0xFFFFF6E6), Color(0xFFB4791A));
      case StatusHue.positive:
        return t.isDark
            ? StatusPalette(AppColors.success.withValues(alpha: 0.15),
                const Color(0xFF4ADE80))
            : const StatusPalette(Color(0xFFE7F8EE), Color(0xFF15803D));
      case StatusHue.danger:
        return t.isDark
            ? StatusPalette(AppColors.error.withValues(alpha: 0.15),
                const Color(0xFFF87171))
            : const StatusPalette(Color(0xFFFEF2F2), Color(0xFFDC2626));
      case StatusHue.neutral:
        return StatusPalette(t.surfaceVariant, t.textSecondary);
    }
  }
}
