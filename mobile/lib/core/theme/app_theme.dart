import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_fonts.dart';

export 'package:real_estate_crm/core/theme/app_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0F1E3C);
  static const primaryLight = Color(0xFF1A3260);
  static const accent = Color(0xFFE5B84C);
  static const accentLight = Color(0xFFFFD54F);

  static const background = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF1F8);
  static const border = Color(0xFFE8ECF4);

  static const textPrimary = Color(0xFF0F1E3C);
  static const textSecondary = Color(0xFF6B7A99);
  static const textHint = Color(0xFFADB5CC);

  static const darkBackground = Color(0xFF141625);
  static const darkSurface = Color(0xFF1E2130);
  static const darkSurfaceVariant = Color(0xFF252A3D);
  static const darkBorder = Color(0xFF2A2F45);

  static const darkTextPrimary = Color(0xFFF0F2FF);
  static const darkTextSecondary = Color(0xFF8B9CC8);
  static const darkTextHint = Color(0xFF4A5070);

  static const darkPrimary = accent;
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
      scaffoldBackgroundColor: AppColors.background,
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
        titleSmall:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        bodyLarge:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        bodyMedium:
            TextStyle(color: AppColors.textPrimary, fontFamily: AppFonts.sans),
        bodySmall: TextStyle(
            color: AppColors.textSecondary, fontFamily: AppFonts.sans),
        labelLarge: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600),
        labelMedium: TextStyle(
            color: AppColors.textSecondary, fontFamily: AppFonts.sans),
        labelSmall:
            TextStyle(color: AppColors.textHint, fontFamily: AppFonts.sans),
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
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
            color: AppColors.textHint, fontSize: 14, fontFamily: AppFonts.sans),
        labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
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
              fontSize: 15),
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
            fontSize: 14),
      ),
      listTileTheme: const ListTileThemeData(
          titleTextStyle: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500),
          subtitleTextStyle: TextStyle(
              fontFamily: AppFonts.sans,
              color: AppColors.textSecondary,
              fontSize: 12)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        selectedLabelStyle: TextStyle(
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600,
            fontSize: 11),
        unselectedLabelStyle:
            TextStyle(fontFamily: AppFonts.sans, fontSize: 11),
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
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.sans,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.onDarkPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.onDarkPrimary,
        surface: AppColors.darkSurface,
        // ignore: deprecated_member_use
        background: AppColors.darkBackground,
        error: AppColors.error,
        // ignore: deprecated_member_use
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
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
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        bodyLarge: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        bodyMedium: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
        bodySmall: TextStyle(
            color: AppColors.darkTextSecondary, fontFamily: AppFonts.sans),
        labelLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600),
        labelMedium: TextStyle(
            color: AppColors.darkTextSecondary, fontFamily: AppFonts.sans),
        labelSmall:
            TextStyle(color: AppColors.darkTextHint, fontFamily: AppFonts.sans),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder, width: 1)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.darkPrimary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
            color: AppColors.darkTextHint,
            fontSize: 14,
            fontFamily: AppFonts.sans),
        labelStyle: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 14,
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
              fontSize: 15),
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
              side: const BorderSide(color: AppColors.darkBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontFamily: AppFonts.sans, fontWeight: FontWeight.w600))),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        labelStyle: const TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.darkTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        subtitleTextStyle: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.darkTextSecondary,
            fontSize: 12),
        iconColor: AppColors.darkTextSecondary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextHint,
        elevation: 0,
        selectedLabelStyle: TextStyle(
            fontFamily: AppFonts.sans,
            fontWeight: FontWeight.w600,
            fontSize: 11),
        unselectedLabelStyle:
            TextStyle(fontFamily: AppFonts.sans, fontSize: 11),
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
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.darkSurface,
        textStyle: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: AppFonts.sans,
            fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
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
            fontSize: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.darkPrimary
                : AppColors.darkTextHint),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.darkPrimary.withAlpha(102)
                : AppColors.darkBorder),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: AppFonts.sans),
      ),
    );
  }
}
