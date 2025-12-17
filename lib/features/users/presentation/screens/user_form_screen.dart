import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/user_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../departments/presentation/providers/department_provider.dart';

/// Form screen for creating or editing a user
class UserFormScreen extends ConsumerStatefulWidget {
  final String? userId;
  final UserModel? user;

  const UserFormScreen({super.key, this.userId, this.user});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _employeeIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  String _selectedRole = AppConstants.roleEmployee;
  String? _selectedDepartment;
  bool _isLoading = false;

  bool get isEditing => widget.userId != null;

  @override
  void initState() {
    super.initState();
    _employeeIdController = TextEditingController(
      text: widget.user?.employeeId,
    );
    _nameController = TextEditingController(text: widget.user?.name);
    _emailController = TextEditingController(text: widget.user?.email);
    _phoneController = TextEditingController(text: widget.user?.phone);
    _passwordController = TextEditingController();

    if (widget.user != null) {
      _selectedRole = widget.user!.role;
      _selectedDepartment = widget.user!.departmentId;
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(userControllerProvider.notifier);

      if (isEditing) {
        await controller.updateUser(
          userId: widget.userId!,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          departmentId: _selectedDepartment,
        );
      } else {
        await controller.createUser(
          employeeId: _employeeIdController.text.trim(),
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          departmentId: _selectedDepartment,
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : 'Password@123',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'User updated successfully'
                : AppConstants.successUserCreated,
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      // Clean up error message by removing "Exception: " prefix
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleToggleActive() async {
    if (widget.user == null) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(userControllerProvider.notifier);

      if (widget.user!.isActive) {
        await controller.deactivateUser(widget.userId!);
      } else {
        await controller.activateUser(widget.userId!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.user!.isActive ? 'User deactivated' : 'User activated',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentsStream = ref.watch(activeDepartmentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit User' : 'New User'),
        actions: [
          if (isEditing && widget.user != null)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _handleToggleActive,
                  child: Row(
                    children: [
                      Icon(
                        widget.user!.isActive
                            ? Icons.block
                            : Icons.check_circle,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(widget.user!.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () async {
                    try {
                      final controller = ref.read(
                        userControllerProvider.notifier,
                      );
                      await controller.resetPassword(widget.user!.email);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset email sent'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.lock_reset, size: 20),
                      SizedBox(width: 12),
                      Text('Reset Password'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User icon
                Center(
                  child: Container(
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
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Employee ID
                CustomTextField(
                  label: 'Employee ID',
                  hint: 'e.g., EMP001',
                  controller: _employeeIdController,
                  validator: Validators.employeeId,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  enabled: !isEditing && !_isLoading,
                ),
                const SizedBox(height: 16),

                // Name
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter full name',
                  controller: _nameController,
                  validator: Validators.name,
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter email address',
                  controller: _emailController,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isEditing && !_isLoading,
                ),
                const SizedBox(height: 16),

                // Phone
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter 10-digit phone number',
                  controller: _phoneController,
                  validator: Validators.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Role dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.roleEmployee,
                      child: Text('Employee'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.roleDeptHead,
                      child: Text('Department Head'),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                  validator: (value) => Validators.required(value, 'Role'),
                ),
                const SizedBox(height: 16),

                // Department dropdown
                departmentsStream.when(
                  data: (departments) {
                    return DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No Department'),
                        ),
                        ...departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept.id,
                            child: Text(dept.name),
                          );
                        }),
                      ],
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedDepartment = value;
                              });
                            },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading departments'),
                ),
                const SizedBox(height: 16),

                // Password (only for new users)
                if (!isEditing) ...[
                  PasswordTextField(
                    label: 'Password (Optional)',
                    hint: 'Default: Password@123',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'If left empty, default password "Password@123" will be used',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.info),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),

                // Save button
                CustomButton(
                  text: isEditing ? 'Update User' : 'Create User',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  useGradient: true,
                  icon: isEditing ? Icons.save : Icons.person_add,
                ),
                const SizedBox(height: 12),

                // Cancel button
                CustomButton.secondary(
                  text: 'Cancel',
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
