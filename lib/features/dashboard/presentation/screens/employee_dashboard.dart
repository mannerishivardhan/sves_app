import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Employee Dashboard
class EmployeeDashboard extends ConsumerWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppConstants.routeLogin,
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
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
              Text('Welcome Back 👋', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Manage your leaves easily',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Leave Balance Section
              Text('Leave Balance', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLeaveBalanceCard(
                      title: 'Sick Leave',
                      remaining: 10,
                      total: 12,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLeaveBalanceCard(
                      title: 'Paid Leave',
                      remaining: 15,
                      total: 20,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Applications
              Text('Recent Applications', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _buildLeaveApplicationCard(
                leaveType: 'Sick Leave',
                dates: 'Dec 15-17, 2024',
                status: 'Approved',
                statusColor: AppColors.success,
              ),
              const SizedBox(height: 12),
              _buildLeaveApplicationCard(
                leaveType: 'Paid Leave',
                dates: 'Dec 25-26, 2024',
                status: 'Pending',
                statusColor: AppColors.warning,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
      ),
    );
  }

  Widget _buildLeaveBalanceCard({
    required String title,
    required int remaining,
    required int total,
    required Color color,
  }) {
    final percentage = (remaining / total);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.textTheme.labelLarge),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$remaining',
                  style: AppTextStyles.h2.copyWith(color: color),
                ),
                Text('/$total', style: AppTextStyles.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveApplicationCard({
    required String leaveType,
    required String dates,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(leaveType, style: AppTextStyles.textTheme.titleMedium),
                  Text(dates, style: AppTextStyles.textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: AppTextStyles.textTheme.labelMedium?.copyWith(
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
