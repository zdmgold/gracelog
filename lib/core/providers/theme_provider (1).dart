import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's [ThemeMode] (light / dark / system).
///
/// Persists the selection to SharedPreferences key `theme_mode`.
/// Notifies all listeners on change. Default is [ThemeMode.system].
class ThemeProvider extends ValueNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.system) {
    _load();
  }

  static const String _prefsKey = 'theme_mode';

  /// Loads the saved theme mode from SharedPreferences.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null) {
        value = ThemeMode.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e, stackTrace) {
      _logError('_load', e, stackTrace);
    }
  }

  /// Sets the theme mode and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (value == mode) return;
    value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (e, stackTrace) {
      _logError('setThemeMode', e, stackTrace);
    }
  }

  /// Toggles between light and dark, ignoring system.
  Future<void> toggleLightDark() async {
    final next = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[ThemeProvider::$method] $error\n$stackTrace');
  }
}
