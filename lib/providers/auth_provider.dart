import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth/auth_service.dart';

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provide the initial authentication state - important for the splash screen
final initialAuthStateProvider = FutureProvider<AuthResult>((ref) async {
  final authService = ref.watch(authServiceProvider);

  // Get current user synchronously first
  final currentUser = authService.getCurrentUser();
  if (currentUser != null) {
    return AuthResult.authenticated(currentUser);
  }

  // If no current user, wait a moment for Firebase to fully initialize
  // and check persistence storage
  return await Future.delayed(const Duration(milliseconds: 500), () {
    final user = authService.getCurrentUser();
    if (user != null) {
      return AuthResult.authenticated(user);
    }
    return AuthResult.unauthenticated();
  });
});

// Auth state notifier
class AuthNotifier extends Notifier<AuthResult> {
  @override
  AuthResult build() {
    _initAuth();
    return AuthResult.loading();
  }

  void _initAuth() {
    final authService = ref.read(authServiceProvider);

    // First check if user is already logged in
    final currentUser = authService.getCurrentUser();
    if (currentUser != null) {
      state = AuthResult.authenticated(currentUser);
    }

    // Then listen to auth state changes
    authService.authStateChanges.listen((User? user) {
      if (user == null) {
        state = AuthResult.unauthenticated();
      } else {
        state = AuthResult.authenticated(UserModel.fromFirebase(user));
      }
    });
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = AuthResult.loading();
      final authService = ref.read(authServiceProvider);
      state = await authService.signInWithGoogle();
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = AuthResult.loading();
      final authService = ref.read(authServiceProvider);
      state = await authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      debugPrint('Error in signInWithEmailAndPassword: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      state = AuthResult.loading();
      final authService = ref.read(authServiceProvider);
      state = await authService.signUpWithEmailAndPassword(email, password);
    } catch (e) {
      debugPrint('Error in signUpWithEmailAndPassword: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      state = AuthResult.loading();
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = AuthResult.unauthenticated();
    } catch (e) {
      debugPrint('Error in signOut: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      final authService = ref.read(authServiceProvider);
      state = await authService.resetPassword(email);
    } catch (e) {
      debugPrint('Error in resetPassword: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    final authService = ref.read(authServiceProvider);
    return authService.getCurrentUser();
  }
}

// Provider for auth state
final authProvider = NotifierProvider<AuthNotifier, AuthResult>(
  AuthNotifier.new,
);
