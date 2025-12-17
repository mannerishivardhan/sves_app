import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait for 2 seconds to show splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final authRepository = ref.read(authRepositoryProvider);

      // Check if any users exist in the system
      final usersExist = await authRepository.checkIfUsersExist();

      if (!mounted) return;

      // If no users exist, show onboarding
      if (!usersExist) {
        Navigator.of(
          context,
        ).pushReplacementNamed(AppConstants.routeOnboarding);
        return;
      }

      // Check current auth state
      final currentUser = await authRepository.getCurrentUserProfile();

      if (!mounted) return;

      if (currentUser == null) {
        // Not logged in, go to login
        Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
      } else {
        // Logged in, navigate based on role
        if (currentUser.isSuperAdmin) {
          Navigator.of(
            context,
          ).pushReplacementNamed(AppConstants.routeSuperAdminDashboard);
        } else if (currentUser.isDeptHead) {
          Navigator.of(
            context,
          ).pushReplacementNamed(AppConstants.routeDeptHeadDashboard);
        } else {
          Navigator.of(
            context,
          ).pushReplacementNamed(AppConstants.routeEmployeeDashboard);
        }
      }
    } catch (e) {
      if (!mounted) return;

      // On error, go to login
      Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              const Text(
                'SVES',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Leave Management System',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
