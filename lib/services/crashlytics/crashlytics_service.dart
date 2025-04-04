import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Singleton instance for easy access to the crashlytics service
final crashlytics = CrashlyticsService.instance;

/// Service to handle app crashes and report them to Firebase Crashlytics
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._();
  static CrashlyticsService get instance => _instance;

  CrashlyticsService._();

  /// Initialize Firebase Crashlytics
  Future<void> initialize() async {
    if (kDebugMode) {
      // Force disable Crashlytics collection in debug mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      _logInfo('Crashlytics disabled in debug mode');
    } else {
      // Enable Crashlytics collection in release mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      _logInfo('Crashlytics enabled in release mode');
    }

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Handle platform specific errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Log non-fatal exception to Crashlytics
  void recordError(dynamic exception, StackTrace stack, {bool fatal = false}) {
    FirebaseCrashlytics.instance.recordError(exception, stack, fatal: fatal);
    _logInfo('Error recorded: $exception');
  }

  /// Log custom message to Crashlytics
  void log(String message) {
    FirebaseCrashlytics.instance.log(message);
    _logInfo('Log added: $message');
  }

  /// Set user identifier for Crashlytics
  Future<void> setUserIdentifier(String identifier) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
    _logInfo('User identifier set: $identifier');
  }

  /// Add custom key/value pair to crash reports
  Future<void> setCustomKey(String key, dynamic value) async {
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
    _logInfo('Custom key set: $key = $value');
  }

  /// Helper method to log debug info
  void _logInfo(String message) {
    if (kDebugMode) {
      print('🔥 CRASHLYTICS: $message');
    }
  }
}
