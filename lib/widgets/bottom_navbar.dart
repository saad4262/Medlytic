import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/navigation_controller.dart';
import '../theme/app_theme.dart';

class ModernPillNavbarFloating extends StatelessWidget {
  const ModernPillNavbarFloating({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();
    final NavigationController navController = Get.find<NavigationController>();

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child:  Container(
            decoration: BoxDecoration(
              color: Colors.white, // Transparent glass effect
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() {
              bool isUrdu = controller.currentLanguage.value == 'ur';
              int currentIndex = navController.currentBottomIndex.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPillNavItem(
                    icon: Icons.home_rounded,
                    label: isUrdu ? 'ہوم' : 'Home',
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: () => navController.changeBottomIndex(0),
                  ),
                  _buildPillNavItem(
                    icon: Icons.analytics_rounded,
                    label: isUrdu ? 'تجزیہ' : 'Analytics',
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: () => navController.changeBottomIndex(1),
                  ),
                  _buildPillNavItem(
                    icon: Icons.history_rounded,
                    label: isUrdu ? 'تاریخ' : 'History',
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: () => navController.changeBottomIndex(2),
                  ),
                  _buildPillNavItem(
                    icon: Icons.person_rounded,
                    label: isUrdu ? 'پروفائل' : 'Profile',
                    index: 3,
                    currentIndex: currentIndex,
                    onTap: () => navController.changeBottomIndex(3),
                  ),
                ],
              );
            }),
          ),
        ),

    );
  }

  Widget _buildPillNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
