import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sves_app/firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/super_admin_dashboard.dart';
import 'features/dashboard/presentation/screens/dept_head_dashboard.dart';
import 'features/dashboard/presentation/screens/employee_dashboard.dart';
import 'features/departments/presentation/screens/departments_list_screen.dart';
import 'features/departments/presentation/screens/departments_overview_screen.dart';
import 'features/users/presentation/screens/users_list_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 12 Pro size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppConstants.routeSplash,
          routes: {
            AppConstants.routeSplash: (context) => const SplashScreen(),
            AppConstants.routeOnboarding: (context) => const OnboardingScreen(),
            AppConstants.routeLogin: (context) => const LoginScreen(),
            AppConstants.routeSuperAdminDashboard: (context) =>
                const SuperAdminDashboard(),
            AppConstants.routeDeptHeadDashboard: (context) =>
                const DeptHeadDashboard(),
            AppConstants.routeEmployeeDashboard: (context) =>
                const EmployeeDashboard(),
            AppConstants.routeDepartments: (context) =>
                const DepartmentsListScreen(),
            '/departments/overview': (context) =>
                const DepartmentsOverviewScreen(),
            AppConstants.routeUsers: (context) =>
                const UsersListScreen(allowManagement: false),
            AppConstants.routeProfile: (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
