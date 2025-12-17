import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Repository for authentication operations
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📧 REPO: Starting Firebase Auth sign in...');
      debugPrint('📧 REPO: Email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('📧 REPO: Firebase Auth successful');
      debugPrint('📧 REPO: User UID: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        debugPrint('❌ REPO: User credential is null!');
        throw Exception('Login failed');
      }

      debugPrint('📧 REPO: Fetching user data from Firestore...');

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userCredential.user!.uid)
          .get();

      debugPrint('📧 REPO: Firestore query complete');
      debugPrint('📧 REPO: Document exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        debugPrint('❌ REPO: User document not found in Firestore!');
        throw Exception('User data not found');
      }

      debugPrint('📧 REPO: Creating UserModel from Firestore data...');
      final user = UserModel.fromFirestore(userDoc);

      debugPrint('📧 REPO: UserModel created successfully');
      debugPrint('📧 REPO: User email: ${user.email}, role: ${user.role}');

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ REPO: Firebase Auth Exception');
      debugPrint('❌ REPO: Code: ${e.code}');
      debugPrint('❌ REPO: Message: ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      debugPrint('❌ REPO: General Exception: $e');
      debugPrint('❌ REPO: Stack: $stackTrace');
      throw Exception('An error occurred during login: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out');
    }
  }

  /// Check if any users exist in the system (for onboarding)
  Future<bool> checkIfUsersExist() async {
    try {
      debugPrint('🔍 Checking if users exist in Firestore...');
      final snapshot = await _firestore
          .collection(AppConstants.collectionUsers)
          .limit(1)
          .get();

      final exists = snapshot.docs.isNotEmpty;
      debugPrint(
        '👥 Users exist: $exists (found ${snapshot.docs.length} users)',
      );
      return exists;
    } catch (e) {
      debugPrint('❌ Error checking users: $e');
      // On error, assume users exist to avoid showing onboarding
      return true;
    }
  }

  /// Get current user profile from Firestore
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  /// Stream of current user profile
  Stream<UserModel?> get currentUserProfileStream {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection(AppConstants.collectionUsers)
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserModel.fromFirestore(doc);
        });
  }

  /// Create a new user (Super Admin only - or during onboarding)
  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String employeeId,
    required String role,
    String? departmentId,
  }) async {
    UserCredential? userCredential;

    try {
      debugPrint('🔵 Creating Firebase Auth user...');

      // Create Firebase Auth user
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create authentication user');
      }

      debugPrint('✅ Firebase Auth user created: ${userCredential.user!.uid}');

      // Wait a moment for Firebase Auth to fully initialize the user
      await Future.delayed(const Duration(milliseconds: 500));

      // For onboarding (first user), we're now authenticated as the new user
      // For subsequent users, the current Super Admin is authenticated

      debugPrint('🔵 Writing to Firestore...');

      try {
        // Create user document in Firestore
        final userData = {
          'employee_id': employeeId,
          'email': email,
          'name': name,
          'phone': phone,
          'role': role,
          'department_id': departmentId,
          'is_active': true,
          'profile_image_url': null,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(userCredential.user!.uid)
            .set(userData);

        debugPrint('✅ Firestore document created successfully');
      } catch (firestoreError) {
        debugPrint('❌ Firestore write error: $firestoreError');
        // If Firestore fails, delete the auth user to keep things consistent
        try {
          await userCredential.user?.delete();
          debugPrint('🗑️ Cleaned up auth user due to Firestore error');
        } catch (e) {
          debugPrint('⚠️ Could not clean up auth user: $e');
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      debugPrint('❌ Firestore Error: ${e.code} - ${e.message}');
      debugPrint('Plugin: ${e.plugin}');
      throw Exception('Firestore error: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint('❌ Unknown error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{'updated_at': Timestamp.now()};

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null)
        updates['profile_image_url'] = profileImageUrl;

      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
