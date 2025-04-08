import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/performance/performance.dart';
import '../services/analytics/performance_tracker.dart'; // Correct import for PerformanceTracker
import '../main.dart'
    show themeNotifier; // Import the theme notifier from main.dart

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    performance.trackNavigation('HomeScreen');
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

  void _signOut() async {
    performance.trackButtonClick(
      'signout_button',
      screenName: 'HomeScreen',
    );

    try {
      await ref.read(authProvider.notifier).signOut();

      // Explicitly navigate to auth screen after successful sign-out
      if (mounted) {
        performance.logCustomEvent(
          'User signed out successfully, redirecting to auth screen',
          eventName: 'sign_out_success',
        );

        // Navigate to auth screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false, // Remove all previous routes from the stack
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

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
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
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
          // Settings button
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
            tooltip: 'Settings',
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.photoURL != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user!.photoURL!),
                ),
              ),
            Text(
              'Welcome, ${user?.displayName ?? user?.email ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You are now signed in',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Counter section from main.dart's HomeScreen
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Increment'),
                ),
                const SizedBox(width: 16),
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
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Sign out button
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
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
