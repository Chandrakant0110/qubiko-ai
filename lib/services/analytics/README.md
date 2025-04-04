# Analytics Service

This is a centralized analytics service for the Qubiko AI application. It currently supports Firebase Analytics and can be extended to support other analytics providers like PostHog, Mixpanel, etc. in the future.

## Features

- Centralized analytics service with a common interface
- Support for multiple analytics providers
- Debug logging for events and errors
- Automatic screen tracking
- TypeScript-style named parameters for all methods

## Usage

### Basic Event Tracking

```dart
import 'package:qubiko_ai/services/analytics/analytics.dart';

// Log a simple event
analytics.logEvent(name: 'button_clicked');

// Log an event with parameters
analytics.logEvent(
  name: 'item_selected',
  parameters: {
    'item_id': 'item123',
    'item_name': 'Cool Item',
    'price': 19.99,
  },
);
```

### User Properties

```dart
// Set a user property
analytics.setUserProperty(
  name: 'subscription_type',
  value: 'premium',
);

// Set user ID
analytics.setUserId('user_123456');
```

### Screen Tracking

Screen tracking is handled automatically by the `AnalyticsRouteObserver`, but you can also log screen views manually:

```dart
analytics.logScreenView(
  screenName: 'ProductDetail',
  screenClass: 'ProductDetailScreen',
);
```

### Authentication Events

```dart
// Log sign up
analytics.logSignUp(method: 'email');

// Log login
analytics.logLogin(method: 'google');
```

### Error Tracking

```dart
try {
  // Some code that might throw an error
} catch (e, stackTrace) {
  analytics.logError(
    message: 'Failed to load data',
    error: e,
    stackTrace: stackTrace,
  );
}
```

### Disabling Analytics

You can disable/enable analytics collection at runtime:

```dart
// Disable analytics
analytics.setAnalyticsCollectionEnabled(false);

// Enable analytics
analytics.setAnalyticsCollectionEnabled(true);
```

## Extending with New Providers

To add a new analytics provider:

1. Create a new class that implements `AnalyticsService`
2. Update the `AnalyticsManager.initialize()` method to register your provider

Example for adding a new provider:

```dart
// 1. Create a new provider class
class PostHogAnalyticsService implements AnalyticsService {
  // Implement all required methods...
}

// 2. Register the provider in AnalyticsManager
Future<void> initialize() async {
  if (_initialized) return;

  // Add existing Firebase Analytics provider
  await addProvider(FirebaseAnalyticsService());
  
  // Add new PostHog provider
  await addProvider(PostHogAnalyticsService());

  _initialized = true;
}
```

## Debug Logging

In debug mode, all analytics events and errors are logged to the console with emoji indicators:
- 📊 ANALYTICS: For regular events
- ❌ ANALYTICS ERROR: For errors 