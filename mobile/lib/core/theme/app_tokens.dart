import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

// Anything styling text needs both the colour tokens and the family name.
export 'package:real_estate_crm/core/theme/app_fonts.dart';

/// Brightness-resolved colour tokens from the design handoff.
///
/// Screens read these instead of branching on `Theme.of(context).brightness`
/// themselves, so a light and a dark screen are the same widget tree.
///
/// ```dart
/// final t = context.tokens;
/// Container(color: t.surface, ...)
/// ```
class AppTokens {
  final bool isDark;

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  /// Filled-button / active-tab fill. Navy in light, gold in dark.
  final Color primary;

  /// Label on [primary]. White in light, navy in dark.
  final Color onPrimary;

  /// Brand gold. The single accent per screen (eyebrows, time chips, IDs).
  final Color accent;

  /// Label on [accent] — always navy.
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

  /// Background of the hero card. Navy in light (white text on it), a bordered
  /// surface in dark.
  Color get heroSurface => isDark ? AppColors.darkSurface : AppColors.primary;
  Color get heroText => isDark ? AppColors.darkTextPrimary : Colors.white;
  Color get heroTextMuted => AppColors.darkTextSecondary; // #8B9CC8, both themes
  Color? get heroBorder => isDark ? AppColors.darkBorder : null;

  /// Filled action *inside* the navy hero: white in light (navy sits under it
  /// already), gold in dark.
  Color get heroActionFill => isDark ? AppColors.accent : Colors.white;
  Color get heroActionLabel => AppColors.primary;

  /// 1px hairline for ghost buttons drawn on the navy hero.
  Color get heroGhostBorder =>
      isDark ? AppColors.darkBorder : Colors.white.withValues(alpha: 0.28);

  /// Destructive fill / label / border — a tinted surface, never solid red.
  Color get dangerFill => isDark
      ? AppColors.error.withValues(alpha: 0.12)
      : const Color(0xFFFEF2F2);
  Color get dangerBorder => isDark
      ? AppColors.error.withValues(alpha: 0.32)
      : const Color(0xFFFEE2E2);
  Color get dangerText =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  /// The one place a solid red is allowed: the confirm button of a delete
  /// dialog.
  Color get dangerSolid =>
      isDark ? AppColors.error : const Color(0xFFDC2626);

  /// Scrim behind bottom sheets (.42) and dialogs (.5).
  Color get sheetScrim => AppColors.primary.withValues(alpha: 0.42);
  Color get dialogScrim => AppColors.primary.withValues(alpha: 0.5);

  // ── Charts ────────────────────────────────────────────────────
  // Fills for bars, rings and segments. Lightened in dark so a saturated hue
  // doesn't disappear into a #141625 background.
  Color get chartLead =>
      isDark ? const Color(0xFFA78BFA) : AppColors.lead;
  Color get chartNegotiation =>
      isDark ? const Color(0xFFFBBF24) : AppColors.negotiation;
  Color get chartWon =>
      isDark ? const Color(0xFF4ADE80) : AppColors.closedWon;
  Color get chartLost =>
      isDark ? const Color(0xFFF87171) : AppColors.closedLost;

  /// The unfilled remainder of a bar or ring.
  Color get chartTrack => surfaceVariant;

  /// A status hue safe for *small text*.
  ///
  /// The raw [AppColors] hues are tuned as fills: amber #F59E0B on the light
  /// background is about 2:1, which is unreadable at 10–11px. This returns the
  /// darkened/lightened label from the chip palette instead, which is the same
  /// hue at a contrast that actually works in both themes.
  Color statusText(StatusHue hue) => StatusPalette.resolve(this, hue).label;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => AppTokens.of(this);
}

/// The hues colour is allowed to carry. Colour signals *status* only —
/// navigation and structure stay navy/neutral.
enum StatusHue { lead, negotiation, positive, danger, neutral }

/// Foreground/background pair for a status chip.
class StatusPalette {
  final Color fill;
  final Color label;
  const StatusPalette(this.fill, this.label);

  /// Light theme uses solid pastel fills; dark keeps the hue at low alpha with
  /// a lightened label, per the handoff.
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
