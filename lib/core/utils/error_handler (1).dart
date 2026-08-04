import 'package:flutter/material.dart';

/// Global error handling boundary.
/// Every async operation should be wrapped in [safeAsync].
class ErrorHandler {
  const ErrorHandler._();

  /// Initializes global error handling.
  static void setup() {
    FlutterError.onError = (FlutterErrorDetails details) {
      logError(details.exception, details.stack);
    };
  }

  /// Logs an error silently (no UI).
  /// In production, this could route to a crash reporter.
  static void logError(dynamic error, StackTrace? stackTrace) {
    // ignore: avoid_print
    debugPrint('[GraceLog Error] $error');
    if (stackTrace != null) {
      // ignore: avoid_print
      debugPrint(stackTrace.toString());
    }
  }

  /// Displays a non-intrusive error banner.
  static void showErrorBanner(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        leading: const Icon(Icons.error_outline, color: Colors.red),
        backgroundColor: Colors.red.shade50,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('DISMISS'),
          ),
        ],
      ),
    );
  }

  /// Wraps an async operation with error handling and mounted checks.
  ///
  /// Usage:
  /// ```dart
  /// await ErrorHandler.safeAsync(() async {
  ///   await someFuture();
  /// }, context: context, onError: (e) => showErrorBanner(context, e.toString()));
  /// ```
  static Future<void> safeAsync(
    Future<void> Function() operation, {
    required BuildContext context,
    void Function(dynamic error)? onError,
    VoidCallback? onComplete,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (context.mounted && onError != null) {
        onError(error);
      }
    } finally {
      if (context.mounted && onComplete != null) {
        onComplete();
      }
    }
  }

  /// Wraps an async operation that returns a value.
  static Future<T?> safeAsyncWithResult<T>(
    Future<T> Function() operation, {
    required BuildContext context,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      if (context.mounted && onError != null) {
        onError(error);
      }
      return null;
    }
  }
}

/// Mixin for widgets that need mounted-state guards.
mixin MountedCheckMixin<T extends StatefulWidget> on State<T> {
  /// Safely calls setState only if the widget is still mounted.
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}
