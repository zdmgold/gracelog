import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

/// GraceLog In-App Purchase service.
///
/// Manages a single subscription product:
///   [com.gracelog.app.pro.monthly] at $0.99/month.
///
/// The subscription removes the banner ad only. Zero feature gating.
///
/// Exposes a [isSubscribed] stream that providers listen to.
/// Automatically acknowledges pending Android purchases.
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  /// The single GraceLog Pro monthly subscription product ID.
  static const String _proMonthlyId = 'com.gracelog.app.pro.monthly';

  final InAppPurchase _iap = InAppPurchase.instance;
  final StreamController<bool> _subscriptionController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSubscription;
  List<ProductDetails> _products = [];
  bool _initialized = false;

  /// Stream that emits true when the user has an active subscription,
  /// false otherwise. Widgets listen to this via SubscriptionProvider.
  Stream<bool> get isSubscribed => _subscriptionController.stream;

  /// The cached subscription state. Defaults to false until queried.
  bool _cachedSubscribed = false;
  bool get cachedSubscribed => _cachedSubscribed;

  /// Initializes the IAP connection, queries available products, and
  /// attaches the purchase stream listener.
  ///
  /// Safe to call multiple times --- subsequent calls are no-ops.
  Future<void> initialize() async {
    if (_initialized) return;

    final bool available = await _iap.isAvailable();
    if (!available) {
      _subscriptionController.add(false);
      _initialized = true;
      return;
    }

    // Query product details
    final ProductDetailsResponse response =
        await _iap.queryProductDetails({_proMonthlyId});
    _products = response.productDetails;

    if (response.notFoundIDs.isNotEmpty) {
      _logError(
        'initialize',
        'Product not found: ${response.notFoundIDs}',
        StackTrace.current,
      );
    }

    // Listen to purchase updates
    _purchaseStreamSubscription =
        _iap.purchaseStream.listen(_onPurchaseUpdate, onError: (error) {
      _logError('purchaseStream', error, StackTrace.current);
    });

    // Restore past purchases to determine current status
    await restorePurchases();

    _initialized = true;
  }

  /// Initiates a purchase flow for the Pro monthly subscription.
  ///
  /// Returns true if the purchase request was sent to the platform
  /// successfully. The actual purchase result arrives via the
  /// [purchaseStream] listener.
  Future<bool> purchase() async {
    if (!_initialized || _products.isEmpty) return false;

    try {
      final product = _products.firstWhere(
        (p) => p.id == _proMonthlyId,
      );
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e, stackTrace) {
      _logError('purchase', e, stackTrace);
      return false;
    }
  }

  /// Restores previous purchases from the platform store.
  ///
  /// This re-evaluates subscription status on app reinstalls and
  /// across devices (for the same Apple ID / Google account).
  /// Emits the updated [isSubscribed] state.
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e, stackTrace) {
      _logError('restorePurchases', e, stackTrace);
    }
  }

  /// Disposes the purchase stream subscription and the broadcast
  /// controller. Call this from the app lifecycle on destroy.
  void dispose() {
    _purchaseStreamSubscription?.cancel();
    _subscriptionController.close();
  }

  // ------------------------------------------------------------------
  // Purchase stream handler
  // ------------------------------------------------------------------

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.pending:
          _logInfo('Purchase pending: ${purchase.productID}');
          break;

        case PurchaseStatus.error:
          _logError(
            'purchaseStream',
            'Purchase error: ${purchase.error?.message}',
            StackTrace.current,
          );
          break;

        case PurchaseStatus.canceled:
          _logInfo('Purchase canceled: ${purchase.productID}');
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchase) {
    if (purchase.productID == _proMonthlyId) {
      // On Android, we must acknowledge the purchase explicitly
      if (purchase is GooglePlayPurchaseDetails) {
        final billingClientPurchase = purchase.billingClientPurchase;
        if (!billingClientPurchase.isAcknowledged) {
          final androidAddition =
              _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          androidAddition.consumePurchase(purchase);
        }
      }

      _cachedSubscribed = true;
      _subscriptionController.add(true);
      _logInfo('Subscription active: ${purchase.productID}');
    }
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  void _logInfo(String message) {
    // In production this routes to the global ErrorHandler at info level.
    // ignore: avoid_print
    print('[IAPService] $message');
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // In production this routes to the global ErrorHandler.
    // ignore: avoid_print
    print('[IAPService::$method] $error\n$stackTrace');
  }
}
