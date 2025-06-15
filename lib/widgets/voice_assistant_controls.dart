import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medlytic/widgets/premium_card.dart';

import '../controllers/voice_assistant_controller.dart';
import '../theme/app_theme.dart';

class VoiceAssistantControls extends StatelessWidget {
  final String text;

  const VoiceAssistantControls({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VoiceAssistantController controller = Get.find<VoiceAssistantController>();

    return Obx(() {
      final bool isPlaying = controller.isPlaying.value;
      final bool isPaused = controller.isPaused.value;

      return PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.record_voice_over_rounded,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Voice Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (isPlaying)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPaused ? Icons.pause_rounded : Icons.volume_up_rounded,
                          size: 14,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPaused ? 'Paused' : 'Speaking',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Play',
                  isActive: !isPlaying || isPaused,
                  onPressed: () => controller.speak(text),
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  label: isPaused ? 'Resume' : 'Pause',
                  isActive: isPlaying,
                  onPressed: () => controller.pause(),
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.stop_rounded,
                  label: 'Stop',
                  isActive: isPlaying,
                  onPressed: () => controller.stop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Voice settings
            const Text(
              'Voice Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Speed control
            Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.speed_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Speed',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: controller.rate.value,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: AppTheme.accentColor,
                    inactiveColor: AppTheme.accentColor.withOpacity(0.2),
                    onChanged: (value) => controller.setRate(value),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(controller.rate.value * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Pitch control
            Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pitch',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: controller.pitch.value,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    activeColor: AppTheme.accentColor,
                    inactiveColor: AppTheme.accentColor.withOpacity(0.2),
                    onChanged: (value) => controller.setPitch(value),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(controller.pitch.value * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Volume control
            Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.volume_up_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Volume',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: controller.volume.value,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: AppTheme.accentColor,
                    inactiveColor: AppTheme.accentColor.withOpacity(0.2),
                    onChanged: (value) => controller.setVolume(value),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(controller.volume.value * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Current word indicator
            if (isPlaying && controller.currentWord.value.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.record_voice_over_rounded,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Currently reading: "${controller.currentWord.value}"',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isActive ? AppTheme.accentColor : Colors.grey,
            ),
            onPressed: isActive ? onPressed : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppTheme.accentColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
