import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable state container for app-level settings.
class AppState {
  const AppState({
    this.isBiometricEnabled = false,
    this.isBedtimeMode = false,
    this.currentLocale = const Locale('en'),
  });

  final bool isBiometricEnabled;
  final bool isBedtimeMode;
  final Locale currentLocale;

  AppState copyWith({
    bool? isBiometricEnabled,
    bool? isBedtimeMode,
    Locale? currentLocale,
  }) {
    return AppState(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBedtimeMode: isBedtimeMode ?? this.isBedtimeMode,
      currentLocale: currentLocale ?? this.currentLocale,
    );
  }
}

/// Manages app-wide state: biometric lock, bedtime reflection mode,
/// and current locale. Persists all settings to SharedPreferences.
class AppStateProvider extends ValueNotifier<AppState> {
  AppStateProvider() : super(const AppState()) {
    _load();
  }

  static const String _biometricKey = 'biometric_enabled';
  static const String _bedtimeKey = 'bedtime_mode';
  static const String _localeKey = 'app_locale';

  /// Loads all persisted settings.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometric = prefs.getBool(_biometricKey) ?? false;
      final bedtime = prefs.getBool(_bedtimeKey) ?? false;
      final localeCode = prefs.getString(_localeKey) ?? 'en';

      value = value.copyWith(
        isBiometricEnabled: biometric,
        isBedtimeMode: bedtime,
        currentLocale: Locale(localeCode),
      );
    } catch (e, stackTrace) {
      _logError('_load', e, stackTrace);
    }
  }

  /// Toggles biometric app lock on/off.
  Future<void> toggleBiometric() async {
    final next = !value.isBiometricEnabled;
    value = value.copyWith(isBiometricEnabled: next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricKey, next);
    } catch (e, stackTrace) {
      _logError('toggleBiometric', e, stackTrace);
    }
  }

  /// Toggles bedtime reflection mode (OLED black UI, simplified entry).
  Future<void> toggleBedtimeMode() async {
    final next = !value.isBedtimeMode;
    value = value.copyWith(isBedtimeMode: next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_bedtimeKey, next);
    } catch (e, stackTrace) {
      _logError('toggleBedtimeMode', e, stackTrace);
    }
  }

  /// Sets the app locale to [localeCode] (e.g., 'en', 'es', 'ar').
  Future<void> setLocale(String localeCode) async {
    if (value.currentLocale.languageCode == localeCode) return;
    final locale = Locale(localeCode);
    value = value.copyWith(currentLocale: locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, localeCode);
    } catch (e, stackTrace) {
      _logError('setLocale', e, stackTrace);
    }
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[AppStateProvider::$method] $error\n$stackTrace');
  }
}
