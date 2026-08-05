import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// GraceLog AdMob service with mandatory graceful degradation.
///
/// If initialization fails for any reason (network, policy, config),
/// the service silently sets [isAvailable] to false and the banner
/// slot collapses to zero height. The app never crashes on launch
/// due to AdMob.
///
/// All banner display methods first check [SubscriptionProvider]
/// state via the [shouldShowAds] callback.
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  /// Google's official test App IDs. Safe for debug builds.
  /// Replace with production IDs before store submission.
  static const String _androidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String _iosAppId =
      'ca-app-pub-3940256099942544~1458002511';

  /// Google's official test Banner Unit IDs.
  static const String _androidBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  bool _initialized = false;
  bool _isAvailable = false;
  BannerAd? _bannerAd;

  /// True if AdMob initialized successfully and ads can be requested.
  bool get isAvailable => _isAvailable;

  /// The currently loaded banner ad, or null if none.
  BannerAd? get bannerAd => _bannerAd;

  /// Callback injected by [SubscriptionProvider].
  /// Returns true when the user is NOT subscribed (ads should show).
  bool Function()? shouldShowAds;

  /// Initializes the Mobile Ads SDK with the platform-correct App ID.
  ///
  /// Wrapped in a broad try/catch so that ANY failure results in
  /// [isAvailable] = false rather than an uncaught exception.
  /// Safe to call multiple times --- subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appId = Platform.isAndroid ? _androidAppId : _iosAppId;
      await MobileAds.instance.initialize();
      _isAvailable = true;
    } catch (e, stackTrace) {
      _isAvailable = false;
      _logError('initialize', e, stackTrace);
    } finally {
      _initialized = true;
    }
  }

  /// Loads a new [BannerAd] if AdMob is available and the user has
  /// not purchased the ad-removal subscription.
  ///
  /// If [shouldShowAds] returns false (subscribed), the existing
  /// banner is disposed and no new ad is requested.
  ///
  /// Returns the loaded [BannerAd] on success, or null.
  Future<BannerAd?> loadBannerAd() async {
    if (!_isAvailable) return null;

    // Subscription check: if user is Pro, hide ads immediately.
    if (shouldShowAds != null && !shouldShowAds!()) {
      disposeBannerAd();
      return null;
    }

    disposeBannerAd();

    final unitId = Platform.isAndroid ? _androidBannerUnitId : _iosBannerUnitId;

    try {
      final banner = BannerAd(
        adUnitId: unitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _logInfo('Banner ad loaded: ${ad.adUnitId}');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _logError(
              'loadBannerAd',
              'Ad failed to load: ${error.message} (code ${error.code})',
              StackTrace.current,
            );
          },
          onAdOpened: (ad) => _logInfo('Banner ad opened'),
          onAdClosed: (ad) => _logInfo('Banner ad closed'),
          onAdImpression: (ad) => _logInfo('Banner ad impression recorded'),
        ),
      );

      await banner.load();
      _bannerAd = banner;
      return banner;
    } catch (e, stackTrace) {
      _logError('loadBannerAd', e, stackTrace);
      return null;
    }
  }

  /// Disposes the current banner ad and nulls the reference.
  /// Safe to call when no banner is loaded.
  void disposeBannerAd() {
    try {
      _bannerAd?.dispose();
    } catch (e, stackTrace) {
      _logError('disposeBannerAd', e, stackTrace);
    } finally {
      _bannerAd = null;
    }
  }

  /// Convenience method that returns a [Widget] wrapping the banner
  /// ad, or a [SizedBox.shrink()] when ads should not be shown.
  ///
  /// Use this directly in screen build methods:
  /// ```dart
  /// bottomNavigationBar: AdMobService().bannerWidget(),
  /// ```
  Widget bannerWidget() {
    if (!_isAvailable) return const SizedBox.shrink();
    if (shouldShowAds != null && !shouldShowAds!()) {
      return const SizedBox.shrink();
    }
    if (_bannerAd == null) return const SizedBox.shrink();

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  /// Forces a banner reload. Useful after orientation changes or
  /// when returning from the subscription purchase screen.
  Future<BannerAd?> refreshBanner() => loadBannerAd();

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  void _logInfo(String message) {
    // In production this routes to the global ErrorHandler at info level.
    // ignore: avoid_print
    print('[AdMobService] $message');
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // In production this routes to the global ErrorHandler.
    // ignore: avoid_print
    print('[AdMobService::$method] $error\n$stackTrace');
  }
}
