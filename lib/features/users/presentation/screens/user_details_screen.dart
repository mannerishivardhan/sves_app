import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../departments/presentation/providers/department_provider.dart';
import '../providers/user_provider.dart';
import 'user_form_screen.dart';

/// Read-only user details screen showing full bio and stats
class UserDetailsScreen extends ConsumerWidget {
  final UserModel user;

  /// When true, shows edit and delete buttons. When false, view-only mode.
  final bool allowManagement;

  const UserDetailsScreen({
    super.key,
    required this.user,
    this.allowManagement = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch department name if user has department
    String departmentName = 'Not Assigned';
    if (user.departmentId != null) {
      final deptAsync = ref.watch(departmentStreamProvider(user.departmentId!));
      departmentName = deptAsync.when(
        data: (dept) => dept?.name ?? 'Unknown',
        loading: () => 'Loading...',
        error: (_, __) => 'Unknown',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: allowManagement
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit User',
                  onPressed: () async {
                    // Navigate to edit and wait for result
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserFormScreen(userId: user.id, user: user),
                      ),
                    );
                    // Pop back to users list so the data refreshes
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  tooltip: 'Delete User',
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete User'),
                        content: Text(
                          'Are you sure you want to permanently delete "${user.name}"?\n\nThis action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Delete Permanently'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      try {
                        await ref
                            .read(userControllerProvider.notifier)
                            .deleteUser(user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User deleted permanently'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Personal Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.person, 'Personal Information'),
                    const SizedBox(height: 16),
                    _buildInfoRow('Employee ID', user.employeeId),
                    const Divider(),
                    _buildInfoRow('Full Name', user.name),
                    const Divider(),
                    _buildInfoRow('Email', user.email),
                    const Divider(),
                    _buildInfoRow('Phone', user.phone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Work Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.work, 'Work Information'),
                    const SizedBox(height: 16),
                    _buildInfoRow('Role', _formatRole(user.role)),
                    const Divider(),
                    _buildInfoRow('Department', departmentName),
                    const Divider(),
                    _buildStatusRow('Status', user.isActive),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.analytics, 'Statistics'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Leave Balance',
                            '12', // TODO: Add leaveBalance to UserModel when implementing leave feature
                            Icons.event_available,
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pending Leaves',
                            '0',
                            Icons.pending_actions,
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Approved Leaves',
                            '0',
                            Icons.check_circle,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Rejected Leaves',
                            '0',
                            Icons.cancel,
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.info, 'Account Information'),
                    const SizedBox(height: 16),
                    _buildInfoRow('Member Since', _formatDate(user.createdAt)),
                    const Divider(),
                    _buildInfoRow('Last Updated', _formatDate(user.updatedAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _getRoleColor(user.role),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Name
        Text(user.name, style: AppTextStyles.h2, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        // Employee ID
        Text(
          user.employeeId,
          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getRoleColor(user.role).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getRoleColor(user.role).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _formatRole(user.role),
            style: TextStyle(
              color: _getRoleColor(user.role),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Status Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: (user.isActive ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                user.isActive ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: user.isActive ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                user.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: user.isActive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isActive ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: isActive ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return 'Super Admin';
      case AppConstants.roleDeptHead:
        return 'Department Head';
      case AppConstants.roleEmployee:
        return 'Employee';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return AppColors.error;
      case AppConstants.roleDeptHead:
        return AppColors.primary;
      case AppConstants.roleEmployee:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
