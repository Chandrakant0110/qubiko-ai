import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_assets.dart';
import '../services/performance/performance.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    performance.trackNavigation('AuthScreen');
    performance.startTiming('AuthScreenViewDuration');
  }

  @override
  void dispose() {
    performance.endTimingAndLog(
      'AuthScreenViewDuration',
      eventName: 'auth_screen_view',
    );
    super.dispose();
  }

  void _onLoginPressed() {
    performance.trackButtonClick(
      'login_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'login'},
    );
    // TODO: Implement login functionality
  }

  void _onSignUpPressed() {
    performance.trackButtonClick(
      'signup_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'signup'},
    );
    // TODO: Implement signup functionality
  }

  void _onGooglePressed() {
    performance.trackButtonClick(
      'google_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'google_auth'},
    );
    // TODO: Implement Google auth
  }

  void _onApplePressed() {
    performance.trackButtonClick(
      'apple_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'apple_auth'},
    );
    // TODO: Implement Apple auth
  }

  void _onFacebookPressed() {
    performance.trackButtonClick(
      'facebook_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'facebook_auth'},
    );
    // TODO: Implement Facebook auth
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.authBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Welcome text - using RichText to handle the emoji separately
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: const Color(0xFF212121),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                          fontSize: 40,
                          height: 1.6,
                        ),
                    children: const [
                      TextSpan(text: 'Welcome to\n'),
                      TextSpan(text: 'Qubiko AI '),
                      TextSpan(
                        text: '👋',
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 4),

                // Login button - using custom gradient button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: AppColors.primaryButtonShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: _onLoginPressed,
                      child: Center(
                        child: Text(
                          'Log in',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                    fontFamily: 'Urbanist',
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sign up button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: _onSignUpPressed,
                      child: Center(
                        child: Text(
                          'Sign up',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryLightBlue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                    fontFamily: 'Urbanist',
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),

                // "Or continue with" section
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'or continue with',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF616161),
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              fontFamily: 'Urbanist',
                            ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                // Social login buttons
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      onPressed: _onGooglePressed,
                      iconPath: AppAssets.googleIcon,
                      iconSize: 26,
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      onPressed: _onApplePressed,
                      iconPath: AppAssets.appleIcon,
                      iconSize: 30,
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      onPressed: _onFacebookPressed,
                      iconPath: AppAssets.facebookIcon,
                      iconSize: 40,
                    ),
                  ],
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String iconPath,
    double width = 110,
    double height = 60,
    double iconSize = 32,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onPressed,
          child: Center(
            child: Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
