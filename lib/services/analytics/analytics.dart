// Export the main analytics interfaces and implementations
export 'analytics_service.dart';
export 'analytics_manager.dart';
export 'firebase_analytics_service.dart';

// Export a singleton instance for easy access
import 'analytics_manager.dart';

/// Singleton for accessing analytics throughout the app
final analytics = AnalyticsManager.instance;
