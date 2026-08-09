import 'package:flutter/material.dart';

import 'constants.dart';

/// GraceLog theme configuration.
///
/// Builds light and dark [ThemeData] instances using semantic tokens.
/// All widgets must consume colors via [Theme.of(context)], not
/// raw [AppColors] references, to ensure proper dark-mode support.
class AppTheme {
  AppTheme._();

  static ThemeData buildLightTheme() {
    return _buildTheme(
      brightness: Brightness.light,
      bgPrimary: AppColors.bgPrimaryLight,
      bgSecondary: AppColors.bgSecondaryLight,
      surface: AppColors.surfaceLight,
      surfaceElevated: AppColors.surfaceElevatedLight,
      textPrimary: AppColors.textPrimaryLight,
      textSecondary: AppColors.textSecondaryLight,
      textTertiary: AppColors.textTertiaryLight,
      textInverse: AppColors.textInverseLight,
      border: AppColors.borderLight,
      borderFocused: AppColors.borderFocusedLight,
      divider: AppColors.dividerLight,
    );
  }

  static ThemeData buildDarkTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      bgPrimary: AppColors.bgPrimaryDark,
      bgSecondary: AppColors.bgSecondaryDark,
      surface: AppColors.surfaceDark,
      surfaceElevated: AppColors.surfaceElevatedDark,
      textPrimary: AppColors.textPrimaryDark,
      textSecondary: AppColors.textSecondaryDark,
      textTertiary: AppColors.textTertiaryDark,
      textInverse: AppColors.textInverseDark,
      border: AppColors.borderDark,
      borderFocused: AppColors.borderFocusedDark,
      divider: AppColors.dividerDark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bgPrimary,
    required Color bgSecondary,
    required Color surface,
    required Color surfaceElevated,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color textInverse,
    required Color border,
    required Color borderFocused,
    required Color divider,
  }) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.accentGold : AppColors.accentGold;
    final primaryColorDark = isDark ? AppColors.accentGold : AppColors.accentGold;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        onPrimary: textInverse,
        secondary: AppColors.accentSage,
        onSecondary: textInverse,
        surface: surface,
        onSurface: textPrimary,
        error: AppColors.textError,
        onError: textInverse,
        outline: border,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surface,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textError),
        ),
        hintStyle: TextStyle(color: textTertiary, fontSize: 15),
        labelStyle: TextStyle(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textInverse,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: textSecondary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primaryColor.withOpacity(0.12),
        labelStyle: TextStyle(color: textPrimary, fontSize: 14),
        secondaryLabelStyle: TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        minLeadingWidth: 48,
        minVerticalPadding: 16,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: TextStyle(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textTertiary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Extension on [ThemeData] for quick access to GraceLog design tokens.
extension AppThemeData on ThemeData {
  /// Returns the appropriate shadow list based on brightness.
  List<BoxShadow> get shadowLight => AppColors.shadowLight;
  List<BoxShadow> get shadowMedium => AppColors.shadowMedium;
  List<BoxShadow> get shadowHeavy => AppColors.shadowHeavy;

  /// Returns the appropriate glassmorphism overlay color.
  Color get glassColor => brightness == Brightness.dark
      ? AppColors.glassDark
      : AppColors.glassWhite;

  /// Animation helpers.
  Duration get durationFast => AppConstants.durationFast;
  Duration get durationNormal => AppConstants.durationNormal;
  Duration get durationSlow => AppConstants.durationSlow;
  Curve get easeOutExpo => AppConstants.easeOutExpo;
  Curve get easeInOutCubic => AppConstants.easeInOutCubic;
}
