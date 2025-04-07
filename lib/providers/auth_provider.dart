import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth/auth_service.dart';

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthResult> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthResult.loading()) {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((User? user) {
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
      state = await _authService.signInWithGoogle();
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = AuthResult.loading();
      state = await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      debugPrint('Error in signInWithEmailAndPassword: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      state = AuthResult.loading();
      state = await _authService.signUpWithEmailAndPassword(email, password);
    } catch (e) {
      debugPrint('Error in signUpWithEmailAndPassword: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = AuthResult.unauthenticated();
    } catch (e) {
      debugPrint('Error in signOut: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      state = await _authService.resetPassword(email);
    } catch (e) {
      debugPrint('Error in resetPassword: $e');
      state = AuthResult.error(e.toString());
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    return _authService.getCurrentUser();
  }
}

// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthResult>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
}); 