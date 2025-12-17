import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../departments/presentation/providers/department_provider.dart';
import '../../../users/presentation/providers/user_provider.dart';
import '../../../users/presentation/screens/users_list_screen.dart';

/// Dashboard for Super Admin
class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeProfile);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text('Welcome, Admin 👋', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Here\'s what\'s happening today',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Stats Grid - Watch async data here
              _buildStatsGrid(context, ref),
              const SizedBox(height: 32),

              // Pending Approvals
              Text('Pending Approvals', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _buildPendingApprovalCard(
                name: 'John Doe',
                department: 'Horticulture',
                leaveType: 'Sick Leave',
                dates: 'Dec 20-22, 2024',
              ),
              const SizedBox(height: 12),
              _buildPendingApprovalCard(
                name: 'Jane Smith',
                department: 'Academics',
                leaveType: 'Paid Leave',
                dates: 'Dec 25-26, 2024',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'users',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const UsersListScreen(allowManagement: true),
                ),
              );
            },
            icon: const Icon(Icons.people),
            label: const Text('Manage Users'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'departments',
            onPressed: () {
              Navigator.of(context).pushNamed('/departments');
            },
            icon: const Icon(Icons.business),
            label: const Text('Manage Departments'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(activeDepartmentsStreamProvider);
    final usersAsync = ref.watch(usersStreamProvider);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        StatCard.primary(
          title: 'Departments',
          value: departmentsAsync.when(
            data: (depts) => depts.length.toString(),
            loading: () => '...',
            error: (_, __) => '0',
          ),
          icon: Icons.business,
          onTap: () {
            Navigator.of(context).pushNamed('/departments/overview');
          },
        ),
        StatCard.success(
          title: 'Total Users',
          value: usersAsync.when(
            data: (users) => users.length.toString(),
            loading: () => '...',
            error: (_, __) => '0',
          ),
          icon: Icons.people,
          onTap: () {
            Navigator.of(context).pushNamed('/users');
          },
        ),
        StatCard.warning(
          title: 'Pending Requests',
          value: '0',
          icon: Icons.pending_actions,
        ),
        StatCard.error(
          title: 'On Leave Today',
          value: '0',
          icon: Icons.event_busy,
        ),
      ],
    );
  }

  Widget _buildPendingApprovalCard({
    required String name,
    required String department,
    required String leaveType,
    required String dates,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight.withValues(
                    alpha: 0.2,
                  ),
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.textTheme.titleMedium),
                      Text(
                        department,
                        style: AppTextStyles.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(dates, style: AppTextStyles.textTheme.bodySmall),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    leaveType,
                    style: AppTextStyles.textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
