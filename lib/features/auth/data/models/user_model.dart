import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a user in the system
class UserModel {
  final String id;
  final String employeeId;
  final String email;
  final String name;
  final String phone;
  final String role; // super_admin, dept_head, employee
  final String? departmentId;
  final bool isActive;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.employeeId,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.departmentId,
    required this.isActive,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      employeeId: data['employee_id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'employee',
      departmentId: data['department_id'],
      isActive: data['is_active'] ?? true,
      profileImageUrl: data['profile_image_url'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'employee_id': employeeId,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'department_id': departmentId,
      'is_active': isActive,
      'profile_image_url': profileImageUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? employeeId,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? departmentId,
    bool? isActive,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is super admin
  bool get isSuperAdmin => role == 'super_admin';

  /// Check if user is department head
  bool get isDeptHead => role == 'dept_head';

  /// Check if user is employee
  bool get isEmployee => role == 'employee';
}
