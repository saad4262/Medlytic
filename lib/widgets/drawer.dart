import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../screens/analysis_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        // IconButton(
                        //   onPressed: () => Get.back(),
                        //   icon: const Icon(
                        //     Icons.close_rounded,
                        //     color: Colors.white,
                        //     size: 24,
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // User Avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:  CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage('assets/images/saad-img.jpg'),
                        // backgroundColor: AppTheme.primaryColor,
                        // child: Icon(
                        //   Icons.person_rounded,
                        //   size: 40,
                        //   color: Colors.white,
                        // ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // User Info
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authController.userModel.value?.displayName ?? 'User Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authController.userModel.value?.email ?? 'user@example.com',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 10),

                // Main Navigation
                Obx(() {
                  bool isUrdu = controller.currentLanguage.value == 'ur';
                  return Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home_rounded,
                        title: isUrdu ? 'ہوم' : 'Home',
                        onTap: () => Get.back(),
                        isSelected: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.analytics_rounded,
                        title: isUrdu ? 'تجزیہ' : 'Analysis',
                        onTap: () {
                          Get.back();
                          Get.to(() => AnalysisScreen());
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.history_rounded,
                        title: isUrdu ? 'تاریخ' : 'History',
                        onTap: () {
                          Get.back();
                          Get.to(() => HistoryScreen());
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_rounded,
                        title: isUrdu ? 'پروفائل' : 'Profile',
                        onTap: () {
                          Get.back();
                          Get.to(() => ProfileScreen());
                        },
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 10),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 10),

                // Secondary Navigation
                Obx(() {
                  bool isUrdu = controller.currentLanguage.value == 'ur';
                  return Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.settings_rounded,
                        title: isUrdu ? 'سیٹنگز' : 'Settings',
                        onTap: () {
                          Get.back();
                          _showComingSoonDialog(isUrdu ? 'سیٹنگز' : 'Settings');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_outline_rounded,
                        title: isUrdu ? 'مدد اور سپورٹ' : 'Help & Support',
                        onTap: () {
                          Get.back();
                          _showComingSoonDialog(isUrdu ? 'مدد اور سپورٹ' : 'Help & Support');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.info_outline_rounded,
                        title: isUrdu ? 'ایپ کے بارے میں' : 'About App',
                        onTap: () {
                          Get.back();
                          _showAboutDialog();
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.star_outline_rounded,
                        title: isUrdu ? 'ریٹ کریں' : 'Rate Us',
                        onTap: () {
                          Get.back();
                          _showComingSoonDialog(isUrdu ? 'ریٹ کریں' : 'Rate Us');
                        },
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 10),

                // Logout
                Obx(() {
                  bool isUrdu = controller.currentLanguage.value == 'ur';
                  return _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: isUrdu ? 'لاگ آؤٹ' : 'Logout',
                    onTap: () {
                      Get.back();
                      _showLogoutDialog();
                    },
                    isDestructive: true,
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.2)
                : isDestructive
                ? AppTheme.errorColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? AppTheme.primaryColor
                : isDestructive
                ? AppTheme.errorColor
                : AppTheme.textPrimary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? AppTheme.primaryColor
                : isDestructive
                ? AppTheme.errorColor
                : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final AppController controller = Get.find<AppController>();
    final AuthController authController = Get.find<AuthController>();
    bool isUrdu = controller.currentLanguage.value == 'ur';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isUrdu ? 'لاگ آؤٹ' : 'Logout',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isUrdu
              ? 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              isUrdu ? 'منسوخ' : 'Cancel',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isUrdu ? 'لاگ آؤٹ' : 'Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final AppController controller = Get.find<AppController>();
    bool isUrdu = controller.currentLanguage.value == 'ur';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Medlytic',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUrdu
                  ? 'AI سے چلنے والا طبی رپورٹ تجزیہ کار'
                  : 'AI-Powered Medical Report Analyzer',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isUrdu
                  ? 'ورژن: 1.0.0\nآپ کی طبی رپورٹس کا ذہین تجزیہ اور بصیرت فراہم کرتا ہے۔'
                  : 'Version: 1.0.0\nProviding intelligent analysis and insights for your medical reports.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUrdu
                          ? 'آپ کا ڈیٹا محفوظ اور نجی ہے'
                          : 'Your data is secure and private',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isUrdu ? 'ٹھیک ہے' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    final AppController controller = Get.find<AppController>();
    bool isUrdu = controller.currentLanguage.value == 'ur';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.construction_rounded,
              color: AppTheme.accentColor,
            ),
            const SizedBox(width: 12),
            Text(
              isUrdu ? 'جلد آ رہا ہے' : 'Coming Soon',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
        content: Text(
          isUrdu
              ? '$feature فیچر جلد دستیاب ہوگا۔ اپڈیٹ کے لیے منتظر رہیں!'
              : '$feature feature will be available soon. Stay tuned for updates!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isUrdu ? 'ٹھیک ہے' : 'OK'),
          ),
        ],
      ),
    );
  }
}
