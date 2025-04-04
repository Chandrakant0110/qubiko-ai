# Performance Tracking and Beautiful Logs

This module provides a powerful performance tracking system with beautiful, emoji-enhanced, colored logs in debug mode to help monitor app performance and user interactions.

## Features

- 🚀 App startup and initialization tracking
- ⏱️ Operation timing with detailed metrics
- 🔄 Screen navigation tracking
- 👆 Button click and user interaction tracking
- 📊 Integration with Firebase Analytics
- 💾 Custom event tracking with rich parameters
- 🎨 **Colored console logs for better visibility**

## Beautiful Colored Debug Logs

In debug mode, the performance tracker outputs beautifully formatted logs with emoji indicators and colors for better visibility:

- **Magenta** - App initialization logs
- **Green** - Success messages and button clicks
- **Yellow** - Timing information
- **Blue** - Navigation events
- **Red** - Error messages
- **Cyan** - Started timing operations

Example output:
```
🚀 APP STARTING...                        (magenta, bold)
⏺️ STARTED TIMING: Firebase Initialization (cyan)
⏱️ Firebase Initialization TOOK: 245ms     (yellow)
⏱️ Analytics Initialization TOOK: 120ms    (yellow)
✅ APP INITIALIZED                         (green, bold)
⏱️ COLD START TOOK: 876ms                  (yellow)
🔄 NAVIGATED TO: SplashScreen              (blue)
⏱️ SplashScreenDuration TOOK: 3001ms       (yellow)
🔄 NAVIGATED TO: WalkthroughScreen         (blue)
👆 BUTTON CLICKED: next_button on WalkthroughScreen (green)
🔄 NAVIGATED TO: OnboardingPage2 from OnboardingPage1 (blue)
👆 BUTTON CLICKED: skip_button on WalkthroughScreen (green)
🔄 NAVIGATED TO: HomeScreen from WalkthroughScreen (blue)
👆 BUTTON CLICKED: increment_button on HomeScreen (green)
❌ ERROR: Failed to load resource            (red, bold)
```

## Usage Examples

### Tracking App Startup

```dart
// In main.dart
performance.startAppInitialization();
WidgetsFlutterBinding.ensureInitialized();

// After initializations
performance.markAppInitialized();
```

### Timing Operations

```dart
// Start timing an operation
performance.startTiming('DatabaseOperation');

// Perform the operation
await loadDataFromDatabase();

// End timing and log the result
performance.endTimingAndLog(
  'DatabaseOperation',
  eventName: 'database_load_complete',
  additionalParams: {'record_count': recordCount},
);
```

### Tracking Navigation

```dart
// In screen or page initState()
performance.trackNavigation(
  'ProductDetailsScreen', 
  previousScreen: 'ProductListScreen',
);
```

### Tracking Button Clicks

```dart
// For button click handlers
onPressed: () {
  performance.trackButtonClick(
    'purchase_button',
    screenName: 'ProductScreen',
    additionalParams: {
      'product_id': product.id,
      'price': product.price,
    },
  );
  
  // Rest of the button logic
  processTransaction();
}
```

### Logging Errors

```dart
try {
  // Some operation that might fail
} catch (e, stackTrace) {
  performance.logError(
    'Failed to complete operation', 
    e, 
    stackTrace
  );
}
```

### Custom Colored Logs

```dart
// Log with a specific color
performance.logCustomEvent(
  'Important business logic executed',
  eventName: 'business_logic_executed',
  parameters: {'result': 'success'},
  color: PerformanceTracker.getColorByName('magenta')
);
```

## Integration with Analytics

All events tracked with the performance tracker are automatically sent to Firebase Analytics (and any other analytics providers you've configured) via the centralized analytics service.

In production, the console logs won't appear, but the analytics events will still be recorded and sent to your analytics services.

## Extending with Custom Events

You can add custom tracking methods as needed by extending the `PerformanceTracker` class or by using the existing methods with custom event names and parameters. 