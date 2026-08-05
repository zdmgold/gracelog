import 'package:flutter/material.dart';

import 'constants.dart';

/// Material 3 theme factory using only semantic tokens.
/// No raw hex values appear in this file — all colors route through [AppColors].
class AppTheme {
  const AppTheme._();

  // ==========================================================================
  // LIGHT THEME
  // ==========================================================================

  static ThemeData buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.textInverseLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.textInverseLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.bgTertiaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.borderLight,
      error: AppColors.error,
      onError: AppColors.textInverseLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgPrimaryLight,
      canvasColor: AppColors.bgSecondaryLight,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: const [AppTypography.fontFamilyFallback],

      // TextTheme — all sizes use AppTypography tokens
      textTheme: TextTheme(
        displayLarge: _textStyle(
          size: AppTypography.displaySize,
          weight: AppTypography.displayWeight,
          height: AppTypography.displayLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        headlineLarge: _textStyle(
          size: AppTypography.headlineSize,
          weight: AppTypography.headlineWeight,
          height: AppTypography.headlineLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        titleLarge: _textStyle(
          size: AppTypography.titleLargeSize,
          weight: AppTypography.titleLargeWeight,
          height: AppTypography.titleLargeLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: _textStyle(
          size: AppTypography.titleMediumSize,
          weight: AppTypography.titleMediumWeight,
          height: AppTypography.titleMediumLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: _textStyle(
          size: AppTypography.bodyLargeSize,
          weight: AppTypography.bodyLargeWeight,
          height: AppTypography.bodyLargeLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        labelLarge: _textStyle(
          size: AppTypography.labelLargeSize,
          weight: AppTypography.labelLargeWeight,
          height: AppTypography.labelLargeLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: _textStyle(
          size: AppTypography.captionSize,
          weight: AppTypography.captionWeight,
          height: AppTypography.captionLineHeight,
          color: AppColors.textSecondaryLight,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.bgPrimaryLight,
        foregroundColor: AppColors.textPrimaryLight,
        titleTextStyle: _textStyle(
          size: AppTypography.titleLargeSize,
          weight: AppTypography.titleLargeWeight,
          height: AppTypography.titleLargeLineHeight,
          color: AppColors.textPrimaryLight,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgTertiaryLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        hintStyle: _textStyle(
          size: AppTypography.bodyLargeSize,
          weight: AppTypography.bodyLargeWeight,
          height: AppTypography.bodyLargeLineHeight,
          color: AppColors.textTertiaryLight,
        ),
        labelStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textSecondaryLight,
        ),
        errorStyle: _textStyle(
          size: AppTypography.captionSize,
          weight: AppTypography.captionWeight,
          height: AppTypography.captionLineHeight,
          color: AppColors.error,
        ),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppShape.radiusXl),
            topRight: Radius.circular(AppShape.radiusXl),
          ),
        ),
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusXl),
        ),
        elevation: 0,
        titleTextStyle: _textStyle(
          size: AppTypography.titleLargeSize,
          weight: AppTypography.titleLargeWeight,
          height: AppTypography.titleLargeLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        contentTextStyle: _textStyle(
          size: AppTypography.bodyLargeSize,
          weight: AppTypography.bodyLargeWeight,
          height: AppTypography.bodyLargeLineHeight,
          color: AppColors.textPrimaryLight,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.textInverseLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(
            AppAccessibility.minTouchTarget,
            AppAccessibility.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.radiusLg),
          ),
          textStyle: _textStyle(
            size: AppTypography.labelLargeSize,
            weight: AppTypography.labelLargeWeight,
            height: AppTypography.labelLargeLineHeight,
            color: AppColors.textInverseLight,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(
            AppAccessibility.minTouchTarget,
            AppAccessibility.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: _textStyle(
            size: AppTypography.labelLargeSize,
            weight: AppTypography.labelLargeWeight,
            height: AppTypography.labelLargeLineHeight,
            color: AppColors.primaryLight,
          ),
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.md,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
        ),
        tileColor: AppColors.surfaceLight,
        selectedTileColor: AppColors.bgTertiaryLight,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgTertiaryLight,
        selectedColor: AppColors.primaryLight,
        labelStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textPrimaryLight,
        ),
        secondaryLabelStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textInverseLight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusFull),
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textInverseLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.bgTertiaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight.withValues(alpha: 0.5);
          }
          return AppColors.borderLight;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.borderLight,
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
    );
  }

  // ==========================================================================
  // DARK THEME
  // ==========================================================================

  static ThemeData buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.textInverseDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.textInverseDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.bgTertiaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDark,
      error: AppColors.error,
      onError: AppColors.textInverseDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgPrimaryDark,
      canvasColor: AppColors.bgSecondaryDark,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: const [AppTypography.fontFamilyFallback],

