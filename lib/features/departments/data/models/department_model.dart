import 'package:cloud_firestore/cloud_firestore.dart';

/// Department model representing a department in the organization
class DepartmentModel {
  final String id;
  final String name;
  final String description;
  final String? headId;
  final String? headName;
  final int employeeCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    this.headId,
    this.headName,
    required this.employeeCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create DepartmentModel from Firestore document
  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      headId: data['head_id'],
      headName: data['head_name'],
      employeeCount: data['employee_count'] ?? 0,
      isActive: data['is_active'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert DepartmentModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'head_id': headId,
      'head_name': headName,
      'employee_count': employeeCount,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with modified fields
  DepartmentModel copyWith({
    String? id,
    String? name,
    String? description,
    String? headId,
    String? headName,
    int? employeeCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      headId: headId ?? this.headId,
      headName: headName ?? this.headName,
      employeeCount: employeeCount ?? this.employeeCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if department has a head assigned
  bool get hasHead => headId != null && headId!.isNotEmpty;
}
