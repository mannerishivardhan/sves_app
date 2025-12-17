import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Repository for department operations
class DepartmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all departments
  Stream<List<DepartmentModel>> getDepartmentsStream() {
    return _firestore
        .collection(AppConstants.collectionDepartments)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DepartmentModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get active departments only
  Stream<List<DepartmentModel>> getActiveDepartmentsStream() {
    return _firestore
        .collection(AppConstants.collectionDepartments)
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DepartmentModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get department by ID
  Future<DepartmentModel?> getDepartmentById(String departmentId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionDepartments)
          .doc(departmentId)
          .get();

      if (!doc.exists) return null;
      return DepartmentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get department');
    }
  }

  /// Get department by ID as stream
  Stream<DepartmentModel?> getDepartmentStream(String departmentId) {
    return _firestore
        .collection(AppConstants.collectionDepartments)
        .doc(departmentId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return DepartmentModel.fromFirestore(doc);
        });
  }

  /// Create a new department
  Future<String> createDepartment({
    required String name,
    required String description,
  }) async {
    try {
      final departmentRef = _firestore
          .collection(AppConstants.collectionDepartments)
          .doc();

      final department = DepartmentModel(
        id: departmentRef.id,
        name: name,
        description: description,
        employeeCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await departmentRef.set(department.toFirestore());
      return departmentRef.id;
    } catch (e) {
      throw Exception('Failed to create department');
    }
  }

  /// Update department details
  Future<void> updateDepartment({
    required String departmentId,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{'updated_at': Timestamp.now()};

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (isActive != null) updates['is_active'] = isActive;

      await _firestore
          .collection(AppConstants.collectionDepartments)
          .doc(departmentId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update department');
    }
  }

  /// Assign department head
  Future<void> assignDepartmentHead({
    required String departmentId,
    required String headId,
    required String headName,
  }) async {
    try {
      // Use batch to update both department and user
      final batch = _firestore.batch();

      // Update department
      final deptRef = _firestore
          .collection(AppConstants.collectionDepartments)
          .doc(departmentId);
      batch.update(deptRef, {
        'head_id': headId,
        'head_name': headName,
        'updated_at': Timestamp.now(),
      });

      // Update user role to dept_head
      final userRef = _firestore
          .collection(AppConstants.collectionUsers)
          .doc(headId);
      batch.update(userRef, {
        'role': AppConstants.roleDeptHead,
        'updated_at': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to assign department head');
    }
  }

  /// Remove department head
  Future<void> removeDepartmentHead({
    required String departmentId,
    required String headId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update department
      final deptRef = _firestore
          .collection(AppConstants.collectionDepartments)
          .doc(departmentId);
      batch.update(deptRef, {
        'head_id': FieldValue.delete(),
        'head_name': FieldValue.delete(),
        'updated_at': Timestamp.now(),
      });

      // Update user role back to employee
      final userRef = _firestore
          .collection(AppConstants.collectionUsers)
          .doc(headId);
      batch.update(userRef, {
        'role': AppConstants.roleEmployee,
        'updated_at': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove department head');
    }
  }

  /// Delete department (soft delete)
  Future<void> deleteDepartment(String departmentId) async {
    try {
      await _firestore
          .collection(AppConstants.collectionDepartments)
          .doc(departmentId)
          .update({'is_active': false, 'updated_at': Timestamp.now()});
    } catch (e) {
      throw Exception('Failed to delete department');
    }
  }

  /// Update employee count
  Future<void> updateEmployeeCount(String departmentId, int delta) async {
    try {
      await _firestore
          .collection(AppConstants.collectionDepartments)
          .doc(departmentId)
          .update({
            'employee_count': FieldValue.increment(delta),
            'updated_at': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Failed to update employee count');
    }
  }

  /// Get departments with employee counts
  Future<List<DepartmentModel>> getDepartmentsWithCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionDepartments)
          .where('is_active', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => DepartmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get departments');
    }
  }

  /// Recalculate employee counts for all departments
  /// Call this to fix counts if they get out of sync
  Future<void> recalculateAllDepartmentCounts() async {
    try {
      // Get all departments
      final deptSnapshot = await _firestore
          .collection(AppConstants.collectionDepartments)
          .get();

      // For each department, count users and update
      for (final deptDoc in deptSnapshot.docs) {
        final deptId = deptDoc.id;

        // Count active users in this department
        final userSnapshot = await _firestore
            .collection(AppConstants.collectionUsers)
            .where('department_id', isEqualTo: deptId)
            .where('is_active', isEqualTo: true)
            .get();

        final count = userSnapshot.docs.length;

        // Find department head (if any)
        final headSnapshot = await _firestore
            .collection(AppConstants.collectionUsers)
            .where('department_id', isEqualTo: deptId)
            .where('role', isEqualTo: AppConstants.roleDeptHead)
            .where('is_active', isEqualTo: true)
            .limit(1)
            .get();

        // Prepare update data
        final updateData = <String, dynamic>{
          'employee_count': count,
          'updated_at': Timestamp.now(),
        };

        // Add or remove head info
        if (headSnapshot.docs.isNotEmpty) {
          final headDoc = headSnapshot.docs.first;
          final headData = headDoc.data();
          updateData['head_id'] = headDoc.id;
          updateData['head_name'] = headData['name'] ?? '';
        } else {
          // Remove head info if no head found
          updateData['head_id'] = FieldValue.delete();
          updateData['head_name'] = FieldValue.delete();
        }

        // Update the department
        await _firestore
            .collection(AppConstants.collectionDepartments)
            .doc(deptId)
            .update(updateData);

        print(
          'Updated $deptId: $count members, head: ${updateData['head_name'] ?? 'none'}',
        );
      }

      print('✅ All department counts and heads recalculated successfully');
    } catch (e) {
      print('❌ Error recalculating counts: $e');
      throw Exception('Failed to recalculate department counts');
    }
  }
}
