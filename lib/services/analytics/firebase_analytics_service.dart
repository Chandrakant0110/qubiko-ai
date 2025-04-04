import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

/// Firebase implementation of the Analytics Service
class FirebaseAnalyticsService implements AnalyticsService {
  late final FirebaseAnalytics _analytics;

  @override
  Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
    if (kDebugMode) {
      print('📊 ANALYTICS: Firebase Analytics initialized');
    }
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Convert Map<String, dynamic> to Map<String, Object>
      Map<String, Object>? analyticsParams;
      if (parameters != null) {
        analyticsParams = {};
        parameters.forEach((key, value) {
          if (value != null) {
            analyticsParams![key] = value.toString();
          }
        });
      }

      await _analytics.logEvent(
        name: name,
        parameters: analyticsParams,
      );

      if (kDebugMode) {
        print(
            '📊 ANALYTICS: Event logged: $name ${parameters != null ? '- $parameters' : ''}');
      }
    } catch (e, stackTrace) {
      _printError('Failed to log event: $name', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(
        name: name,
        value: value,
      );

      if (kDebugMode) {
        print('📊 ANALYTICS: User property set: $name = $value');
      }
    } catch (e, stackTrace) {
      _printError('Failed to set user property: $name', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);

      if (kDebugMode) {
        print('📊 ANALYTICS: User ID set: $userId');
      }
    } catch (e, stackTrace) {
      _printError('Failed to set user ID', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> logSignUp({String? method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method ?? '');

      if (kDebugMode) {
        print(
            '📊 ANALYTICS: Sign up logged ${method != null ? 'with method: $method' : ''}');
      }
    } catch (e, stackTrace) {
      _printError('Failed to log sign up', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> logLogin({String? method}) async {
    try {
      await _analytics.logLogin(loginMethod: method ?? '');

      if (kDebugMode) {
        print(
            '📊 ANALYTICS: Login logged ${method != null ? 'with method: $method' : ''}');
      }
    } catch (e, stackTrace) {
      _printError('Failed to log login', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? '',
      );

      if (kDebugMode) {
        print(
            '📊 ANALYTICS: Screen view logged: $screenName ${screenClass != null ? '($screenClass)' : ''}');
      }
    } catch (e, stackTrace) {
      _printError('Failed to log screen view: $screenName', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> logError({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  }) async {
    try {
      final Map<String, Object> errorParams = {
        'message': message,
      };

      if (error != null) {
        errorParams['error'] = error.toString();
      }

      if (stackTrace != null) {
        final trace = stackTrace.toString();
        errorParams['stackTrace'] =
            trace.length > 500 ? trace.substring(0, 500) : trace;
      }

      await _analytics.logEvent(
        name: 'app_error',
        parameters: errorParams,
      );

      _printError(message, error, stackTrace);
    } catch (e, stk) {
      _printError('Failed to log error event', e, stk);
      // Don't rethrow here to avoid recursive errors
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();

      if (kDebugMode) {
        print('📊 ANALYTICS: Analytics data reset');
      }
    } catch (e, stackTrace) {
      _printError('Failed to reset analytics data', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);

      if (kDebugMode) {
        print(
            '📊 ANALYTICS: Analytics collection ${enabled ? 'enabled' : 'disabled'}');
      }
    } catch (e, stackTrace) {
      _printError('Failed to set analytics collection enabled: $enabled', e,
          stackTrace);
      rethrow;
    }
  }

  /// Internal helper for debug error printing
  void _printError(String message, [dynamic error, StackTrace? stackTrace]) {
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
