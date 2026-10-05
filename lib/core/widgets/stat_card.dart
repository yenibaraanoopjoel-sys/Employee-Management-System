import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = gradient;
    return Container(
      decoration: BoxDecoration(
        gradient: bg,
        color: bg == null ? AppColors.surface : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bg != null
                        ? Colors.white.withValues(alpha: 0.2)
                        : color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: bg != null ? Colors.white : color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: bg != null ? Colors.white : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: bg != null
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
