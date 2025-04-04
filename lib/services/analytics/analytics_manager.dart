import 'analytics_service.dart';
import 'firebase_analytics_service.dart';
import 'package:flutter/foundation.dart';

/// Manager for handling multiple analytics providers
class AnalyticsManager implements AnalyticsService {
  AnalyticsManager._();
  static final AnalyticsManager instance = AnalyticsManager._();

  final List<AnalyticsService> _providers = [];
  bool _initialized = false;
  bool _enabled = true;

  /// Initialize with default providers
  Future<void> initialize() async {
    if (_initialized) return;

    // Add Firebase Analytics provider
    await addProvider(FirebaseAnalyticsService());

    _initialized = true;

    if (kDebugMode) {
      print(
          '📊 ANALYTICS MANAGER: Initialized with ${_providers.length} providers');
    }
  }

  /// Add a new analytics provider
  Future<void> addProvider(AnalyticsService provider) async {
    await provider.init();
    _providers.add(provider);

    if (kDebugMode) {
      print('📊 ANALYTICS MANAGER: Added ${provider.runtimeType}');
    }
  }

  /// Check if the manager has been initialized
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    await initialize();
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.logEvent(name: name, parameters: parameters);
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.setUserProperty(name: name, value: value);
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.setUserId(userId);
    }
  }

  @override
  Future<void> logSignUp({String? method}) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.logSignUp(method: method);
    }
  }

  @override
  Future<void> logLogin({String? method}) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.logLogin(method: method);
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    }
  }

  @override
  Future<void> logError({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
  }) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.logError(
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    if (!_enabled) return;

    for (final provider in _providers) {
      await provider.resetAnalyticsData();
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _enabled = enabled;

    for (final provider in _providers) {
      await provider.setAnalyticsCollectionEnabled(enabled);
    }
  }
}
