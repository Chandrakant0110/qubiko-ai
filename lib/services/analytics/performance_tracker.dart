import 'package:flutter/foundation.dart';
import 'analytics.dart';
import '../crashlytics/crashlytics.dart';

/// Service to track app performance metrics
class PerformanceTracker {
  static final PerformanceTracker _instance = PerformanceTracker._();
  static PerformanceTracker get instance => _instance;

  PerformanceTracker._();

  final Map<String, DateTime> _startTimes = {};
  DateTime? _appStartTime;

  // ANSI color codes for colored console output
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _bold = '\x1B[1m';

  /// Start tracking app initialization time
  void startAppInitialization() {
    _appStartTime = DateTime.now();
    _logInfo('🚀 APP STARTING...', color: _magenta, isBold: true);
  }

  /// Mark app as fully initialized and log startup time
  void markAppInitialized() {
    if (_appStartTime == null) return;

    final startupTime = DateTime.now().difference(_appStartTime!);

    _logInfo('✅ APP INITIALIZED', color: _green, isBold: true);
    _logInfo('⏱️ COLD START TOOK: ${startupTime.inMilliseconds}ms',
        color: _yellow);

    // Log to analytics
    analytics.logEvent(
      name: 'app_start_complete',
      parameters: {
        'startup_time_ms': startupTime.inMilliseconds,
        'is_debug': kDebugMode,
      },
    );
  }

  /// Start timing an operation
  void startTiming(String operationName) {
    _startTimes[operationName] = DateTime.now();
    _logInfo('⏺️ STARTED TIMING: $operationName', color: _cyan);
  }

  /// End timing an operation and return the duration in milliseconds
  int endTiming(String operationName) {
    if (!_startTimes.containsKey(operationName)) return 0;

    final duration = DateTime.now().difference(_startTimes[operationName]!);
    _startTimes.remove(operationName);

    return duration.inMilliseconds;
  }

  /// End timing and log the result
  void endTimingAndLog(String operationName,
      {String? eventName, Map<String, dynamic>? additionalParams}) {
    final durationMs = endTiming(operationName);
    if (durationMs == 0) return;

    _logInfo('⏱️ $operationName TOOK: ${durationMs}ms', color: _yellow);

    // Log to analytics if eventName is provided
    if (eventName != null) {
      final params = <String, dynamic>{
        'duration_ms': durationMs,
      };

      if (additionalParams != null) {
        params.addAll(additionalParams);
      }

      analytics.logEvent(
        name: eventName,
        parameters: params,
      );
    }
  }

  /// Helper method to log beautiful debug info with colors
  void _logInfo(String message, {String color = '', bool isBold = false}) {
    if (kDebugMode) {
      final formattedMessage =
          isBold ? '$color$_bold$message$_reset' : '$color$message$_reset';
      print(formattedMessage);
    }
  }

  /// Track screen navigation with timing
  void trackNavigation(String screenName, {String? previousScreen}) {
    final params = <String, dynamic>{
      'screen_name': screenName,
    };

    if (previousScreen != null) {
      params['previous_screen'] = previousScreen;
    }

    _logInfo(
        '🔄 NAVIGATED TO: $screenName ${previousScreen != null ? 'from $previousScreen' : ''}',
        color: _blue);

    analytics.logEvent(
      name: 'screen_navigation',
      parameters: params,
    );
  }

  /// Track button click events
  void trackButtonClick(String buttonName,
      {String? screenName, Map<String, dynamic>? additionalParams}) {
    final params = <String, dynamic>{
      'button_name': buttonName,
    };

    if (screenName != null) {
      params['screen_name'] = screenName;
    }

    if (additionalParams != null) {
      params.addAll(additionalParams);
    }

    _logInfo(
        '👆 BUTTON CLICKED: $buttonName ${screenName != null ? 'on $screenName' : ''}',
        color: _green);

    analytics.logEvent(
      name: 'button_click',
      parameters: params,
    );
  }

  /// Log an error with red color
  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logInfo('❌ ERROR: $message', color: _red, isBold: true);

    if (error != null) {
      _logInfo('   $error', color: _red);
    }

    if (stackTrace != null) {
      _logInfo('   $stackTrace', color: _red);
    }

    // Also log to analytics
    final params = <String, Object>{
      'message': message,
    };

    if (error != null) {
      params['error'] = error.toString();
    }

    analytics.logEvent(
      name: 'app_error',
      parameters: params,
    );

    // Record error to Crashlytics
    crashlytics.log('ERROR: $message');
    final errorToRecord = error ?? message;
    final stackToRecord = stackTrace ?? StackTrace.current;
    crashlytics.recordError(errorToRecord, stackToRecord, fatal: false);
  }

  /// Log a custom event with a specific color
  void logCustomEvent(String message,
      {String? eventName,
      Map<String, dynamic>? parameters,
      String color = ''}) {
    // Use white if no color specified
    final logColor = color.isEmpty ? _white : color;
    _logInfo('📝 $message', color: logColor);

    if (eventName != null) {
      analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    }
  }

  /// Get the color code by name for custom logging
  static String getColorByName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return _red;
      case 'green':
        return _green;
      case 'yellow':
        return _yellow;
      case 'blue':
        return _blue;
      case 'magenta':
        return _magenta;
      case 'cyan':
        return _cyan;
      case 'white':
        return _white;
      default:
        return '';
    }
  }
}
