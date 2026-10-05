import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/employee_model.dart';
import '../../../models/department_model.dart';
import '../../../services/employee_service.dart';
import '../../../services/department_service.dart';
import '../../../services/storage_service.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/date_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditEmployeeScreen extends StatefulWidget {
  final EmployeeModel employee;
  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empService = EmployeeService();
  final _deptService = DepartmentService();
  final _storageService = StorageService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _designationCtrl;
  late final TextEditingController _salaryCtrl;
  late final TextEditingController _addressCtrl;

  DepartmentModel? _selectedDept;
  late String _employmentType;
  late String _status;
  late String _gender;
  DateTime? _joiningDate;
  DateTime? _dob;
  XFile? _newImage;
  bool _loading = false;
  List<DepartmentModel> _departments = [];

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameCtrl = TextEditingController(text: e.fullName);
    _phoneCtrl = TextEditingController(text: e.phone);
    _designationCtrl = TextEditingController(text: e.designation);
    _salaryCtrl = TextEditingController(text: e.salary.toStringAsFixed(0));
    _addressCtrl = TextEditingController(text: e.address);
    _employmentType = e.employmentType;
    _status = e.status;
    _gender = e.gender;
    _joiningDate = e.joiningDate;
    _dob = e.dateOfBirth;
    _loadDepts();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _designationCtrl.dispose();
    _salaryCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDepts() async {
    final depts = await _deptService.getDepartments();
    if (mounted) {
      setState(() {
        _departments = depts;
        _selectedDept = depts.where((d) => d.id == widget.employee.departmentId).firstOrNull;
      });
    }
  }

  Future<void> _pickImage() async {
    final img = await _storageService.pickImage();
    if (img != null) setState(() => _newImage = img);
  }

  Future<void> _pickDate(bool isJoining) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isJoining ? (_joiningDate ?? DateTime.now()) : (_dob ?? DateTime(1990)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => isJoining ? _joiningDate = date : _dob = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String imageUrl = widget.employee.profileImage;
      if (_newImage != null) {
        imageUrl = await _storageService.uploadProfileImage(
            widget.employee.userId, _newImage!);
      }

      final updated = widget.employee.copyWith(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        profileImage: imageUrl,
        departmentId: _selectedDept?.id ?? widget.employee.departmentId,
        departmentName: _selectedDept?.name ?? widget.employee.departmentName,
        designation: _designationCtrl.text.trim(),
        joiningDate: _joiningDate,
        salary: double.tryParse(_salaryCtrl.text) ?? widget.employee.salary,
        employmentType: _employmentType,
        status: _status,
        address: _addressCtrl.text.trim(),
        dateOfBirth: _dob,
        gender: _gender,
        updatedAt: DateTime.now(),
      );

      await _empService.updateEmployee(widget.employee.id, updated);
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Employee updated successfully!', isSuccess: true);
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.editEmployee),
          backgroundColor: AppColors.surface,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CustomButton(
                label: 'Update',
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
                  _field(CustomTextField(
                    label: AppStrings.phone,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  )),
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
                          readOnly: true,
                          initialValue: _dob != null ? AppDateUtils.formatDate(_dob) : '',
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
                  _field(CustomTextField(
                    label: AppStrings.designation,
                    controller: _designationCtrl,
                    validator: (v) => Validators.required(v, 'Designation'),
                  )),
                  _field(CustomDropdownField<DepartmentModel>(
                    label: AppStrings.department,
                    value: _selectedDept,
                    items: _departments,
                    itemLabel: (d) => d.name,
                    onChanged: (v) => setState(() => _selectedDept = v),
                  )),
                  _twoColumns(
                    GestureDetector(
                      onTap: () => _pickDate(true),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          label: AppStrings.joiningDate,
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
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Update Employee',
                  onPressed: _submit,
                  isLoading: _loading,
                  width: double.infinity,
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
            _buildAvatarContent(),
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
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (widget.employee.profileImage.isNotEmpty && _newImage == null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.employee.profileImage,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(
          AppHelpers.getInitials(widget.employee.fullName),
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
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

  Widget _field(Widget child) => Padding(padding: const EdgeInsets.only(bottom: 16), child: child);

  Widget _twoColumns(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ]);
        }
        return Column(children: [left, const SizedBox(height: 16), right]);
      }),
    );
  }
}
