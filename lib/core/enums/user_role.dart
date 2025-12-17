/// User roles in the system
enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  deptHead('dept_head', 'Department Head'),
  employee('employee', 'Employee');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Get role from string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.employee,
    );
  }

  /// Check if role is Super Admin
  bool get isSuperAdmin => this == UserRole.superAdmin;

  /// Check if role is Department Head
  bool get isDeptHead => this == UserRole.deptHead;

  /// Check if role is Employee
  bool get isEmployee => this == UserRole.employee;

  /// Check if role can manage users
  bool get canManageUsers => isSuperAdmin || isDeptHead;

  /// Check if role can manage departments
  bool get canManageDepartments => isSuperAdmin;

  /// Check if role can approve leaves
  bool get canApproveLeaves => isSuperAdmin || isDeptHead;
}
