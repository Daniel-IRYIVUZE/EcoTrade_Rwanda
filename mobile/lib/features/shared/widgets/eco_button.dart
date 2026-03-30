import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EcoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final double? height;

  const EcoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      final outlineColor = backgroundColor ?? AppColors.primary;
      return SizedBox(
        width: double.infinity,
        height: height ?? 56,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: icon != null ? Icon(icon, size: 18, color: outlineColor) : const SizedBox.shrink(),
          label: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(outlineColor),
                  ),
                )
              : Text(label, style: TextStyle(color: outlineColor)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: outlineColor, width: 1.5),
            foregroundColor: outlineColor,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class EcoSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool outlined;

  const EcoSmallButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : buttonColor,
          borderRadius: BorderRadius.circular(8),
          border: outlined ? Border.all(color: buttonColor, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: outlined ? buttonColor : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
