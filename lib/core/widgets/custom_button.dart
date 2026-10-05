import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double? width;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;
    Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final style = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
            side: BorderSide(color: buttonColor, width: 1.5),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          );

    final button = isOutlined
        ? OutlinedButton(
            style: style,
            onPressed: isLoading ? null : onPressed,
            child: child,
          )
        : ElevatedButton(
            style: style,
            onPressed: isLoading ? null : onPressed,
            child: child,
          );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