      textTheme: TextTheme(
        displayLarge: _textStyle(
          size: AppTypography.displaySize,
          weight: AppTypography.displayWeight,
          height: AppTypography.displayLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: _textStyle(
          size: AppTypography.headlineSize,
          weight: AppTypography.headlineWeight,
          height: AppTypography.headlineLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: _textStyle(
          size: AppTypography.titleLargeSize,
          weight: AppTypography.titleLargeWeight,
          height: AppTypography.titleLargeLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: _textStyle(
          size: AppTypography.titleMediumSize,
          weight: AppTypography.titleMediumWeight,
          height: AppTypography.titleMediumLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: _textStyle(
          size: AppTypography.bodyLargeSize,
          weight: AppTypography.bodyLargeWeight,
          height: AppTypography.bodyLargeLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        labelLarge: _textStyle(
          size: AppTypography.labelLargeSize,
          weight: AppTypography.labelLargeWeight,
          height: AppTypography.labelLargeLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: _textStyle(
          size: AppTypography.captionSize,
          weight: AppTypography.captionWeight,
          height: AppTypography.captionLineHeight,
          color: AppColors.textSecondaryDark,
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.bgPrimaryDark,
        foregroundColor: AppColors.textPrimaryDark,
        titleTextStyle: _textStyle(
          size: AppTypography.titleLargeSize,
          weight: AppTypography.titleLargeWeight,
          height: AppTypography.titleLargeLineHeight,
          color: AppColors.textPrimaryDark,
        ),
      ),

      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgTertiaryDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: const BorderSide(
            color: AppColors.primaryDark,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        hintStyle: _textStyle(
          size: AppTypography.bodyLargeSize,
          weight: AppTypography.bodyLargeWeight,
          height: AppTypography.bodyLargeLineHeight,
          color: AppColors.textTertiaryDark,
        ),
        labelStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textSecondaryDark,
        ),
        errorStyle: _textStyle(
          size: AppTypography.captionSize,
          weight: AppTypography.captionWeight,
          height: AppTypography.captionLineHeight,
          color: AppColors.error,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppShape.radiusXl),
            topRight: Radius.circular(AppShape.radiusXl),
          ),
        ),
        elevation: 0,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusXl),
        ),
        elevation: 0,
        titleTextStyle: _textStyle(
          size: AppTypography.titleLargeSize,
          weight: AppTypography.titleLargeWeight,
          height: AppTypography.titleLargeLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: _textStyle(
          size: AppTypography.bodyLargeSize,
          weight: AppTypography.bodyLargeWeight,
          height: AppTypography.bodyLargeLineHeight,
          color: AppColors.textPrimaryDark,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textInverseDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(
            AppAccessibility.minTouchTarget,
            AppAccessibility.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShape.radiusLg),
          ),
          textStyle: _textStyle(
            size: AppTypography.labelLargeSize,
            weight: AppTypography.labelLargeWeight,
            height: AppTypography.labelLargeLineHeight,
            color: AppColors.textInverseDark,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(
            AppAccessibility.minTouchTarget,
            AppAccessibility.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: _textStyle(
            size: AppTypography.labelLargeSize,
            weight: AppTypography.labelLargeWeight,
            height: AppTypography.labelLargeLineHeight,
            color: AppColors.primaryDark,
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.md,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
        ),
        tileColor: AppColors.surfaceDark,
        selectedTileColor: AppColors.bgTertiaryDark,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgTertiaryDark,
        selectedColor: AppColors.primaryDark,
        labelStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        secondaryLabelStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textInverseDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusFull),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: _textStyle(
          size: AppTypography.bodyMediumSize,
          weight: AppTypography.bodyMediumWeight,
          height: AppTypography.bodyMediumLineHeight,
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.bgTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark.withValues(alpha: 0.5);
          }
          return AppColors.borderDark;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryDark,
        inactiveTrackColor: AppColors.borderDark,
        thumbColor: AppColors.primaryDark,
        overlayColor: AppColors.primaryDark.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
    );
  }

  // ==========================================================================
  // BEDTIME MODE THEME (OLED Black)
  // ==========================================================================

  static ThemeData buildBedtimeTheme() {
    return buildDarkTheme().copyWith(
      scaffoldBackgroundColor: AppColors.bedtimeBackground,
      canvasColor: AppColors.bedtimeBackground,
      colorScheme: buildDarkTheme().colorScheme.copyWith(
        surface: AppColors.bedtimeBackground,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.bedtimeBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShape.radiusLg),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: buildDarkTheme().textTheme.apply(
        bodyColor: AppColors.bedtimeText,
        displayColor: AppColors.bedtimeText,
      ),
    );
  }

  // ==========================================================================
  // HELPER
  // ==========================================================================

  static TextStyle _textStyle({
    required double size,
    required FontWeight weight,
    required double height,
    required Color color,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: 0,
    );
  }
}
