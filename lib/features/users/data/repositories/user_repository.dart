import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../departments/data/repositories/department_repository.dart';

/// Repository for user management operations
class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get secondary Firebase app for user creation (doesn't affect main session)
  Future<FirebaseAuth> _getSecondaryAuth() async {
    try {
      // Check if secondary app already exists
      final existingApp = Firebase.app('userCreation');
      return FirebaseAuth.instanceFor(app: existingApp);
    } catch (_) {
      // Create secondary app if it doesn't exist
      final secondaryApp = await Firebase.initializeApp(
        name: 'userCreation',
        options: Firebase.app().options,
      );
      return FirebaseAuth.instanceFor(app: secondaryApp);
    }
  }

  /// Get all users
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
          // Debug logging
          print('📋 UsersStream: Loaded ${users.length} users');
          for (var user in users) {
            print('   - ${user.name} (${user.email})');
          }
          return users;
        });
  }

  /// Get users by department
  Stream<List<UserModel>> getUsersByDepartmentStream(String departmentId) {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .where('department_id', isEqualTo: departmentId)
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get users by both department and role
  Stream<List<UserModel>> getUsersByDepartmentAndRoleStream(
    String departmentId,
    String role,
  ) {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .where('department_id', isEqualTo: departmentId)
        .where('role', isEqualTo: role)
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get users by role
  Stream<List<UserModel>> getUsersByRoleStream(String role) {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .where('role', isEqualTo: role)
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user');
    }
  }

  /// Create a new user (Super Admin only)
  Future<String> createUser({
    required String employeeId,
    required String email,
    required String name,
    required String phone,
    required String role,
    String? departmentId,
    String password = 'Password@123', // Default password
  }) async {
    try {
      // Check if employee ID already exists
      final existingByEmployeeId = await _firestore
          .collection(AppConstants.collectionUsers)
          .where('employee_id', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (existingByEmployeeId.docs.isNotEmpty) {
        throw Exception('Employee ID already exists');
      }

      // Use secondary Firebase app for user creation
      // This prevents the admin from being signed out
      final secondaryAuth = await _getSecondaryAuth();

      // Create Firebase Auth user using secondary auth instance
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Create Firestore user document
      final user = UserModel(
        id: userId,
        employeeId: employeeId,
        email: email,
        name: name,
        phone: phone,
        role: role,
        departmentId: departmentId,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .set(user.toFirestore());

      // Update department employee count if assigned to a department
      if (departmentId != null) {
        final deptRepo = DepartmentRepository();
        await deptRepo.updateEmployeeCount(departmentId, 1);
      }

      // Sign out from secondary auth (doesn't affect main admin session)
      await secondaryAuth.signOut();

      return userId;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email already in use');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'weak-password':
          throw Exception('Password is too weak');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        default:
          throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      // Handle other errors (including those from secondary auth)
      final errorMessage = e.toString();
      if (errorMessage.contains('email-already-in-use')) {
        throw Exception('Email already in use by another account');
      } else if (errorMessage.contains('network')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      }
      throw Exception('Failed to create user: $errorMessage');
    }
  }

  /// Update user details
  Future<void> updateUser({
    required String userId,
    String? name,
    String? phone,
    String? role,
    String? departmentId,
    bool? isActive,
  }) async {
    try {
      // Get current user data for department tracking
      final currentUser = await getUserById(userId);
      if (currentUser == null) throw Exception('User not found');

      final updates = <String, dynamic>{'updated_at': Timestamp.now()};

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (role != null) updates['role'] = role;
      if (departmentId != null) updates['department_id'] = departmentId;
      if (isActive != null) updates['is_active'] = isActive;

      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update(updates);

      // Update department employee counts if department changed
      if (departmentId != null && currentUser.departmentId != departmentId) {
        final deptRepo = DepartmentRepository();

        // Decrease count from old department
        if (currentUser.departmentId != null) {
          await deptRepo.updateEmployeeCount(currentUser.departmentId!, -1);
        }

        // Increase count in new department
        await deptRepo.updateEmployeeCount(departmentId, 1);
      }
    } catch (e) {
      throw Exception('Failed to update user');
    }
  }

  /// Deactivate user
  Future<void> deactivateUser(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) throw Exception('User not found');

      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update({'is_active': false, 'updated_at': Timestamp.now()});

      // Update department employee count
      if (user.departmentId != null) {
        final deptRepo = DepartmentRepository();
        await deptRepo.updateEmployeeCount(user.departmentId!, -1);
      }
    } catch (e) {
      throw Exception('Failed to deactivate user');
    }
  }

  /// Activate user
  Future<void> activateUser(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) throw Exception('User not found');

      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .update({'is_active': true, 'updated_at': Timestamp.now()});

      // Update department employee count
      if (user.departmentId != null) {
        final deptRepo = DepartmentRepository();
        await deptRepo.updateEmployeeCount(user.departmentId!, 1);
      }
    } catch (e) {
      throw Exception('Failed to activate user');
    }
  }

  /// Permanently delete user
  Future<void> deleteUser(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) throw Exception('User not found');

      // Update department employee count before deletion
      if (user.departmentId != null) {
        final deptRepo = DepartmentRepository();
        await deptRepo.updateEmployeeCount(user.departmentId!, -1);
      }

      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user');
    }
  }

  /// Transfer user to different department
  Future<void> transferUser({
    required String userId,
    required String newDepartmentId,
  }) async {
    try {
      final user = await getUserById(userId);
      if (user == null) throw Exception('User not found');

      await updateUser(userId: userId, departmentId: newDepartmentId);
    } catch (e) {
      throw Exception('Failed to transfer user');
    }
  }

  /// Get employees available to be assigned as department head
  Future<List<UserModel>> getAvailableDepartmentHeads(
    String departmentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionUsers)
          .where('department_id', isEqualTo: departmentId)
          .where('is_active', isEqualTo: true)
          .where(
            'role',
            whereIn: [AppConstants.roleEmployee, AppConstants.roleDeptHead],
          )
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get available heads');
    }
  }

  /// Reset user password (Admin function)
  Future<void> resetUserPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email');
      }
      throw Exception('Failed to send password reset email');
    } catch (e) {
      throw Exception('Failed to reset password');
    }
  }
}
