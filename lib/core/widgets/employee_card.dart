import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/employee_model.dart';
import '../constants/app_colors.dart';
import '../utils/helpers.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppHelpers.getStatusColor(employee.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee.fullName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(statusColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.designation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            employee.employeeId,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.business_outlined,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              employee.departmentName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') onEdit?.call();
                      if (val == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ]),
                      ),
                    ],
                    child: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
                  ),
                ],
              ],
            ),
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
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitialsAvatar(),
          errorWidget: (_, __, ___) => _buildInitialsAvatar(),
        ),
      );
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          AppHelpers.getInitials(employee.fullName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        employee.status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
