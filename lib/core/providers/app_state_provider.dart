import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../platform/notification_service.dart';

/// Immutable state container for app-level settings.
class AppState {
  const AppState({
    this.isBiometricEnabled = false,
    this.isBedtimeMode = false,
    this.currentLocale = const Locale('en'),
    this.reminderHour = 20,
    this.reminderMinute = 0,
  });

  final bool isBiometricEnabled;
  final bool isBedtimeMode;
  final Locale currentLocale;
  final int reminderHour;
  final int reminderMinute;

  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour, minute: reminderMinute);

  AppState copyWith({
    bool? isBiometricEnabled,
    bool? isBedtimeMode,
    Locale? currentLocale,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return AppState(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBedtimeMode: isBedtimeMode ?? this.isBedtimeMode,
      currentLocale: currentLocale ?? this.currentLocale,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}

/// Manages app-wide state: biometric lock, bedtime reflection mode,
/// current locale, and the daily reminder time. Persists all settings
/// to SharedPreferences.
class AppStateProvider extends ValueNotifier<AppState> {
  AppStateProvider() : super(const AppState()) {
    _load();
  }

  static const String _biometricKey = 'biometric_enabled';
  static const String _bedtimeKey = 'bedtime_mode';
  static const String _localeKey = 'app_locale';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometric = prefs.getBool(_biometricKey) ?? false;
      final bedtime = prefs.getBool(_bedtimeKey) ?? false;
      final localeCode = prefs.getString(_localeKey) ?? 'en';
      final reminderHour = prefs.getInt(_reminderHourKey) ?? 20;
      final reminderMinute = prefs.getInt(_reminderMinuteKey) ?? 0;

      value = value.copyWith(
        isBiometricEnabled: biometric,
        isBedtimeMode: bedtime,
        currentLocale: Locale(localeCode),
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      );
    } catch (e, stackTrace) {
      _logError('_load', e, stackTrace);
    }
  }

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

  /// Updates the daily reminder time, persists it, and reschedules the
  /// actual notification so this stays the single source of truth.
  Future<void> setReminderTime(TimeOfDay time) async {
    value = value.copyWith(reminderHour: time.hour, reminderMinute: time.minute);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_reminderHourKey, time.hour);
      await prefs.setInt(_reminderMinuteKey, time.minute);
      await NotificationService().scheduleDailyReminder(hour: time.hour, minute: time.minute);
    } catch (e, stackTrace) {
      _logError('setReminderTime', e, stackTrace);
    }
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[AppStateProvider::$method] $error\n$stackTrace');
  }
}
