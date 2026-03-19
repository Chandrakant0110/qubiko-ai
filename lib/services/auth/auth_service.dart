import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthResult {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthResult({required this.status, this.user, this.errorMessage});

  factory AuthResult.authenticated(UserModel user) {
    return AuthResult(status: AuthStatus.authenticated, user: user);
  }

  factory AuthResult.unauthenticated() {
    return AuthResult(status: AuthStatus.unauthenticated);
  }

  factory AuthResult.loading() {
    return AuthResult(status: AuthStatus.loading);
  }

  factory AuthResult.error(String errorMessage) {
    return AuthResult(status: AuthStatus.error, errorMessage: errorMessage);
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the authentication state once immediately
  Future<User?> get currentUser async => _auth.currentUser;

  // Get current user synchronously
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint('Current user found: ${user.uid}, email: ${user.email}');
      return UserModel.fromFirebase(user);
    }
    debugPrint('No current user found');
    return null;
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In if needed
      await _googleSignIn.initialize();

      // Start the sign-in process using authenticate() instead of signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        // User cancelled the sign-in flow
        return AuthResult.unauthenticated();
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Get access token from authorization client for Firebase
      final authz = await googleUser.authorizationClient.authorizationForScopes(
        ['openid', 'email', 'profile'],
      );

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        return AuthResult.authenticated(UserModel.fromFirebase(user));
      } else {
        return AuthResult.error('Failed to sign in with Google');
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return AuthResult.error(e.toString());
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        return AuthResult.authenticated(UserModel.fromFirebase(user));
      } else {
        return AuthResult.error('Failed to sign in with email and password');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      debugPrint('Error signing in with email and password: $errorMessage');
      return AuthResult.error(errorMessage);
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      return AuthResult.error(e.toString());
    }
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        return AuthResult.authenticated(UserModel.fromFirebase(user));
      } else {
        return AuthResult.error(
          'Failed to create user with email and password',
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'The email address is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      debugPrint('Error signing up with email and password: $errorMessage');
      return AuthResult.error(errorMessage);
    } catch (e) {
      debugPrint('Error signing up with email and password: $e');
      return AuthResult.error(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut(); // Sign out from Firebase
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.unauthenticated();
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      return AuthResult.error(errorMessage);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
}
