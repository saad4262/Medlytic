import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 50,
                    // backgroundColor: AppTheme.primaryColor,
                    backgroundImage: AssetImage('assets/images/saad-img.jpg'),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                    authController.userModel.value?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    authController.userModel.value?.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () {
                Get.snackbar(
                  'Coming Soon',
                  'Notification settings will be available soon',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Privacy',
              subtitle: 'Manage your data and privacy settings',
              onTap: () {
                Get.snackbar(
                  'Coming Soon',
                  'Privacy settings will be available soon',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help or contact support',
              onTap: () {
                Get.snackbar(
                  'Support',
                  'For support, please email: support@medihelper.com',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App information and version',
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('About MediHelper'),
                    content: const Text(
                      'MediHelper v1.0.0\n\n'
                      'An AI-powered medical report analysis app that helps patients understand their medical reports.\n\n'
                      'Developed with Flutter and Firebase.\n\n'
                      'API: Gemini 2.0 Flash\n'
                      'OCR: Google ML Kit',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            Get.back();
                            authController.signOut();
                          },
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
