import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../users/presentation/screens/users_list_screen.dart';
import '../../../users/presentation/providers/user_provider.dart';
import '../providers/department_provider.dart';

/// Read-only departments overview screen for dashboard navigation
class DepartmentsOverviewScreen extends ConsumerWidget {
  const DepartmentsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsStream = ref.watch(departmentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Departments Overview')),
      body: departmentsStream.when(
        data: (departments) {
          if (departments.isEmpty) {
            return const EmptyState(
              message: 'No departments yet',
              subtitle: 'Departments will appear here once created',
              icon: Icons.business_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(departmentsStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments[index];
                return _DepartmentOverviewCard(
                  departmentId: department.id,
                  name: department.name,
                  description: department.description,
                  headId: department.headId,
                  headName: department.headName,
                  isActive: department.isActive,
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
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading departments', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(departmentsStreamProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartmentOverviewCard extends ConsumerWidget {
  final String departmentId;
  final String name;
  final String description;
  final String? headId;
  final String? headName;
  final bool isActive;

  const _DepartmentOverviewCard({
    required this.departmentId,
    required this.name,
    required this.description,
    this.headId,
    this.headName,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch real-time member count from users collection
    final usersStream = ref.watch(
      usersByDepartmentStreamProvider(departmentId),
    );
    final memberCount = usersStream.when(
      data: (users) => users.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: null, // Read-only view
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Header - matches manage departments style
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 24,
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
                                name,
                                style: AppTextStyles.textTheme.titleLarge,
                              ),
                            ),
                            if (!isActive)
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
                                  style: AppTextStyles.textTheme.labelSmall
                                      ?.copyWith(color: AppColors.error),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppTextStyles.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Clickable head and members sections
              Row(
                children: [
                  // Department Head - Clickable
                  Expanded(
                    child: InkWell(
                      onTap: headId != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsersListScreen(
                                    filterByDepartment: departmentId,
                                    filterByRole: 'dept_head',
                                    title: '$name - Department Head',
                                  ),
                                ),
                              );
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: headId != null
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bordered Head label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: headId != null
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.05,
                                      ),
                                border: Border.all(
                                  color: headId != null
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : AppColors.textSecondary.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.supervisor_account,
                                    size: 18,
                                    color: headId != null
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Head',
                                    style: AppTextStyles.textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  if (headName != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      ':',
                                      style: AppTextStyles.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        headName!,
                                        style: AppTextStyles.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // All Members - Clickable
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UsersListScreen(
                              filterByDepartment: departmentId,
                              filterByRole: 'employee',
                              title: '$name - Employees',
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bordered Members label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.08,
                                ),
                                border: Border.all(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Members($memberCount)',
                                    style: AppTextStyles.textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
