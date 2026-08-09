import 'package:flutter/material.dart';

/// GraceLog semantic color tokens.
///
/// Jewel-tone palette: gold (primary), amethyst (secondary), deep ink
/// (dark background), ruby (error). All widgets should consume colors
/// via [Theme.of(context)] where possible — the un-suffixed legacy
/// aliases below (bgPrimary, textPrimary, etc.) exist only for the
/// small number of screens not yet converted to theme-aware colors
/// (e.g. ScriptureDetailScreen) and always resolve to light-mode
/// values regardless of the active theme.
class AppColors {
  AppColors._();

  // ------------------------------------------------------------------
  // Light theme
  // ------------------------------------------------------------------
  static const Color bgPrimaryLight = Color(0xFFFBF6EC);
  static const Color bgSecondaryLight = Color(0xFFF3EBDB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF7F1E3);
  static const Color textPrimaryLight = Color(0xFF241C10);
  static const Color textSecondaryLight = Color(0xFF5C5142);
  static const Color textTertiaryLight = Color(0xFF8A8071);
  static const Color textInverseLight = Color(0xFF1A140F);
  static const Color borderLight = Color(0xFFE2D6BE);
  static const Color borderFocusedLight = Color(0xFFD4AF37);
  static const Color dividerLight = Color(0xFFE9E0CC);

  // ------------------------------------------------------------------
  // Dark theme
  // ------------------------------------------------------------------
  static const Color bgPrimaryDark = Color(0xFF1A140F);
  static const Color bgSecondaryDark = Color(0xFF241C15);
  static const Color surfaceDark = Color(0xFF221B15);
  static const Color surfaceElevatedDark = Color(0xFF2A2119);
  static const Color textPrimaryDark = Color(0xFFF5EFE4);
  static const Color textSecondaryDark = Color(0xFFC9BFAE);
  static const Color textTertiaryDark = Color(0xFF8F8573);
  static const Color textInverseDark = Color(0xFF1A140F);
  static const Color borderDark = Color(0xFF3A2E20);
  static const Color borderFocusedDark = Color(0xFFF4D160);
  static const Color dividerDark = Color(0xFF332920);

  // ------------------------------------------------------------------
  // Brand accents (theme-agnostic — same value in light and dark)
  // ------------------------------------------------------------------
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentAmethyst = Color(0xFF6B4FA0);
  static const Color accentAmber = Color(0xFFE0943E);
  static const Color accentEmerald = Color(0xFF3B9B6F);
  static const Color accentRuby = Color(0xFFE0435C);

  /// Legacy alias — value is now amethyst, not green. Kept only
  /// because theme.dart references this exact name for
  /// ColorScheme.secondary; new code should use [accentAmethyst].
  static const Color accentSage = accentAmethyst;

  /// Legacy alias for [accentGold], referenced by a few widgets
  /// (StreakFlame, WeeklyBlessingCard) for warm highlight accents.
  static const Color accentWarm = accentGold;

  /// Legacy alias for [accentAmber], referenced by StreakFlame for
  /// its 7-29 day streak tier.
  static const Color accentOrange = accentAmber;

  /// Success color — intentionally independent of [accentAmethyst]
  /// (previously aliased to the old sage-green token; decoupled so
  /// "success" and "secondary accent" are no longer secretly the
  /// same color).
  static const Color accentSuccess = accentEmerald;

  // ------------------------------------------------------------------
  // Error
  // ------------------------------------------------------------------
  static const Color textError = accentRuby;
  static const Color borderError = textError;

  // ------------------------------------------------------------------
  // Mood colors
  // ------------------------------------------------------------------
  static const Color moodPeaceful = Color(0xFF6B4FA0);
  static const Color moodThankful = Color(0xFFD4AF37);
  static const Color moodJoyful = Color(0xFFE0943E);
  static const Color moodHopeful = Color(0xFF3B9B6F);
  static const Color moodAnxious = Color(0xFF4A7FB5);
  static const Color moodWorried = Color(0xFF8A6BAE);
  static const Color moodTired = Color(0xFF7A6F5E);

  // ------------------------------------------------------------------
  // Shadows
  // ------------------------------------------------------------------
  static const List<BoxShadow> shadowLight = [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 3)),
  ];
  static const List<BoxShadow> shadowHeavy = [
    BoxShadow(color: Color(0x2E000000), blurRadius: 20, offset: Offset(0, 6)),
  ];

  // ------------------------------------------------------------------
  // Glassmorphism overlays
  // ------------------------------------------------------------------
  static const Color glassWhite = Color(0x1FFFFFFF);
  static const Color glassDark = Color(0x33241C10);

  // ------------------------------------------------------------------
  // Legacy un-suffixed aliases (always light-mode values)
  // ------------------------------------------------------------------
  static const Color bgPrimary = bgPrimaryLight;
  static const Color bgSecondary = bgSecondaryLight;
  static const Color bgTertiary = surfaceElevatedLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color accentPrimary = accentGold;
  static const Color borderSubtle = borderLight;
}

/// GraceLog non-color design tokens: durations, curves, milestones,
/// app metadata, and the rotating home-screen taglines.
class AppConstants {
  AppConstants._();

  static const String appName = 'GraceLog';

  // ------------------------------------------------------------------
  // Motion
  // ------------------------------------------------------------------
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 600);
  static const Curve easeOutExpo = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Curve easeInOutCubic = Cubic(0.65, 0.0, 0.35, 1.0);

  // ------------------------------------------------------------------
  // Streak milestones
  // ------------------------------------------------------------------
  static const List<int> streakMilestones = [7, 30, 100, 365];

  // ------------------------------------------------------------------
  // Rotating home-screen taglines
  //
  // Indexed [weekday][timeSlot]: weekday 0=Monday..6=Sunday (matches
  // DateTime.weekday - 1). timeSlot 0=morning, 1=afternoon, 2=evening.
  // 21 total, 3 per day.
  // ------------------------------------------------------------------
  static const List<List<String>> dailyTaglines = [
    // Monday
    [
      'A new week of grace begins',
      'Halfway into Monday, still counting',
      "Monday's done, grace remains",
    ],
    // Tuesday
    [
      'Tuesday grace, fresh as coffee',
      'Small graces, logged daily',
      "Tuesday's quiet thanks",
    ],
    // Wednesday
    [
      'Midweek grace, right on time',
      'Halfway there, still grateful',
      'Wednesday winds down gently',
    ],
    // Thursday
    [
      'Grace meets you here today',
      'Almost Friday, still thankful',
      "Thursday's gentle reflection",
    ],
    // Friday
    [
      'Count it all joy this week',
      'Friday grace, well earned',
      'The week closes in gratitude',
    ],
    // Saturday
    [
      'Soaking in so much grace',
      "Saturday's slower kind of thanks",
      'An easy evening, full of grace',
    ],
    // Sunday
    [
      'A quiet moment of thanks',
      'Sunday grace, unhurried',
      'Closing the week in peace',
    ],
  ];

  /// Returns today's tagline for the current time of day.
  static String currentTagline() {
    final now = DateTime.now();
    final dayIndex = now.weekday - 1;
    final timeSlot = now.hour < 12 ? 0 : (now.hour < 17 ? 1 : 2);
    return dailyTaglines[dayIndex][timeSlot];
  }
}
