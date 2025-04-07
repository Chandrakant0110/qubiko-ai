import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/performance/performance.dart';
import '../providers/auth_provider.dart';
import '../services/auth/auth_service.dart';
import 'walkthrough_screen.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    performance.trackNavigation('SplashScreen');
    performance.startTiming('SplashScreenDuration');

    // Make sure splash screen shows for a minimum duration
    _splashTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
      });
      _checkAuthAndNavigate();
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;

    // Get the initial auth state using the future provider
    final initialAuthState = ref.read(initialAuthStateProvider);

    initialAuthState.when(
      data: (authResult) {
        // Authentication state has been determined
        performance.endTimingAndLog(
          'SplashScreenDuration',
          eventName: 'splash_screen_complete',
        );

        if (authResult.status == AuthStatus.authenticated) {
          // User is authenticated, go to home screen
          performance.logCustomEvent(
            'User authenticated, going to home screen',
            eventName: 'auth_success',
          );
          _navigateToScreen(const HomeScreen(), 'HomeScreen');
        } else {
          // User is not authenticated, go to walkthrough/auth
          performance.logCustomEvent(
            'User not authenticated, showing walkthrough',
            eventName: 'auth_required',
          );
          _navigateToScreen(
            WalkthroughScreen(
              nextScreen: const AuthScreen(),
            ),
            'WalkthroughScreen',
          );
        }
      },
      loading: () {
        // Still loading, don't navigate yet
        performance.logCustomEvent(
          'Auth state is still loading',
          eventName: 'auth_loading',
        );
      },
      error: (error, stack) {
        // Error occurred, navigate to auth screen to be safe
        performance.logError(
          'Error checking auth state',
          error.toString(),
          stack,
        );
        _navigateToScreen(
          WalkthroughScreen(
            nextScreen: const AuthScreen(),
          ),
          'WalkthroughScreen',
        );
      },
    );
  }

  void _navigateToScreen(Widget screen, String routeName) {
    // Prevent multiple navigations
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => screen,
        settings: RouteSettings(name: routeName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the auth state to show loading indicator
    final initialAuthState = ref.watch(initialAuthStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with shadow and gradient
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(19, 26, 45, 0.1),
                      blurRadius: 12,
                      offset: Offset(13, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Q',
                    style: TextStyle(
                      fontFamily: GoogleFonts.urbanist().fontFamily,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = AppColors.primaryGradient.createShader(
                          const Rect.fromLTWH(0.0, 0.0, 60, 60),
                        ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App name
              Text(
                'Qubiko AI',
                style: GoogleFonts.urbanist(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              // Show a loading indicator if we're still determining auth state
              if (initialAuthState is AsyncLoading) ...[
                const SizedBox(height: 40),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
