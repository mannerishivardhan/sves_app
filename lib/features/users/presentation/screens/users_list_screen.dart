import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/user_provider.dart';
import '../../../auth/data/models/user_model.dart';
import 'user_form_screen.dart';
import 'user_details_screen.dart';

/// Users list screen for Super Admin
class UsersListScreen extends ConsumerStatefulWidget {
  final String? filterByDepartment;
  final String? filterByRole;
  final String? title;

  /// When true, allows add/edit/delete operations. When false, view-only mode.
  final bool allowManagement;

  const UsersListScreen({
    super.key,
    this.filterByDepartment,
    this.filterByRole,
    this.title,
    this.allowManagement = false,
  });

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Initialize filter based on widget parameters
    _selectedFilter = widget.filterByRole ?? 'all';
  }

  @override
  Widget build(BuildContext context) {
    // Use appropriate filtered stream based on parameters
    final AsyncValue<List<UserModel>> usersStream;

    if (widget.filterByDepartment != null && widget.filterByRole != null) {
      // Filter by both department AND role
      usersStream = ref.watch(
        usersByDepartmentAndRoleStreamProvider(
          widget.filterByDepartment!,
          widget.filterByRole!,
        ),
      );
    } else if (widget.filterByDepartment != null) {
      // Filter by department only
      usersStream = ref.watch(
        usersByDepartmentStreamProvider(widget.filterByDepartment!),
      );
    } else if (_selectedFilter == 'all') {
      usersStream = ref.watch(usersStreamProvider);
    } else {
      usersStream = ref.watch(
        usersByRoleStreamProvider(
          _selectedFilter == 'dept_head'
              ? AppConstants.roleDeptHead
              : AppConstants.roleEmployee,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs (only show when not in filtered mode)
          if (widget.filterByDepartment == null && widget.filterByRole == null)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Users', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dept Heads', 'dept_head'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Employees', 'employee'),
                  ],
                ),
              ),
            ),

          // Users list
          Expanded(
            child: usersStream.when(
              data: (users) {
                if (users.isEmpty) {
                  return widget.allowManagement
                      ? EmptyState(
                          message: 'No users yet',
                          subtitle: 'Create your first user to get started',
                          icon: Icons.people_outlined,
                          actionLabel: 'Add User',
                          onActionPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserFormScreen(),
                              ),
                            );
                          },
                        )
                      : const EmptyState(
                          message: 'No users yet',
                          subtitle:
                              'Users will appear here once they are added',
                          icon: Icons.people_outlined,
                        );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(usersStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _UserCard(
                        user: user,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailsScreen(
                                user: user,
                                allowManagement: widget.allowManagement,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading users', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(usersStreamProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.allowManagement
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  Color _getRoleColor() {
    switch (user.role) {
      case AppConstants.roleSuperAdmin:
        return AppColors.error;
      case AppConstants.roleDeptHead:
        return AppColors.primary;
      case AppConstants.roleEmployee:
      default:
        return AppColors.success;
    }
  }

  String _getRoleLabel() {
    switch (user.role) {
      case AppConstants.roleSuperAdmin:
        return 'Super Admin';
      case AppConstants.roleDeptHead:
        return 'Dept Head';
      case AppConstants.roleEmployee:
      default:
        return 'Employee';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getRoleColor().withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: _getRoleColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: AppTextStyles.textTheme.titleMedium,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getRoleLabel(),
                                style: AppTextStyles.textTheme.labelSmall
                                    ?.copyWith(color: _getRoleColor()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.employeeId,
                          style: AppTextStyles.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user.email,
                      style: AppTextStyles.textTheme.bodySmall,
                    ),
                  ),
                  if (!user.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Inactive',
                        style: AppTextStyles.textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
