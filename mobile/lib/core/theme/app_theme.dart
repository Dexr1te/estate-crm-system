import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';

export 'package:real_estate_crm/core/theme/app_fonts.dart';
export 'package:real_estate_crm/core/theme/app_type.dart';

class AppColors {
  static const primary = Color(0xFF0F1E3C);
  static const primaryLight = Color(0xFF1A3260);
  static const accent = Color(0xFFE5B84C);
  static const accentLight = Color(0xFFFFD54F);

  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEFEFF4);
  static const border = Color(0xFFE6E6EB);

  static const textPrimary = Color(0xFF111318);
  static const textSecondary = Color(0xFF6E717C);
  static const textHint = Color(0xFF878B96);

  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkSurfaceVariant = Color(0xFF2C2C2E);
  static const darkBorder = Color(0xFF2F2F33);

  static const materialDarkBackground = Color(0xFF121212);
  static const materialDarkSurface = Color(0xFF1E1E1E);
  static const materialDarkSurfaceVariant = Color(0xFF2A2A2A);
  static const materialDarkBorder = Color(0xFF333333);

  static const darkTextPrimary = Color(0xFFF5F5F7);
  static const darkTextSecondary = Color(0xFF9A9AA1);
  static const darkTextHint = Color(0xFF76767E);

  static const darkPrimary = Color(0xFFD9B45E);
  static const onDarkPrimary = Color(0xFF0F1E3C);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF8B9CC8);

  static const lead = Color(0xFF8B5CF6);
  static const negotiation = Color(0xFFF59E0B);
  static const closedWon = Color(0xFF22C55E);
  static const closedLost = Color(0xFFEF4444);

  static const available = Color(0xFF22C55E);
  static const reserved = Color(0xFFF59E0B);
  static const sold = Color(0xFF8B5CF6);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.sans,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: AppColors.primary,
        surface: AppColors.surface,
        // ignore: deprecated_member_use
        background: AppColors.background,
        error: AppColors.error,
        // ignore: deprecated_member_use
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        displayMedium:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        displaySmall:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        headlineLarge:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        headlineMedium:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        headlineSmall:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600),
        titleSmall: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
        bodyLarge: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
        bodyMedium: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
        bodySmall: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.footnote),
        labelLarge: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600,
            fontSize: AppType.body),
        labelMedium: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.footnote),
        labelSmall: TextStyle(
            color: AppColors.textHint,
            fontFamily: AppFonts.sans,
            fontSize: AppType.caption),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide: const BorderSide(color: AppColors.error)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: AppType.body,
            fontFamily: AppFonts.sans),
        labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppType.body,
            fontFamily: AppFonts.sans),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontFamily: AppFonts.sans,
              fontWeight: FontWeight.w600,
              fontSize: AppType.body),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                  fontFamily: AppFonts.sans, fontWeight: FontWeight.w600))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontFamily: AppFonts.sans, fontWeight: FontWeight.w600))),
      chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none),
      dividerTheme:
          const DividerThemeData(color: AppColors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
      ),
      listTileTheme: const ListTileThemeData(
          titleTextStyle: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.textPrimary,
              fontSize: AppType.body,
              fontWeight: FontWeight.w500),
          subtitleTextStyle: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.textSecondary,
              fontSize: AppType.footnote)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        selectedLabelStyle: TextStyle(
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600,
            fontSize: AppType.caption),
        unselectedLabelStyle:
            TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.caption),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary.withAlpha(102)
                : AppColors.border),
      ),
    );
  }
}

class AppThemeDark {
  static ThemeData get dark => forPlatform(defaultTargetPlatform);

  static ThemeData forPlatform(TargetPlatform platform) {
    final t = AppTokens.darkFor(platform);
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.sans,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.onDarkPrimary,
        secondary: AppColors.darkPrimary,
        onSecondary: AppColors.onDarkPrimary,
        surface: t.surface,
        // ignore: deprecated_member_use
        background: t.background,
        error: AppColors.error,
        // ignore: deprecated_member_use
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        displayMedium: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        displaySmall: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        headlineLarge: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        headlineMedium: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        headlineSmall: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        titleLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600),
        titleSmall: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
        bodyLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
        bodyMedium: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
        bodySmall: TextStyle(
            color: AppColors.darkTextSecondary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.footnote),
        labelLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600,
            fontSize: AppType.body),
        labelMedium: TextStyle(
            color: AppColors.darkTextSecondary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.footnote),
        labelSmall: TextStyle(
            color: AppColors.darkTextHint,
            fontFamily: AppFonts.sans,
            fontSize: AppType.caption),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.border, width: 1)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide:
                const BorderSide(color: AppColors.darkPrimary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            gapPadding: 0,
            borderSide: const BorderSide(color: AppColors.error)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
            color: AppColors.darkTextHint,
            fontSize: AppType.body,
            fontFamily: AppFonts.sans),
        labelStyle: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: AppType.body,
            fontFamily: AppFonts.sans),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.onDarkPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontFamily: AppFonts.sans,
              fontWeight: FontWeight.w600,
              fontSize: AppType.body),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: AppColors.darkPrimary,
              textStyle: const TextStyle(
                  fontFamily: AppFonts.sans, fontWeight: FontWeight.w600))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkTextPrimary,
              side: BorderSide(color: t.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontFamily: AppFonts.sans, fontWeight: FontWeight.w600))),
      chipTheme: ChipThemeData(
        backgroundColor: t.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        labelStyle: const TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
      ),
      dividerTheme: DividerThemeData(color: t.border, thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        modalBackgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.darkTextPrimary,
            fontSize: AppType.body,
            fontWeight: FontWeight.w500),
        subtitleTextStyle: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.darkTextSecondary,
            fontSize: AppType.footnote),
        iconColor: AppColors.darkTextSecondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: t.surface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextHint,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600,
            fontSize: AppType.caption),
        unselectedLabelStyle: const TextStyle(
            fontFamily: AppFonts.sans, fontSize: AppType.caption),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.onDarkPrimary,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.darkPrimary),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.darkPrimary,
        unselectedLabelColor: AppColors.darkTextHint,
        indicatorColor: AppColors.darkPrimary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.surface,
        textStyle: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.darkPrimary
                : AppColors.darkTextHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.darkPrimary.withAlpha(102)
                : t.border),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontSize: AppType.body),
      ),
    );
  }
}
