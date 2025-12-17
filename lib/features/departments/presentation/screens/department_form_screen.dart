import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/department_provider.dart';

/// Form screen for creating or editing a department
class DepartmentFormScreen extends ConsumerStatefulWidget {
  final String? departmentId;
  final String? departmentName;
  final String? departmentDescription;

  const DepartmentFormScreen({
    super.key,
    this.departmentId,
    this.departmentName,
    this.departmentDescription,
  });

  @override
  ConsumerState<DepartmentFormScreen> createState() =>
      _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends ConsumerState<DepartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  bool get isEditing => widget.departmentId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.departmentName);
    _descriptionController = TextEditingController(
      text: widget.departmentDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(departmentControllerProvider.notifier);

      if (isEditing) {
        await controller.updateDepartment(
          departmentId: widget.departmentId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      } else {
        await controller.createDepartment(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? AppConstants.successDepartmentCreated.replaceAll(
                    'created',
                    'updated',
                  )
                : AppConstants.successDepartmentCreated,
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

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: const Text(
          'Are you sure you want to delete this department? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final controller = ref.read(departmentControllerProvider.notifier);
      await controller.deleteDepartment(widget.departmentId!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Department deleted successfully'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Department' : 'New Department'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isLoading ? null : _handleDelete,
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
                // Department icon
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
                      Icons.business,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Department name
                CustomTextField(
                  label: 'Department Name',
                  hint: 'e.g., Horticulture, Academics',
                  controller: _nameController,
                  validator: (value) =>
                      Validators.required(value, 'Department name'),
                  prefixIcon: const Icon(Icons.business_outlined),
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),

                // Description
                CustomTextField(
                  label: 'Description',
                  hint: 'Brief description of the department',
                  controller: _descriptionController,
                  validator: (value) =>
                      Validators.required(value, 'Description'),
                  prefixIcon: const Icon(Icons.description_outlined),
                  maxLines: 3,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'You can assign a department head and add employees after saving.'
                              : 'After creating the department, you can assign a head and add employees.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                CustomButton(
                  text: isEditing ? 'Update Department' : 'Create Department',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  useGradient: true,
                  icon: isEditing ? Icons.save : Icons.add,
                ),
                const SizedBox(height: 16),

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
