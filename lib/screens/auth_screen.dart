import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../services/performance/performance.dart';
import '../providers/auth_provider.dart';
import '../services/auth/auth_service.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/auth/google_sign_in_button.dart';
import '../widgets/auth/apple_sign_in_button.dart';
import '../widgets/auth/facebook_sign_in_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    performance.trackNavigation('AuthScreen');
    performance.startTiming('AuthScreenViewDuration');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    performance.endTimingAndLog(
      'AuthScreenViewDuration',
      eventName: 'auth_screen_view',
    );
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _onLoginPressed() async {
    performance.trackButtonClick(
      'login_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'login'},
    );

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter email and password');
      return;
    }

    await ref.read(authProvider.notifier).signInWithEmailAndPassword(
        _emailController.text.trim(), _passwordController.text.trim());
  }

  void _onSignUpPressed() async {
    performance.trackButtonClick(
      'signup_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'signup'},
    );

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter email and password');
      return;
    }

    await ref.read(authProvider.notifier).signUpWithEmailAndPassword(
        _emailController.text.trim(), _passwordController.text.trim());
  }

  void _onGooglePressed() async {
    performance.trackButtonClick(
      'google_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'google_auth'},
    );

    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _onApplePressed() {
    performance.trackButtonClick(
      'apple_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'apple_auth'},
    );
    // TODO: Implement Apple auth
    _showErrorSnackBar('Apple Sign In not implemented yet');
  }

  void _onFacebookPressed() {
    performance.trackButtonClick(
      'facebook_button',
      screenName: 'AuthScreen',
      additionalParams: {'action': 'facebook_auth'},
    );
    // TODO: Implement Facebook auth
    _showErrorSnackBar('Facebook Sign In not implemented yet');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Handle authentication states
    if (authState.status == AuthStatus.error &&
        authState.errorMessage != null) {
      // Show error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(authState.errorMessage!);
      });
    } else if (authState.status == AuthStatus.authenticated) {
      // Navigate to home screen when authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    // Show loading indicator when in loading state
    if (authState.status == AuthStatus.loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.authBackgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.authBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Welcome text - using RichText to handle the emoji separately
                      _buildWelcomeText(),

                      const SizedBox(height: 40),

                      // Email field
                      _buildEmailField(),

                      const SizedBox(height: 16),

                      // Password field
                      _buildPasswordField(),

                      const SizedBox(height: 16),

                      // "Forgot Password?" text
                      if (_isLogin) _buildForgotPasswordButton(),

                      const SizedBox(height: 24),

                      // Login or Sign up button
                      AuthButton(
                        text: _isLogin ? 'Log in' : 'Sign up',
                        onPressed:
                            _isLogin ? _onLoginPressed : _onSignUpPressed,
                      ),

                      const SizedBox(height: 16),

                      // Toggle button
                      TextButton(
                        onPressed: _toggleAuthMode,
                        child: Text(
                          _isLogin
                              ? 'Don\'t have an account? Sign up'
                              : 'Already have an account? Log in',
                          style: TextStyle(
                            color: AppColors.primaryLightBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // "Or continue with" section
                      const SizedBox(height: 32),
                      _buildDividerWithText('or continue with'),

                      // Social login buttons
                      const SizedBox(height: 24),
                      _buildSocialButtons(),

                      const Spacer(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return RichText(
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
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      obscureText: true,
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => _buildResetPasswordDialog(),
          );
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.primaryLightBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordDialog() {
    final resetEmailController = TextEditingController();

    return AlertDialog(
      title: const Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'Enter your email address to receive a password reset link.'),
          const SizedBox(height: 16),
          TextFormField(
            controller: resetEmailController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (resetEmailController.text.isEmpty) {
              _showErrorSnackBar('Please enter your email address');
              return;
            }

            Navigator.of(context).pop();

            await ref.read(authProvider.notifier).resetPassword(
                  resetEmailController.text.trim(),
                );

            _showSuccessSnackBar('Password reset email sent');
          },
          child: const Text('Reset'),
        ),
      ],
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
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
            text,
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
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Google Sign In Button
        GoogleSignInButton(
          onPressed: _onGooglePressed,
          isLoading: ref.watch(authProvider).status == AuthStatus.loading,
        ),
        const SizedBox(height: 16),

        // Apple Sign In Button
        AppleSignInButton(
          onPressed: _onApplePressed,
        ),
        const SizedBox(height: 16),

        // Facebook Sign In Button
        FacebookSignInButton(
          onPressed: _onFacebookPressed,
        ),
      ],
    );
  }
}
