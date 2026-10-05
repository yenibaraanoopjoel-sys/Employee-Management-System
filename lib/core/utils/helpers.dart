import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppHelpers {
  AppHelpers._();

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    final color = isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.primary;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    bool isDangerous = true,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppColors.error : AppColors.primary,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.active;
      case 'inactive':
        return AppColors.inactive;
      case 'on leave':
        return AppColors.onLeaveStatus;
      case 'resigned':
        return AppColors.resigned;
      default:
        return AppColors.textHint;
    }
  }

  static Color getAttendanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.present;
      case 'absent':
        return AppColors.absent;
      case 'late':
        return AppColors.late;
      case 'half day':
        return AppColors.halfDay;
      case 'leave':
        return AppColors.onLeave;
      default:
        return AppColors.textHint;
    }
  }

  static String getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }
}
