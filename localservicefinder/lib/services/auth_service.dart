import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

enum UserRole { user, admin }

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static bool get isLoggedIn {
    try {
      return _auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  static String? get currentUser {
    try {
      return _auth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  static String? get currentUserId {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  // Get user role from Firestore
  static Future<UserRole> getUserRole() async {
    try {
      final userId = currentUserId;
      if (userId == null || _db == null) return UserRole.user;

      final userDoc = await _db!.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        // Default to user role if document doesn't exist
        return UserRole.user;
      }
      
      final role = userDoc.data()?['role'] as String?;
      return role == 'admin' ? UserRole.admin : UserRole.user;
    } catch (_) {
      return UserRole.user;
    }
  }

  // Check if current user is admin
  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == UserRole.admin;
  }

  static Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Check if this user should be admin and set role accordingly
      await _checkAndSetAdminRole(email.trim());
      
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Check if user email is in admin list and set role
  static Future<void> _checkAndSetAdminRole(String email) async {
    const adminEmails = ['ohi82@gmail.com'];
    if (adminEmails.contains(email.toLowerCase())) {
      final userId = currentUserId;
      if (userId != null && _db != null) {
        try {
          // Ensure user document exists
          final userDoc = await _db!.collection('users').doc(userId).get();
          if (userDoc.exists) {
            await setUserRole(userId, UserRole.admin);
          } else {
            // Create user document with admin role
            await _db!.collection('users').doc(userId).set({
              'email': email.toLowerCase(),
              'role': 'admin',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (_) {
          // Ignore errors
        }
      }
    }
  }

  static Future<bool> signup(String email, String password, String firstName, String lastName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update display name
      if (userCredential.user != null) {
        try {
          await userCredential.user!.updateDisplayName('$firstName $lastName');
        } catch (_) {
          // Ignore display name update errors
        }

        // Create user document in Firestore with appropriate role
        if (_db != null) {
          try {
            // Check if this email should be admin
            const adminEmails = ['ohi82@gmail.com'];
            final isAdminEmail = adminEmails.contains(email.trim().toLowerCase());
            
            await _db!.collection('users').doc(userCredential.user!.uid).set({
              'email': email.trim().toLowerCase(),
              'firstName': firstName,
              'lastName': lastName,
              'role': isAdminEmail ? 'admin' : 'user',
              'createdAt': FieldValue.serverTimestamp(),
            });
          } catch (_) {
            // Ignore Firestore errors during signup
          }
        }
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message ?? e.code}';
    }
  }

  // Set user role (admin only function)
  static Future<void> setUserRole(String userId, UserRole role) async {
    if (_db == null) return;
    try {
      await _db!.collection('users').doc(userId).update({
        'role': role == UserRole.admin ? 'admin' : 'user',
      });
    } catch (_) {
      // Ignore errors
    }
  }

  // Set user role by email (utility function for initial admin setup)
  static Future<void> setUserRoleByEmail(String email, UserRole role) async {
    if (_db == null) return;
    try {
      // Find user by email in Firestore
      final querySnapshot = await _db!
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userId = querySnapshot.docs.first.id;
        await setUserRole(userId, role);
      } else {
        // If user doesn't exist in Firestore, try to find by Firebase Auth
        try {
          // Note: Firebase Auth doesn't provide a direct way to get user by email
          // So we'll need to create/update the user document when they sign in
          // For now, we'll just log that the user wasn't found
          debugPrint('User with email $email not found in Firestore');
        } catch (_) {
          // Ignore errors
        }
      }
    } catch (e) {
      debugPrint('Error setting user role by email: $e');
    }
  }

  // Initialize admin users (call this during app startup)
  static Future<void> initializeAdminUsers() async {
    if (_db == null) return;
    
    // List of admin emails to set as admin
    const adminEmails = ['ohi82@gmail.com'];
    
    for (final email in adminEmails) {
      await setUserRoleByEmail(email, UserRole.admin);
    }
  }
}
