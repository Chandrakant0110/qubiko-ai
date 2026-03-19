import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation.dart';
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

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
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
          routes: {
            '/': (context) => const SplashScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const MainNavigation(),
          },
        );
      },
    );
  }
}

// Note: The temporary HomeScreen has been moved to lib/screens/home_screen.dart
// and merged with the auth-aware HomeScreen implementation
