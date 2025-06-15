import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const PremiumButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: isPrimary ? AppTheme.primaryGradient : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPrimary && onPressed != null ? AppTheme.buttonShadow : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : AppTheme.surfaceColor,
          foregroundColor: isPrimary ? Colors.white : AppTheme.primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary ? BorderSide.none : BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isPrimary ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );

    return button;
  }
}
