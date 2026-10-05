import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/employee_model.dart';
import '../../../services/employee_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/date_utils.dart';
import 'edit_employee_screen.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final EmployeeModel employee;
  const EmployeeDetailsScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(context, 'Personal Information', [
                    _InfoRow(Icons.email_rounded, 'Email', employee.email),
                    _InfoRow(Icons.phone_rounded, 'Phone', employee.phone),
                    _InfoRow(Icons.location_on_rounded, 'Address',
                        employee.address.isNotEmpty ? employee.address : '--'),
                    _InfoRow(Icons.cake_rounded, 'Date of Birth',
                        AppDateUtils.formatDate(employee.dateOfBirth)),
                    _InfoRow(
                        employee.gender == 'Female'
                            ? Icons.female_rounded
                            : Icons.male_rounded,
                        'Gender',
                        employee.gender),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard(context, 'Employment Information', [
                    _InfoRow(Icons.badge_rounded, 'Employee ID', employee.employeeId),
                    _InfoRow(Icons.corporate_fare_rounded, 'Department',
                        employee.departmentName),
                    _InfoRow(Icons.work_rounded, 'Designation', employee.designation),
                    _InfoRow(Icons.calendar_today_rounded, 'Joining Date',
                        AppDateUtils.formatDate(employee.joiningDate)),
                    _InfoRow(Icons.attach_money_rounded, 'Salary',
                        '₹${employee.salary.toStringAsFixed(0)}'),
                    _InfoRow(Icons.work_history_rounded, 'Employment Type',
                        employee.employmentType),
                    _InfoRow(Icons.circle, 'Status', employee.status),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final statusColor = AppHelpers.getStatusColor(employee.status);
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditEmployeeScreen(employee: employee),
            ),
          ).then((v) {
            if (v == true && context.mounted) {
              Navigator.pop(context, true);
            }
          }),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: () => _deleteEmployee(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              _buildAvatar(),
              const SizedBox(height: 12),
              Text(
                employee.fullName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                employee.designation,
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(employee.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (employee.profileImage.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: employee.profileImage,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsAvatar(),
          errorWidget: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(
          AppHelpers.getInitials(employee.fullName),
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            ...rows.map((r) => _buildRow(context, r)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, _InfoRow row) {
    final isStatus = row.label == 'Status';
    final statusColor = isStatus
        ? AppHelpers.getStatusColor(row.value)
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(row.icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                isStatus
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(row.value,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      )
                    : Text(row.value,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(BuildContext context) async {
    final ok = await AppHelpers.showConfirmDialog(
      context,
      title: AppStrings.deleteEmployee,
      message: AppStrings.deleteEmployeeConfirm,
    );
    if (ok == true && context.mounted) {
      try {
        await EmployeeService().deleteEmployee(employee.id);
        if (!context.mounted) return;
        Navigator.pop(context, true);
        AppHelpers.showSnackBar(context, 'Employee deleted.', isSuccess: true);
      } catch (e) {
        if (!context.mounted) return;
        AppHelpers.showSnackBar(context, AppStrings.genericError, isError: true);
      }
    }
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
