import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final bool isConnected;
  final String connectedText;
  final String disconnectedText;
  final IconData connectedIcon;
  final IconData disconnectedIcon;

  const StatusIndicator({
    Key? key,
    required this.isConnected,
    required this.connectedText,
    required this.disconnectedText,
    required this.connectedIcon,
    required this.disconnectedIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? AppTheme.successColor.withOpacity(0.3)
              : AppTheme.warningColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? connectedIcon : disconnectedIcon,
            size: 16,
            color: isConnected ? AppTheme.successColor : AppTheme.warningColor,
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? connectedText : disconnectedText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isConnected ? AppTheme.successColor : AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }
}
