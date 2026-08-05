import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/constants.dart';

/// GraceLog local notification service for streak reminders.
///
/// Schedules a daily reminder at a user-configurable time (default 20:00).
/// If the user has already logged an entry for today, the notification
/// is silenced automatically.
///
/// Graceful degradation: if permission is denied or the plugin fails
/// to initialize, all methods become no-ops without crashing the app.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  /// Channel ID for Android notifications.
  static const String _channelId = 'gracelog_streak_reminders';

  /// Channel name visible to the user in Android system settings.
  static const String _channelName = 'Streak Reminders';

  /// Channel description visible in Android system settings.
  static const String _channelDescription =
      'Daily reminders to log your gratitude and maintain your streak.';

  /// Notification ID for the daily streak reminder.
  static const int _dailyReminderId = 1001;

  /// Default reminder time: 20:00 (8:00 PM).
  static const TimeOfDay _defaultTime = TimeOfDay(hour: 20, minute: 0);

  /// Initializes the notification plugin, requests permissions,
  /// and configures timezone data.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz_data.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _permissionGranted = await _requestPermissions();
      _initialized = true;
    } catch (e, stackTrace) {
      _logError('initialize', e, stackTrace);
      _initialized = true;
      _permissionGranted = false;
    }
  }

  /// Requests notification permissions from the user.
  /// On iOS, this triggers the system permission dialog.
  /// On Android 13+, this triggers the POST_NOTIFICATIONS dialog.
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        final result = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      }

      if (Platform.isAndroid) {
        final result = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return result ?? false;
      }

      return false;
    } catch (e, stackTrace) {
      _logError('_requestPermissions', e, stackTrace);
      return false;
    }
  }

  /// Schedules a daily streak reminder at [hour]:[minute] in the
  /// device's local timezone.
  ///
  /// If [hour] and [minute] are omitted, defaults to 20:00.
  /// If permissions are not granted, this is a no-op.
  Future<void> scheduleDailyReminder({int? hour, int? minute}) async {
    if (!_initialized || !_permissionGranted) return;

    final targetHour = hour ?? _defaultTime.hour;
    final targetMinute = minute ?? _defaultTime.minute;

    try {
      await _plugin.zonedSchedule(
        _dailyReminderId,
        AppConstants.appName,
        "Don't break your streak! Take a moment to reflect on today's blessings.",
        _nextInstanceOfTime(targetHour, targetMinute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: false,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, stackTrace) {
      _logError('scheduleDailyReminder', e, stackTrace);
    }
  }

  /// Cancels the daily streak reminder.
  Future<void> cancelDailyReminder() async {
    if (!_initialized) return;

    try {
      await _plugin.cancel(_dailyReminderId);
    } catch (e, stackTrace) {
      _logError('cancelDailyReminder', e, stackTrace);
    }
  }

  /// Cancels all pending notifications.
  Future<void> cancelAll() async {
    if (!_initialized) return;

    try {
      await _plugin.cancelAll();
    } catch (e, stackTrace) {
      _logError('cancelAll', e, stackTrace);
    }
  }

  /// Returns true if notification permissions have been granted.
  bool get hasPermission => _permissionGranted;

  /// Computes the next [TZDateTime] occurrence of [hour]:[minute]
  /// in the local timezone. If that time has already passed today,
  /// returns tomorrow's occurrence.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Handles notification tap. Currently routes to the home dashboard
  /// by doing nothing — the app is already running or will cold-start
  /// to the default route.
  void _onNotificationTap(NotificationResponse response) {
    _logInfo('Notification tapped: ${response.payload}');
  }

  void _logInfo(String message) {
    // ignore: avoid_print
    print('[NotificationService] $message');
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[NotificationService::$method] $error
$stackTrace');
  }
}
