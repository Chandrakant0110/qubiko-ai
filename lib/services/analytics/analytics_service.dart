import 'package:flutter/foundation.dart';

/// Debug logger that wraps analytics calls and prints them in debug mode
mixin AnalyticsLogger {
  void debugLog(String message) {
    if (kDebugMode) {
      print('📊 ANALYTICS: $message');
    }
  }

  void debugLogError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ANALYTICS ERROR: $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
}

/// Abstract class that defines the analytics service interface.
/// This allows for easy swapping of analytics providers.
abstract class AnalyticsService {
  /// Initialize the analytics service
  Future<void> init();

  /// Log an event with the given name and parameters
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  /// Set a user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  /// Set the user ID
  Future<void> setUserId(String? userId);

  /// Log a user sign up event
  Future<void> logSignUp({String? method});

  /// Log a user login event
  Future<void> logLogin({String? method});

  /// Log a screen view event
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  /// Log an error
  Future<void> logError({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  });

  /// Reset all analytics data for the current user
  Future<void> resetAnalyticsData();

  /// Enable or disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled);
}
