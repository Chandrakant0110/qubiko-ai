import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/performance/performance.dart';

class SplashScreen extends StatefulWidget {
  final Widget? nextScreen;

  const SplashScreen({
    super.key,
    this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    performance.trackNavigation('SplashScreen');
    performance.startTiming('SplashScreenDuration');

    // Navigate to the next screen after a delay
    if (widget.nextScreen != null) {
      Timer(const Duration(seconds: 3), () {
        performance.endTimingAndLog(
          'SplashScreenDuration',
          eventName: 'splash_screen_complete',
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => widget.nextScreen!,
            settings: const RouteSettings(name: 'WalkthroughScreen'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
        ),
      ),
    );
  }
}
