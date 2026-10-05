import 'package:flutter/material.dart';
import '../../../models/department_model.dart';
import '../../../services/department_service.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';

class EditDepartmentScreen extends StatefulWidget {
  final DepartmentModel department;
  const EditDepartmentScreen({super.key, required this.department});

  @override
  State<EditDepartmentScreen> createState() => _EditDepartmentScreenState();
}

class _EditDepartmentScreenState extends State<EditDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _managerCtrl;
  final _deptService = DepartmentService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.department.name);
    _descCtrl = TextEditingController(text: widget.department.description);
    _managerCtrl = TextEditingController(text: widget.department.manager);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _managerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final updated = widget.department.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        manager: _managerCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );
      await _deptService.updateDepartment(widget.department.id, updated);
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Department updated!', isSuccess: true);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.editDepartment),
        backgroundColor: AppColors.surface,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit Department',
                    style: Theme.of(context).textTheme.titleLarge),
                const Divider(height: 24),
                CustomTextField(
                  label: AppStrings.departmentName,
                  controller: _nameCtrl,
                  validator: (v) => Validators.minLength(v, 2, 'Department Name'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.description,
                  controller: _descCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.manager,
                  controller: _managerCtrl,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  label: 'Update Department',
                  onPressed: _submit,
                  isLoading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
