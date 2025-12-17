import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Dashboard statistics card with gradient background
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.gradient,
    this.color,
    this.onTap,
  });

  const StatCard.primary({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  }) : gradient = AppColors.primaryGradient,
       color = null;

  const StatCard.success({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  }) : gradient = AppColors.successGradient,
       color = null;

  const StatCard.warning({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  }) : gradient = AppColors.warningGradient,
       color = null;

  const StatCard.error({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  }) : gradient = AppColors.errorGradient,
       color = null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            color: color ?? (gradient == null ? AppColors.primary : null),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (color ?? AppColors.primary).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
