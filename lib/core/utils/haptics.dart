import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized haptic feedback utility for GraceLog.
///
/// Every haptic call in the app should route through here rather
/// than calling [HapticFeedback] directly, so behavior stays
/// consistent and respects the user's reduce-motion preference.
class Haptics {
  const Haptics._();

  static bool _shouldFire(BuildContext? context) {
    if (context == null) return true;
    try {
      return !MediaQuery.of(context).disableAnimations;
    } catch (_) {
      return true;
    }
  }

  /// Light tap — button presses, list item taps.
  static void tap([BuildContext? context]) {
    if (_shouldFire(context)) HapticFeedback.lightImpact();
  }

  /// Selection change — mood chips, toggles, segmented controls.
  static void select([BuildContext? context]) {
    if (_shouldFire(context)) HapticFeedback.selectionClick();
  }

  /// Successful action — entry saved, purchase completed.
  static void success([BuildContext? context]) {
    if (_shouldFire(context)) HapticFeedback.mediumImpact();
  }

  /// Small repeated tick — scrolling through a picker, heatmap cell.
  static void tick([BuildContext? context]) {
    if (_shouldFire(context)) HapticFeedback.selectionClick();
  }

  /// Error or validation failure.
  static void error([BuildContext? context]) {
    if (_shouldFire(context)) HapticFeedback.heavyImpact();
  }
}
