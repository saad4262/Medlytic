import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
            Color(0xFFCBD5E1),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentColor.withOpacity(0.1),
                    AppTheme.accentColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Medical cross pattern
          Positioned(
            top: 100,
            left: 50,
            child: Icon(
              Icons.medical_services_outlined,
              size: 40,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: 200,
            right: 80,
            child: Icon(
              Icons.health_and_safety_outlined,
              size: 35,
              color: AppTheme.accentColor.withOpacity(0.1),
            ),
          ),
          Positioned(
            top: 300,
            right: 40,
            child: Icon(
              Icons.local_hospital_outlined,
              size: 30,
              color: AppTheme.primaryColor.withOpacity(0.08),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
