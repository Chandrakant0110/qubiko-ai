import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/walkthrough_screen.dart';
import 'constants/app_theme.dart';
import 'services/analytics/analytics.dart';
import 'services/performance/performance.dart';
import 'services/crashlytics/crashlytics.dart';

// Theme mode notifier to manage app-wide theme changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  // Start performance tracking
  performance.startAppInitialization();

  WidgetsFlutterBinding.ensureInitialized();
  performance.startTiming('Firebase Initialization');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  performance.endTimingAndLog('Firebase Initialization');

  performance.startTiming('Analytics Initialization');
  // Initialize Analytics
  await analytics.initialize();
  performance.endTimingAndLog('Analytics Initialization');

  // Initialize Firebase Crashlytics
  performance.startTiming('Crashlytics Initialization');
  await crashlytics.initialize();
  performance.endTimingAndLog('Crashlytics Initialization');

  // Mark app as initialized
  performance.markAppInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Qubiko AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          navigatorObservers: [
            // Track screen views automatically using our custom observer
            AnalyticsRouteObserver(),
          ],
          home: SplashScreen(
            nextScreen: const WalkthroughScreen(
              nextScreen: HomeScreen(),
            ),
          ),
        );
      },
    );
  }
}

// Temporary HomeScreen - will be replaced in future
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Log navigation to home screen
    performance.trackNavigation('HomeScreen',
        previousScreen: 'WalkthroughScreen');
    performance.startTiming('HomeScreenEngagement');

    // Show some custom colored logs as examples
    performance.logCustomEvent('Home screen loaded successfully',
        eventName: 'home_screen_loaded',
        color: PerformanceTracker.getColorByName('cyan'));
  }

  @override
  void dispose() {
    performance.endTimingAndLog(
      'HomeScreenEngagement',
      eventName: 'home_screen_session',
    );
    super.dispose();
  }

  int _counter = 0;

  void _incrementCounter() {
    // Log button click with performance tracker
    performance.trackButtonClick(
      'increment_button',
      screenName: 'HomeScreen',
      additionalParams: {'current_count': _counter + 1},
    );

    setState(() {
      _counter++;
    });

    // Track milestone achievements
    if (_counter == 5) {
      performance.trackButtonClick(
        'milestone_reached',
        screenName: 'HomeScreen',
        additionalParams: {
          'milestone': 'five_clicks',
          'time_elapsed': performance.endTiming('HomeScreenEngagement'),
        },
      );

      // Show a custom log with magenta color
      performance.logCustomEvent('🏆 Achievement unlocked: 5 clicks!',
          eventName: 'achievement_unlocked',
          parameters: {'achievement': 'five_clicks'},
          color: PerformanceTracker.getColorByName('magenta'));
    }

    if (_counter == 10) {
      performance.trackButtonClick(
        'milestone_reached',
        screenName: 'HomeScreen',
        additionalParams: {
          'milestone': 'ten_clicks',
          'time_elapsed': performance.endTiming('HomeScreenEngagement'),
        },
      );

      // Show a custom log with yellow color
      performance.logCustomEvent(
          '🏆 Achievement unlocked: 10 clicks! You\'re on fire!',
          eventName: 'achievement_unlocked',
          parameters: {'achievement': 'ten_clicks'},
          color: PerformanceTracker.getColorByName('yellow'));
    }
  }

  // Toggle the theme mode
  void _toggleTheme() {
    final currentTheme = themeNotifier.value;

    // Track theme change with performance tracker
    performance.trackButtonClick(
      'theme_toggle',
      screenName: 'HomeScreen',
      additionalParams: {
        'previous_theme': currentTheme.toString(),
        'new_theme': currentTheme == ThemeMode.light
            ? ThemeMode.dark.toString()
            : ThemeMode.light.toString(),
      },
    );

    // Switch between light and dark theme
    if (currentTheme == ThemeMode.dark) {
      themeNotifier.value = ThemeMode.light;
    } else {
      themeNotifier.value = ThemeMode.dark;
    }

    // Show a snackbar to confirm theme change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Theme changed to ${themeNotifier.value == ThemeMode.dark ? 'dark' : 'light'} mode'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Qubiko AI'),
        actions: [
          // Theme switcher button
          IconButton(
            icon: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, ThemeMode currentMode, __) {
                  return Icon(
                    currentMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  );
                }),
            onPressed: _toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              performance.trackButtonClick(
                'settings_button',
                screenName: 'HomeScreen',
              );
              // Show a snackbar to demonstrate the tracking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings clicked - Event tracked'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.error),
            onPressed: () {
              // Demonstrate error logging with red color
              performance.logError(
                'User triggered test error',
                'This is a test error message',
                StackTrace.current,
              );

              // Show a snackbar to demonstrate the tracking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error logged - Check console'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                performance.trackButtonClick(
                  'reset_counter',
                  screenName: 'HomeScreen',
                  additionalParams: {'previous_count': _counter},
                );
                setState(() {
                  _counter = 0;
                });
              },
              child: const Text('Reset Counter'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    performance.logCustomEvent('Custom green log message',
                        color: PerformanceTracker.getColorByName('green'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Green Log'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    performance.logCustomEvent('Custom blue log message',
                        color: PerformanceTracker.getColorByName('blue'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Blue Log'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    performance.logCustomEvent('Custom red log message',
                        color: PerformanceTracker.getColorByName('red'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Red Log'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // This will cause a crash that Crashlytics will report
                crashlytics.log('About to crash the app intentionally');
                // Force a crash
                throw Exception('This is a test crash!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Crash'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
