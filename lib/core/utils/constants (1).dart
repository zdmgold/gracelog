import 'package:flutter/material.dart';

/// Semantic design tokens for GraceLog.
/// No raw hex values appear outside this file.

// ============================================================================
// COLOR TOKENS
// ============================================================================

class AppColors {
  const AppColors._();

  // Primary
  static const Color primaryLight = Color(0xFF7C5C2E);
  static const Color primaryDark = Color(0xFFD4A76A);

  // Secondary
  static const Color secondaryLight = Color(0xFF5A7C5C);
  static const Color secondaryDark = Color(0xFF8FBC8F);

  // Background
  static const Color bgPrimaryLight = Color(0xFFFDFCF8);
  static const Color bgPrimaryDark = Color(0xFF121212);
  static const Color bgSecondaryLight = Color(0xFFF5F2EB);
  static const Color bgSecondaryDark = Color(0xFF1E1E1E);
  static const Color bgTertiaryLight = Color(0xFFEBE7DE);
  static const Color bgTertiaryDark = Color(0xFF2C2C2C);

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textPrimaryDark = Color(0xFFEAEAEA);
  static const Color textSecondaryLight = Color(0xFF5C5C5C);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryLight = Color(0xFF8A8A8A);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color textInverseLight = Color(0xFFFFFFFF);
  static const Color textInverseDark = Color(0xFF1A1A1A);

  // Accent
  static const Color accentGold = Color(0xFFD4A76A);
  static const Color accentSage = Color(0xFF8FBC8F);
  static const Color accentRose = Color(0xFFD48A8A);
  static const Color accentSky = Color(0xFF8AAED4);

  // Mood colors
  static const Color moodPeaceful = Color(0xFF7EB5A6);
  static const Color moodThankful = Color(0xFFD4A76A);
  static const Color moodJoyful = Color(0xFFE8C547);
  static const Color moodHopeful = Color(0xFF8AAED4);
  static const Color moodAnxious = Color(0xFFB8A9C9);
  static const Color moodWorried = Color(0xFFD48A8A);
  static const Color moodTired = Color(0xFF8A9AA8);

  // Border
  static const Color borderLight = Color(0xFFE0DCD3);
  static const Color borderDark = Color(0xFF3A3A3A);

  // Error / Success / Warning
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  // Bedtime mode (OLED)
  static const Color bedtimeBackground = Color(0xFF000000);
  static const Color bedtimeText = Color(0xFFE0E0E0);

  // AdMob banner background (seamless)
  static const Color adBannerBackground = Color(0xFFF5F2EB);
  static const Color adBannerBackgroundDark = Color(0xFF1E1E1E);
}

// ============================================================================
// TYPOGRAPHY TOKENS
// ============================================================================

class AppTypography {
  const AppTypography._();

  static const String fontFamily = '.SF Pro Text'; // iOS system font
  static const String fontFamilyFallback = 'Roboto'; // Android system font

  // Display
  static const double displaySize = 34.0;
  static const FontWeight displayWeight = FontWeight.w700;
  static const double displayLineHeight = 1.2;

  // Headline
  static const double headlineSize = 28.0;
  static const FontWeight headlineWeight = FontWeight.w700;
  static const double headlineLineHeight = 1.25;

  // Title Large
  static const double titleLargeSize = 22.0;
  static const FontWeight titleLargeWeight = FontWeight.w600;
  static const double titleLargeLineHeight = 1.27;

  // Title Medium
  static const double titleMediumSize = 18.0;
  static const FontWeight titleMediumWeight = FontWeight.w600;
  static const double titleMediumLineHeight = 1.33;

  // Body Large
  static const double bodyLargeSize = 16.0;
  static const FontWeight bodyLargeWeight = FontWeight.w400;
  static const double bodyLargeLineHeight = 1.5;

  // Body Medium
  static const double bodyMediumSize = 14.0;
  static const FontWeight bodyMediumWeight = FontWeight.w400;
  static const double bodyMediumLineHeight = 1.43;

  // Label Large
  static const double labelLargeSize = 14.0;
  static const FontWeight labelLargeWeight = FontWeight.w600;
  static const double labelLargeLineHeight = 1.43;

  // Caption
  static const double captionSize = 12.0;
  static const FontWeight captionWeight = FontWeight.w400;
  static const double captionLineHeight = 1.33;
}

// ============================================================================
// SPACING TOKENS (4px base grid)
// ============================================================================

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

// ============================================================================
// SHAPE TOKENS
// ============================================================================

class AppShape {
  const AppShape._();

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;
}

// ============================================================================
// ANIMATION TOKENS
// ============================================================================

class AppAnimation {
  const AppAnimation._();

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationSlower = Duration(milliseconds: 500);

  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveSpring = Curves.fastOutSlowIn;
  static const Curve curveDecelerate = Curves.decelerate;
}

// ============================================================================
// ACCESSIBILITY CONSTANTS
// ============================================================================

class AppAccessibility {
  const AppAccessibility._();

  /// Minimum touch target size (48dp per Material/iOS guidelines)
  static const double minTouchTarget = 48.0;

  /// Minimum contrast ratio (WCAG AA)
  static const double minContrastRatio = 4.5;

  /// Maximum text scale factor
  static const double maxTextScale = 3.1;

  /// Reduce motion threshold
  static const Duration reduceMotionDuration = Duration(milliseconds: 0);
}

// ============================================================================
// APP CONSTANTS
// ============================================================================

class AppConstants {
  const AppConstants._();

  static const String appName = 'GraceLog';
  static const String bundleId = 'com.gracelog.app';

  // IAP
  static const String iapProductId = 'com.gracelog.app.pro.monthly';

  // AdMob (Google test IDs — replace before store submission)
  static const String admobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String admobAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String admobBannerUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String admobBannerUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';

  // Database
  static const String dbName = 'gracelog.db';
  static const int dbVersion = 1;

  // Export
  static const int exportImageSize = 1080; // Instagram square

  // Streak milestones
  static const List<int> streakMilestones = [7, 30, 100, 365];

  // Supported locales (11 languages)
  static const List<String> supportedLocales = [
    'en', // English
    'es', // Spanish
    'fr', // French
    'de', // German
    'pt', // Portuguese
    'ar', // Arabic (RTL)
    'hi', // Hindi
    'ja', // Japanese
    'ko', // Korean
    'zh', // Chinese
    'he', // Hebrew (RTL)
  ];

  // RTL locales
  static const List<String> rtlLocales = ['ar', 'he'];
}
