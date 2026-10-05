import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/employee_model.dart';
import '../../../models/department_model.dart';
import '../../../services/employee_service.dart';
import '../../../services/department_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/date_utils.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empService = EmployeeService();
  final _deptService = DepartmentService();
  final _authService = AuthService();
  final _storageService = StorageService();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _empIdCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // State
  DepartmentModel? _selectedDept;
  String _employmentType = 'Full Time';
  String _status = 'Active';
  String _gender = 'Male';
  DateTime? _joiningDate;
  DateTime? _dob;
  XFile? _profileImage;
  bool _loading = false;
  bool _uploadingImage = false;
  List<DepartmentModel> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _empIdCtrl.dispose();
    _designationCtrl.dispose();
    _salaryCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    final depts = await _deptService.getDepartments();
    if (mounted) setState(() => _departments = depts);
  }

  Future<void> _pickImage() async {
    final img = await _storageService.pickImage();
    if (img != null) setState(() => _profileImage = img);
  }

  Future<void> _pickDate(bool isJoining) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isJoining) {
          _joiningDate = date;
        } else {
          _dob = date;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDept == null) {
      AppHelpers.showSnackBar(context, 'Please select a department.', isError: true);
      return;
    }
    if (_joiningDate == null) {
      AppHelpers.showSnackBar(context, 'Please select a joining date.', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      // Check duplicates
      if (await _empService.employeeIdExists(_empIdCtrl.text.trim())) {
        if (!mounted) return;
        AppHelpers.showSnackBar(context, AppStrings.employeeIdExists, isError: true);
        setState(() => _loading = false);
        return;
      }
      if (await _empService.emailExists(_emailCtrl.text.trim())) {
        if (!mounted) return;
        AppHelpers.showSnackBar(context, AppStrings.emailExists, isError: true);
        setState(() => _loading = false);
        return;
      }

      // Create Firebase Auth account
      final userModel = await _authService.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
        role: 'employee',
        employeeId: _empIdCtrl.text.trim(),
      );

      // Upload image
      String imageUrl = '';
      if (_profileImage != null) {
        setState(() => _uploadingImage = true);
        try {
          imageUrl = await _storageService.uploadProfileImage(
              userModel.userId, _profileImage!);
        } catch (_) {}
        setState(() => _uploadingImage = false);
      }

      final now = DateTime.now();
      final employee = EmployeeModel(
        id: '',
        employeeId: _empIdCtrl.text.trim(),
        userId: userModel.userId,
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        profileImage: imageUrl,
        departmentId: _selectedDept!.id,
        departmentName: _selectedDept!.name,
        designation: _designationCtrl.text.trim(),
        joiningDate: _joiningDate!,
        salary: double.tryParse(_salaryCtrl.text) ?? 0,
        employmentType: _employmentType,
        status: _status,
        address: _addressCtrl.text.trim(),
        dateOfBirth: _dob,
        gender: _gender,
        createdAt: now,
        updatedAt: now,
      );

      await _empService.addEmployee(employee);

      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Employee added successfully!', isSuccess: true);
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
    return LoadingOverlay(
      isLoading: _loading,
      message: _uploadingImage ? 'Uploading image...' : 'Creating employee...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.addEmployee),
          backgroundColor: AppColors.surface,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CustomButton(
                label: 'Save',
                onPressed: _submit,
                isLoading: _loading,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildSection('Personal Information', [
                  _field(CustomTextField(
                    label: AppStrings.fullName,
                    controller: _nameCtrl,
                    validator: (v) => Validators.minLength(v, 2, 'Full Name'),
                  )),
                  _twoColumns(
                    CustomTextField(
                      label: AppStrings.email,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    CustomTextField(
                      label: AppStrings.phone,
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ),
                  ),
                  _twoColumns(
                    CustomDropdownField<String>(
                      label: AppStrings.gender,
                      value: _gender,
                      items: AppStrings.genders,
                      itemLabel: (g) => g,
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                    GestureDetector(
                      onTap: () => _pickDate(false),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          label: AppStrings.dateOfBirth,
                          hint: 'Select date',
                          readOnly: true,
                          initialValue: _dob != null
                              ? AppDateUtils.formatDate(_dob)
                              : '',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                  ),
                  _field(CustomTextField(
                    label: AppStrings.address,
                    controller: _addressCtrl,
                    maxLines: 2,
                  )),
                ]),
                const SizedBox(height: 16),
                _buildSection('Employment Information', [
                  _twoColumns(
                    CustomTextField(
                      label: AppStrings.employeeId,
                      controller: _empIdCtrl,
                      validator: Validators.employeeId,
                    ),
                    CustomTextField(
                      label: AppStrings.designation,
                      controller: _designationCtrl,
                      validator: (v) => Validators.required(v, 'Designation'),
                    ),
                  ),
                  _field(CustomDropdownField<DepartmentModel>(
                    label: AppStrings.department,
                    value: _selectedDept,
                    items: _departments,
                    itemLabel: (d) => d.name,
                    onChanged: (v) => setState(() => _selectedDept = v),
                    validator: (v) => v == null ? 'Please select a department' : null,
                  )),
                  _twoColumns(
                    GestureDetector(
                      onTap: () => _pickDate(true),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          label: AppStrings.joiningDate,
                          hint: 'Select date',
                          readOnly: true,
                          initialValue: _joiningDate != null
                              ? AppDateUtils.formatDate(_joiningDate)
                              : '',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                    ),
                    CustomTextField(
                      label: AppStrings.salary,
                      controller: _salaryCtrl,
                      keyboardType: TextInputType.number,
                      validator: Validators.salary,
                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    ),
                  ),
                  _twoColumns(
                    CustomDropdownField<String>(
                      label: AppStrings.employmentType,
                      value: _employmentType,
                      items: AppStrings.employmentTypes,
                      itemLabel: (t) => t,
                      onChanged: (v) => setState(() => _employmentType = v!),
                    ),
                    CustomDropdownField<String>(
                      label: AppStrings.status,
                      value: _status,
                      items: AppStrings.employeeStatuses,
                      itemLabel: (s) => s,
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection('Account Credentials', [
                  _field(CustomTextField(
                    label: 'Login Password',
                    hint: 'Set employee login password',
                    controller: _passwordCtrl,
                    obscureText: true,
                    validator: Validators.password,
                  )),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A Firebase Authentication account will be created for this employee using the email and password above.',
                            style: TextStyle(color: AppColors.info, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Create Employee',
                  onPressed: _submit,
                  isLoading: _loading,
                  width: double.infinity,
                  icon: Icons.person_add_rounded,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.primaryLight, width: 2),
              ),
              child: _profileImage != null
                  ? ClipOval(
                      child: Image.network(
                        _profileImage!.path,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultAvatar(),
                      ),
                    )
                  : _defaultAvatar(),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return const Center(
      child: Icon(Icons.person_rounded, size: 48, color: AppColors.primaryLight),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _field(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  Widget _twoColumns(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 16),
              Expanded(child: right),
            ],
          );
        }
        return Column(children: [
          left,
          const SizedBox(height: 16),
          right,
        ]);
      }),
    );
  }
}
