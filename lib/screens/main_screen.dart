import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medlytic/screens/home_screen.dart';
import '../controllers/navigation_controller.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/drawer.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () {
                Get.snackbar(
                  'Notifications',
                  'No new notifications',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  colorText: AppTheme.primaryColor,
                );
              },
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      // Use Column instead of Stack to properly handle layout
      body: Column(
        children: [
          // Main content - takes remaining space
          Expanded(
            child: PageView(
              controller: navController.pageController,
              onPageChanged: (index) {
                navController.currentBottomIndex.value = index;
              },
              children: [
                HomeScreen(),
                AnalysisScreen(),
                HistoryScreen(),
                ProfileScreen(),
              ],
            ),
          ),

          // Bottom Navigation - fixed at bottom
          const ModernPillNavbarFloating(),
        ],
      ),
    );
  }
}
