import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/iap_service.dart';

/// Manages the user's subscription state (ad-removal only).
///
/// Listens to [IAPService.isSubscribed] and caches the boolean in
/// SharedPreferences for instant UI decisions before the IAP stream
/// emits. Default is false (not subscribed, ads show).
class SubscriptionProvider extends ValueNotifier<bool> {
  SubscriptionProvider() : super(false) {
    _load();
  }

  static const String _prefsKey = 'is_subscribed';
  StreamSubscription<bool>? _iapSubscription;

  /// Loads the cached state and attaches the IAP stream listener.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getBool(_prefsKey);
      if (cached != null) value = cached;
    } catch (e, stackTrace) {
      _logError('_load cache', e, stackTrace);
    }

    // Attach to IAP stream
    _iapSubscription = IAPService().isSubscribed.listen(
      (subscribed) {
        if (value != subscribed) {
          value = subscribed;
          _persist(subscribed);
        }
      },
      onError: (error) {
        _logError('IAP stream', error, StackTrace.current);
      },
    );
  }

  /// Triggers the purchase flow via [IAPService].
  /// Returns true if the request was sent successfully.
  Future<bool> purchaseSubscription() async {
    return IAPService().purchase();
  }

  /// Triggers restore purchases via [IAPService].
  Future<void> restorePurchases() async {
    await IAPService().restorePurchases();
  }

  /// Forces a re-check of subscription status.
  /// Useful on app resume or after a purchase attempt.
  Future<void> checkStatus() async {
    await IAPService().restorePurchases();
  }

  @override
  void dispose() {
    _iapSubscription?.cancel();
    super.dispose();
  }

  Future<void> _persist(bool subscribed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, subscribed);
    } catch (e, stackTrace) {
      _logError('_persist', e, stackTrace);
    }
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[SubscriptionProvider::$method] $error\n$stackTrace');
  }
}
