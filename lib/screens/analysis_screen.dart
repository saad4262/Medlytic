import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/voice_assistant_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/voice_assistant_button.dart';
import '../widgets/voice_assistant_controls.dart';


class AnalysisScreen extends StatelessWidget {
  AnalysisScreen({Key? key}) : super(key: key);

  final AppController controller = Get.find<AppController>();
  final VoiceAssistantController voiceController = Get.find<VoiceAssistantController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Analyzing your medical report...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Analysis Results',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Here\'s what our AI found in your medical report',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medical_information,
                                color: AppTheme.accentColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              VoiceAssistantButton(
                                text: controller.analysisResult.value,
                                size: 40,
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Markdown(
                            data: controller.analysisResult.value,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.textPrimary),
                              h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              strong: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              em: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
                              listBullet: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Voice assistant controls
                  VoiceAssistantControls(text: controller.analysisResult.value),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Save to History'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            controller.saveReportToHistory();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Share Results'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            // Implement share functionality
                            Get.snackbar(
                              'Share',
                              'Share functionality will be implemented',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Add extra space at bottom for floating button
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Floating voice assistant button
            Positioned(
              right: 16,
              bottom: 16,
              child: Obx(() {
                if (!voiceController.isPlaying.value) {
                  return FloatingActionButton(
                    onPressed: () {
                      voiceController.speak(controller.analysisResult.value);
                    },
                    backgroundColor: AppTheme.accentColor,
                    child: const Icon(Icons.volume_up_rounded),
                  );
                } else {
                  return FloatingActionButton(
                    onPressed: () {
                      voiceController.stop();
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.stop_rounded),
                  );
                }
              }),
            ),
          ],
        );
      }),
    );
  }
}
