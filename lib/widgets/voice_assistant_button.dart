import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/voice_assistant_controller.dart';
import '../theme/app_theme.dart';

class VoiceAssistantButton extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onSettingsPressed;

  const VoiceAssistantButton({
    Key? key,
    required this.text,
    this.size = 56.0,
    this.color,
    this.backgroundColor,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VoiceAssistantController controller = Get.find<VoiceAssistantController>();
    final AppController appController = Get.find<AppController>();

    return Obx(() {
      final bool isPlaying = controller.isPlaying.value;
      final bool isPaused = controller.isPaused.value;
      final String currentLang = appController.currentLanguage.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: isPlaying
                  ? AppTheme.accentGradient
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: [
                BoxShadow(
                  color: (isPlaying ? AppTheme.accentColor : AppTheme.primaryColor).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(size / 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(size / 2),
                onTap: () {
                  if (isPlaying) {
                    controller.stop();
                  } else {
                    // Determine voice language based on current app language
                    String voiceLanguage = currentLang == 'ur' ? 'ur-PK' : 'en-US';
                    controller.setLanguage(voiceLanguage);
                    controller.speak(text);
                  }
                },
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                      key: ValueKey<bool>(isPlaying),
                      color: Colors.white,
                      size: size * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPlaying
                ? (isPaused
                ? (currentLang == 'ur' ? 'رک گیا' : 'Paused')
                : (currentLang == 'ur' ? 'رک جائے' : 'Stop Reading'))
                : (currentLang == 'ur' ? 'بلند آواز میں پڑھیں' : 'Read Aloud'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isPlaying ? AppTheme.accentColor : AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (isPlaying && controller.currentWord.value.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                controller.currentWord.value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
        ],
      );
    });
  }
}
