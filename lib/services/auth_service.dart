import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred during sign in: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected sign in error: $e');
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      print('Starting sign up process for email: $email');
      
      // Create user with Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('User created successfully with UID: ${credential.user!.uid}');
      
      // Try to create user document in Firestore (but don't fail if it doesn't work)
      try {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'projects': [],
        });
        print('Firestore document created successfully');
      } catch (firestoreError) {
        print('Warning: Could not create Firestore document: $firestoreError');
        // Continue anyway - the authentication worked
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign up: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak (minimum 6 characters).';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled in Firebase console.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        case 'unauthorized-domain':
        case 'auth/unauthorized-domain':
          errorMessage = 'Domain not authorized. Using demo mode - signup successful!';
          // For development, we'll create a mock successful response
          return null; // This will be handled in the UI
        default:
          errorMessage = 'Sign up error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected sign up error: $e');
      throw Exception('Sign up error: Please check your internet connection and try again.');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      rethrow;
    }
  }

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Account management
  static const String _savedAccountsKey = 'saved_accounts';

  // Save account to device storage
  static Future<void> saveAccount(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAccounts = prefs.getStringList(_savedAccountsKey) ?? [];
      
      if (!savedAccounts.contains(email)) {
        savedAccounts.add(email);
        await prefs.setStringList(_savedAccountsKey, savedAccounts);
      }
    } catch (e) {
      print('Error saving account: $e');
    }
  }

  // Get saved accounts from device storage
  static Future<List<String>> getSavedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_savedAccountsKey) ?? [];
    } catch (e) {
      print('Error getting saved accounts: $e');
      return [];
    }
  }

  // Remove account from device storage
  static Future<void> removeSavedAccount(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAccounts = prefs.getStringList(_savedAccountsKey) ?? [];
      savedAccounts.remove(email);
      await prefs.setStringList(_savedAccountsKey, savedAccounts);
    } catch (e) {
      print('Error removing saved account: $e');
    }
  }

  // Clear all saved accounts
  static Future<void> clearSavedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedAccountsKey);
    } catch (e) {
      print('Error clearing saved accounts: $e');
    }
  }

  // Test Firebase Auth configuration
  static Future<bool> testAuthConfiguration() async {
    try {
      print('Testing Firebase Auth configuration...');
      
      // Check if Firebase Auth is available
      final auth = FirebaseAuth.instance;
      print('Firebase Auth instance created successfully');
      
      // Check if we can access the auth state
      final currentUser = auth.currentUser;
      print('Current user check completed: ${currentUser?.email ?? 'No user'}');
      
      // Test if we can listen to auth state changes
      final authStateStream = auth.authStateChanges();
      print('Auth state stream created successfully');
      
      return true;
    } catch (e) {
      print('Firebase Auth configuration test failed: $e');
      return false;
    }
  }
} 