import 'package:flutter/material.dart';

/// GraceLog semantic color tokens.
///
/// All widgets must reference these constants. No raw hex values
/// are permitted in widget code.
///
/// This file provides both the canonical light/dark variants AND
/// backward-compatible aliases so that Phase 4–5 widgets compile
/// without modification. Aliases default to light-theme values.
class AppColors {
  AppColors._();

  // ───────────────────────────────────────────────────────────────
  // Canonical light-theme tokens
  // ───────────────────────────────────────────────────────────────
  static const Color bgPrimaryLight = Color(0xFFFDFCF8);
  static const Color bgSecondaryLight = Color(0xFFF5F2EB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF0EDE6);

  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF5C5C5C);
  static const Color textTertiaryLight = Color(0xFF8A8A8A);
  static const Color textInverseLight = Color(0xFFFFFFFF);
  static const Color textError = Color(0xFFD32F2F);

  static const Color borderLight = Color(0xFFE0DCD3);
  static const Color borderFocusedLight = Color(0xFF7C5C2E);
  static const Color dividerLight = Color(0xFFE8E5DE);

  // ───────────────────────────────────────────────────────────────
  // Canonical dark-theme tokens
  // ───────────────────────────────────────────────────────────────
  static const Color bgPrimaryDark = Color(0xFF121212);
  static const Color bgSecondaryDark = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceElevatedDark = Color(0xFF2A2A2A);

  static const Color textPrimaryDark = Color(0xFFEAEAEA);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color textInverseDark = Color(0xFF121212);

  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color borderFocusedDark = Color(0xFFD4A76A);
  static const Color dividerDark = Color(0xFF2E2E2E);

  // ───────────────────────────────────────────────────────────────
  // Accent tokens (theme-agnostic)
  // ───────────────────────────────────────────────────────────────
  static const Color accentGold = Color(0xFFD4A76A);
  static const Color accentSage = Color(0xFF8FBC8F);
  static const Color accentRose = Color(0xFFE8A0BF);
  static const Color accentSky = Color(0xFF87CEEB);
  static const Color accentCrimson = Color(0xFFDC143C);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentPlum = Color(0xFF9B59B6);

  // ───────────────────────────────────────────────────────────────
  // Mood-specific tokens (theme-agnostic)
  // ───────────────────────────────────────────────────────────────
  static const Color moodPeaceful = Color(0xFF7C9A92);
  static const Color moodThankful = Color(0xFFD4A76A);
  static const Color moodJoyful = Color(0xFFE8B923);
  static const Color moodHopeful = Color(0xFF5B8C5A);
  static const Color moodAnxious = Color(0xFF8B7B8B);
  static const Color moodWorried = Color(0xFF9E8E7E);
  static const Color moodTired = Color(0xFF7A8B99);

  // ───────────────────────────────────────────────────────────────
  // Bedtime / special tokens
  // ───────────────────────────────────────────────────────────────
  static const Color bedtimeBackground = Color(0xFF000000);
  static const Color bedtimeText = Color(0xFFE0E0E0);
  static const Color bedtimeMuted = Color(0xFF808080);

  // ───────────────────────────────────────────────────────────────
  // Backward-compatible aliases (Phase 4–5 widgets reference these)
  // Aliases default to light-theme values. Dark mode is handled
  // by Theme.of(context) in properly themed widgets.
  // ───────────────────────────────────────────────────────────────
  static const Color bgPrimary = bgPrimaryLight;
  static const Color bgSecondary = bgSecondaryLight;
  static const Color surface = surfaceLight;
  static const Color surfaceElevated = surfaceElevatedLight;

  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textTertiary = textTertiaryLight;
  static const Color textInverse = textInverseLight;

  static const Color border = borderLight;
  static const Color borderSubtle = borderLight;
  static const Color borderFocused = borderFocusedLight;
  static const Color divider = dividerLight;

  static const Color accentPrimary = accentGold;
  static const Color accentSecondary = accentSage;
}

/// App-wide string constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'GraceLog';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@gracelog.app';
  static const String privacyPolicyUrl = 'https://gracelog.app/privacy.html';
  static const String supportUrl = 'https://gracelog.app/support.html';

  static const String databaseName = 'gracelog.db';
  static const int databaseVersion = 1;

  static const String iapProductId = 'com.gracelog.app.pro.monthly';

  static const List<int> streakMilestones = [7, 30, 100, 365];

  static const double minTouchTarget = 48.0;
  static const double baseGrid = 4.0;
  static const double maxDynamicTypeScale = 3.1;

  static const String exportJsonMimeType = 'application/json';
  static const String exportPngMimeType = 'image/png';
  static const String exportPdfMimeType = 'application/pdf';
  static const int exportImageSize = 1080;
}

/// SharedPreferences keys.
class PrefKeys {
  PrefKeys._();

  static const String themeMode = 'theme_mode';
  static const String biometricEnabled = 'biometric_enabled';
  static const String bedtimeMode = 'bedtime_mode';
  static const String appLocale = 'app_locale';
  static const String notificationEnabled = 'notification_enabled';
  static const String notificationHour = 'notification_hour';
  static const String notificationMinute = 'notification_minute';
}
