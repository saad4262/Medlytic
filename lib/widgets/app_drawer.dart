import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/app_theme.dart';
import 'language_selector.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final AppController appController = Get.find<AppController>();

    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Header with user info
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Obx(() {
                        String? photoUrl = authController.userModel.value?.photoUrl;
                        String displayName = authController.userModel.value?.displayName ?? 'User';

                        if (photoUrl != null && photoUrl.isNotEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(38),
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildAvatarFallback(displayName);
                              },
                            ),
                          );
                        } else {
                          return _buildAvatarFallback(displayName);
                        }
                      }),
                    ),

                    const SizedBox(height: 16),

                    // User Name
                    Obx(() {
                      String displayName = authController.userModel.value?.displayName ?? 'User';
                      return Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),

                    const SizedBox(height: 4),

                    // User Email
                    Obx(() {
                      String email = authController.userModel.value?.email ?? 'user@example.com';
                      return Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Language Selector
                    const LanguageSelector(),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Obx(() {
                  bool isUrdu = appController.currentLanguage.value == 'ur';
                  return _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: isUrdu ? 'ہوم' : 'Home',
                    onTap: () {
                      Get.back();
                      Get.offAll(() => HomeScreen());
                    },
                    isSelected: Get.currentRoute == '/HomeScreen',
                  );
                }),

                Obx(() {
                  bool isUrdu = appController.currentLanguage.value == 'ur';
                  return _buildDrawerItem(
                    icon: Icons.history_rounded,
                    title: isUrdu ? 'رپورٹ کی تاریخ' : 'Report History',
                    onTap: () {
                      Get.back();
                      Get.to(() => HistoryScreen());
                    },
                  );
                }),

                Obx(() {
                  bool isUrdu = appController.currentLanguage.value == 'ur';
                  return _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: isUrdu ? 'پروفائل' : 'Profile',
                    onTap: () {
                      Get.back();
                      Get.to(() => ProfileScreen());
                    },
                  );
                }),

                const Divider(height: 32),

                Obx(() {
                  bool isUrdu = appController.currentLanguage.value == 'ur';
                  return _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: isUrdu ? 'سیٹنگز' : 'Settings',
                    onTap: () {
                      Get.back();
                      // TODO: Navigate to settings screen
                      Get.snackbar(
                        'Coming Soon',
                        isUrdu ? 'سیٹنگز جلد آ رہی ہیں' : 'Settings coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  );
                }),

                Obx(() {
                  bool isUrdu = appController.currentLanguage.value == 'ur';
                  return _buildDrawerItem(
                    icon: Icons.help_rounded,
                    title: isUrdu ? 'مدد' : 'Help & Support',
                    onTap: () {
                      Get.back();
                      // TODO: Navigate to help screen
                      Get.snackbar(
                        'Help',
                        isUrdu ? 'مدد کا صفحہ جلد آ رہا ہے' : 'Help page coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  );
                }),

                Obx(() {
                  bool isUrdu = appController.currentLanguage.value == 'ur';
                  return _buildDrawerItem(
                    icon: Icons.info_rounded,
                    title: isUrdu ? 'ایپ کے بارے میں' : 'About App',
                    onTap: () {
                      Get.back();
                      _showAboutDialog(context, isUrdu);
                    },
                  );
                }),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              bool isUrdu = appController.currentLanguage.value == 'ur';
              return ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.errorColor,
                ),
                title: Text(
                  isUrdu ? 'لاگ آؤٹ' : 'Logout',
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _showLogoutDialog(context, isUrdu);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: AppTheme.errorColor.withOpacity(0.05),
              );
            }),
          ),

          // App Version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'MediHelper v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String displayName) {
    String initials = displayName.isNotEmpty
        ? displayName.split(' ').map((name) => name[0]).take(2).join().toUpperCase()
        : 'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isUrdu) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          isUrdu ? 'لاگ آؤٹ' : 'Logout',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          isUrdu
              ? 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟'
              : 'Are you sure you want to logout?',
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              isUrdu ? 'منسوخ' : 'Cancel',
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isUrdu ? 'لاگ آؤٹ' : 'Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isUrdu) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          isUrdu ? 'MediHelper کے بارے میں' : 'About MediHelper',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUrdu
                  ? 'MediHelper ایک AI-پاورڈ میڈیکل رپورٹ تجزیہ کار ایپ ہے جو آپ کی طبی رپورٹس کو سمجھنے میں مدد کرتی ہے۔'
                  : 'MediHelper is an AI-powered medical report analyzer that helps you understand your medical reports.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUrdu ? 'خصوصیات:' : 'Features:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUrdu
                  ? '• OCR ٹیکسٹ ایکسٹریکشن\n• AI تجزیہ\n• آواز میں پڑھنا\n• رپورٹ کی تاریخ\n• اردو اور انگریزی سپورٹ'
                  : '• OCR Text Extraction\n• AI Analysis\n• Voice Reading\n• Report History\n• Urdu & English Support',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isUrdu ? 'ٹھیک ہے' : 'OK'),
          ),
        ],
      ),
    );
  }
}
