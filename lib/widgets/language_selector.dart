import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/voice_assistant_controller.dart';
import '../theme/app_theme.dart';


class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final VoiceAssistantController voiceController = Get.find<VoiceAssistantController>();

    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: AppTheme.cardShadow,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: appController.currentLanguage.value,
            icon: const Icon(
              Icons.language_rounded,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            items: const [
              DropdownMenuItem(
                value: 'en',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇺🇸'),
                    SizedBox(width: 6),
                    Text('English'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'ur',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇵🇰'),
                    SizedBox(width: 6),
                    Text('اردو'),
                  ],
                ),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                appController.setLanguage(newValue);

                // Update voice assistant language
                String voiceLanguage = newValue == 'ur' ? 'ur-PK' : 'en-US';
                voiceController.setLanguage(voiceLanguage);

                // Show confirmation
                String message = newValue == 'ur'
                    ? 'زبان اردو میں تبدیل ہو گئی'
                    : 'Language changed to English';

                Get.snackbar(
                  'Language Changed',
                  message,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                  colorText: AppTheme.accentColor,
                  duration: const Duration(seconds: 2),
                );
              }
            },
          ),
        ),
      );
    });
  }
}
