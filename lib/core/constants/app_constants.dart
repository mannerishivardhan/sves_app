/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SVES Leave Management';
  static const String appVersion = '1.0.0';

  // Leave Quotas (Annual)
  static const int sickLeaveYearly = 12;
  static const int paidLeaveYearly = 20;

  // Monthly Limits
  static const int sickLeaveMonthly = 2;
  static const int paidLeaveMonthly = 3;
  static const int unpaidLeaveMonthly = 2;

  // Carry Forward
  static const bool carryForwardEnabled = true;
  static const int maxCarryForwardDays = 5;

  // Leave Types
  static const String leaveTypeSick = 'sick';
  static const String leaveTypePaid = 'paid';
  static const String leaveTypeUnpaid = 'unpaid';

  // User Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleDeptHead = 'dept_head';
  static const String roleEmployee = 'employee';

  // Leave Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Duration Types
  static const String durationFullDay = 'full_day';
  static const String durationHalfDay = 'half_day';

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxImageSize = 500 * 1024; // 500KB

  // Routes (will be updated as we build screens)
  static const String routeLogin = '/login';
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeSuperAdminDashboard = '/super-admin';
  static const String routeDeptHeadDashboard = '/dept-head';
  static const String routeEmployeeDashboard = '/employee';
  static const String routeDepartments = '/departments';
  static const String routeUsers = '/users';
  static const String routeApplyLeave = '/apply-leave';
  static const String routeMyLeaves = '/my-leaves';
  static const String routeLeaveRequests = '/leave-requests';
  static const String routeProfile = '/profile';

  // Firestore Collections
  static const String collectionUsers = 'users';
  static const String collectionDepartments = 'departments';
  static const String collectionLeaveApplications = 'leave_applications';
  static const String collectionLeaveBalances = 'leave_balances';
  static const String collectionNotifications = 'notifications';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorPermission =
      'You do not have permission to perform this action.';

  // Success Messages
  static const String successLeaveApplied =
      'Leave application submitted successfully';
  static const String successLeaveApproved = 'Leave approved successfully';
  static const String successLeaveRejected = 'Leave rejected';
  static const String successUserCreated = 'User created successfully';
  static const String successDepartmentCreated =
      'Department created successfully';
}
