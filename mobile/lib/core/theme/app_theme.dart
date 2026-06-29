import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const primary = Color(0xFF0F1E3C);
  static const primaryLight = Color(0xFF1A3260);
  static const accent = Color(0xFFD4A843);
  static const accentLight = Color(0xFFF5C842);

  // Light surface
  static const background = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF1F8);

  // Light text
  static const textPrimary = Color(0xFF0F1E3C);
  static const textSecondary = Color(0xFF6B7A99);
  static const textHint = Color(0xFFADB5CC);

  // Dark surface
  static const darkBackground = Color(0xFF141625);
  static const darkSurface = Color(0xFF1E2130);
  static const darkSurfaceVariant = Color(0xFF252A3D);
  static const darkBorder = Color(0xFF2A2F45);

  // Dark text
  static const darkTextPrimary = Color(0xFFF0F2FF);
  static const darkTextSecondary = Color(0xFF8B9CC8);
  static const darkTextHint = Color(0xFF4A5070);

  // Dark primary (lighter blue for contrast on dark bg)
  static const darkPrimary = Color(0xFF5B8FE8);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Deal status
  static const lead = Color(0xFF8B5CF6);
  static const negotiation = Color(0xFFF59E0B);
  static const closedWon = Color(0xFF22C55E);
  static const closedLost = Color(0xFFEF4444);

  // Property status
  static const available = Color(0xFF22C55E);
  static const reserved = Color(0xFFF59E0B);
  static const sold = Color.fromARGB(255, 93, 0, 255);
}

// ─── Light Theme ───────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Sora',
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
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
            TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        displayMedium:
            TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        displaySmall:
            TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        headlineLarge:
            TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        headlineMedium:
            TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        headlineSmall:
            TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        bodyMedium: TextStyle(color: AppColors.textPrimary, fontFamily: 'Sora'),
        bodySmall:
            TextStyle(color: AppColors.textSecondary, fontFamily: 'Sora'),
        labelLarge: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600),
        labelMedium:
            TextStyle(color: AppColors.textSecondary, fontFamily: 'Sora'),
        labelSmall: TextStyle(color: AppColors.textHint, fontFamily: 'Sora'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontFamily: 'Sora',
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
            side: const BorderSide(color: Color(0xFFE8ECF4), width: 1)),
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
            borderSide: const BorderSide(color: Color(0xFFE8ECF4))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
            color: AppColors.textHint, fontSize: 14, fontFamily: 'Sora'),
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 14, fontFamily: 'Sora'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontFamily: 'Sora', fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                  fontFamily: 'Sora', fontWeight: FontWeight.w600))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontFamily: 'Sora', fontWeight: FontWeight.w600))),
      chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none),
      dividerTheme:
          const DividerThemeData(color: Color(0xFFE8ECF4), thickness: 1),
      listTileTheme: const ListTileThemeData(
          titleTextStyle: TextStyle(
              fontFamily: 'Sora',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500),
          subtitleTextStyle: TextStyle(
              fontFamily: 'Sora',
              color: AppColors.textSecondary,
              fontSize: 12)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        selectedLabelStyle: TextStyle(
            fontFamily: 'Sora', fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontFamily: 'Sora', fontSize: 11),
      ),
    );
  }
}

// ─── Dark Theme ────────────────────────────────────────────────
class AppThemeDark {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Sora',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        // ignore: deprecated_member_use
        background: AppColors.darkBackground,
        error: AppColors.error,
        // ignore: deprecated_member_use
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      // ─ This is the key fix: all text white in dark mode ─
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        displayMedium:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        displaySmall:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        headlineLarge:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        headlineMedium:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        headlineSmall:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        titleLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600),
        titleSmall:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        bodyLarge:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        bodyMedium:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
        bodySmall:
            TextStyle(color: AppColors.darkTextSecondary, fontFamily: 'Sora'),
        labelLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600),
        labelMedium:
            TextStyle(color: AppColors.darkTextSecondary, fontFamily: 'Sora'),
        labelSmall:
            TextStyle(color: AppColors.darkTextHint, fontFamily: 'Sora'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontFamily: 'Sora',
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
            color: AppColors.darkTextHint, fontSize: 14, fontFamily: 'Sora'),
        labelStyle: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 14,
            fontFamily: 'Sora'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontFamily: 'Sora', fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: AppColors.darkPrimary,
              textStyle: const TextStyle(
                  fontFamily: 'Sora', fontWeight: FontWeight.w600))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkPrimary,
              side: const BorderSide(color: AppColors.darkPrimary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontFamily: 'Sora', fontWeight: FontWeight.w600))),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        labelStyle: const TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
            fontFamily: 'Sora',
            color: AppColors.darkTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        subtitleTextStyle: TextStyle(
            fontFamily: 'Sora',
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
            fontFamily: 'Sora', fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontFamily: 'Sora', fontSize: 11),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.darkSurface,
        textStyle: TextStyle(
            color: AppColors.darkTextPrimary, fontFamily: 'Sora', fontSize: 14),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        titleTextStyle: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'Sora',
            fontSize: 18,
            fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(
            color: AppColors.darkTextSecondary,
            fontFamily: 'Sora',
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
        contentTextStyle:
            TextStyle(color: AppColors.darkTextPrimary, fontFamily: 'Sora'),
      ),
    );
  }
}
