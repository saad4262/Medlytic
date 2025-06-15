import 'package:flutter/material.dart';
import 'package:medlytic/widgets/premium_card.dart';


import '../theme/app_theme.dart';

class DemoInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const DemoInfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.info_outline_rounded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: AppTheme.accentColor.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
