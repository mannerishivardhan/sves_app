import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    debugPrint('🔐 LOGIN: Starting login process...');
    setState(() => _isLoading = true);

    try {
      debugPrint('🔐 LOGIN: Reading auth controller from Riverpod...');
      final authController = ref.read(authControllerProvider.notifier);

      debugPrint('🔐 LOGIN: Calling signIn method...');
      debugPrint('🔐 LOGIN: Email: ${_emailController.text.trim()}');

      final user = await authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint('🔐 LOGIN: Sign in successful! User: ${user.email}');
      debugPrint('🔐 LOGIN: User role: ${user.role}');
      debugPrint('🔐 LOGIN: Is Super Admin: ${user.isSuperAdmin}');

      if (!mounted) {
        debugPrint('🔐 LOGIN: Widget not mounted, aborting navigation');
        return;
      }

      debugPrint('🔐 LOGIN: Navigating based on role...');

      // Navigate based on role
      if (user.isSuperAdmin) {
        debugPrint('🔐 LOGIN: Navigating to Super Admin Dashboard');
        Navigator.of(
          context,
        ).pushReplacementNamed(AppConstants.routeSuperAdminDashboard);
      } else if (user.isDeptHead) {
        debugPrint('🔐 LOGIN: Navigating to Dept Head Dashboard');
        Navigator.of(
          context,
        ).pushReplacementNamed(AppConstants.routeDeptHeadDashboard);
      } else {
        debugPrint('🔐 LOGIN: Navigating to Employee Dashboard');
        Navigator.of(
          context,
        ).pushReplacementNamed(AppConstants.routeEmployeeDashboard);
      }

      debugPrint('🔐 LOGIN: Navigation completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ LOGIN ERROR: $e');
      debugPrint('❌ LOGIN STACK: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      debugPrint('🔐 LOGIN: Cleaning up...');
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('🔐 LOGIN: Process complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue to SVES Leave Management',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  PasswordTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    useGradient: true,
                  ),
                  const SizedBox(height: 16),

                  // Footer note
                  Text(
                    'Contact your administrator if you need help',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
