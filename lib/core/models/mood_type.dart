import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// The seven mood states available in GraceLog.
enum MoodType {
  peaceful,
  thankful,
  joyful,
  hopeful,
  anxious,
  worried,
  tired;

  /// Localized display name ARB key.
  String get displayNameKey => switch (this) {
        MoodType.peaceful => 'moodPeaceful',
        MoodType.thankful => 'moodThankful',
        MoodType.joyful => 'moodJoyful',
        MoodType.hopeful => 'moodHopeful',
        MoodType.anxious => 'moodAnxious',
        MoodType.worried => 'moodWorried',
        MoodType.tired => 'moodTired',
      };

  /// Semantic color token for this mood.
  Color get colorToken => switch (this) {
        MoodType.peaceful => AppColors.moodPeaceful,
        MoodType.thankful => AppColors.moodThankful,
        MoodType.joyful => AppColors.moodJoyful,
        MoodType.hopeful => AppColors.moodHopeful,
        MoodType.anxious => AppColors.moodAnxious,
        MoodType.worried => AppColors.moodWorried,
        MoodType.tired => AppColors.moodTired,
      };

  /// Material icon code point for this mood.
  IconData get icon => switch (this) {
        MoodType.peaceful => Icons.water_drop_outlined,
        MoodType.thankful => Icons.favorite_border,
        MoodType.joyful => Icons.wb_sunny_outlined,
        MoodType.hopeful => Icons.lightbulb_outline,
        MoodType.anxious => Icons.cloud_outlined,
        MoodType.worried => Icons.waves_outlined,
        MoodType.tired => Icons.nightlight_outlined,
      };

  /// The JSON tag used in scripture batch files.
  String get scriptureTag => name;

  /// Parses from a string (case-insensitive).
  /// Falls back to [MoodType.peaceful] if unknown.
  static MoodType fromString(String value) {
    return MoodType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MoodType.peaceful,
    );
  }

  /// All moods in display order.
  static List<MoodType> get all => MoodType.values;
}
