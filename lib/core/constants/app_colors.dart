import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF1A3C6E);
  static const Color primaryLight = Color(0xFF2D5FA3);
  static const Color primaryDark = Color(0xFF0E2447);

  // Secondary palette
  static const Color secondary = Color(0xFF00B4D8);
  static const Color secondaryLight = Color(0xFF48CAE4);
  static const Color secondaryDark = Color(0xFF0096C7);

  // Background
  static const Color background = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF1E293B);

  // Border
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF1A3C6E);

  // Attendance status colors
  static const Color present = Color(0xFF10B981);
  static const Color absent = Color(0xFFEF4444);
  static const Color late = Color(0xFFF59E0B);
  static const Color halfDay = Color(0xFF8B5CF6);
  static const Color onLeave = Color(0xFF3B82F6);

  // Employee status colors
  static const Color active = Color(0xFF10B981);
  static const Color inactive = Color(0xFF94A3B8);
  static const Color onLeaveStatus = Color(0xFF3B82F6);
  static const Color resigned = Color(0xFFEF4444);

  // Card gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A3C6E), Color(0xFF2D5FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00B4D8), Color(0xFF0096C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
