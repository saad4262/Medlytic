// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:percent_indicator/percent_indicator.dart';
//
// import '../theme/app_theme.dart';
//
// class ReportScoreController extends GetxController {
//   var isLoading = false.obs;
//   var healthScore = 0.obs;
//   var status = 'No report uploaded yet.'.obs;
//
//   // Gemini API details
//   final String _geminiApiKey = 'AIzaSyAV7w2enmsaCZa-JpMRraglmWHlDbqs1Dg';
//   final String _geminiEndpoint =
//       'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
//
//   Future<void> pickReport() async {
//     isLoading.value = true;
//     status.value = 'Processing report...';
//     healthScore.value = 0;
//
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
//     );
//
//     if (result != null && result.files.single.path != null) {
//       final file = File(result.files.single.path!);
//       String text = '';
//
//       if (file.path.endsWith('.pdf')) {
//         text = await _extractTextFromPdf(file);
//       } else {
//         text = await _extractTextFromImage(file);
//       }
//
//       if (text.isNotEmpty) {
//         final score = await _analyzeWithGemini(text);
//         healthScore.value = score;
//         status.value = 'Health score generated successfully!';
//       } else {
//         status.value = 'Unable to extract text from the file.';
//       }
//     } else {
//       status.value = 'No file selected.';
//     }
//
//     isLoading.value = false;
//   }
//
//   Future<String> _extractTextFromPdf(File file) async {
//     try {
//       final bytes = await file.readAsBytes();
//       final document = PdfDocument(inputBytes: bytes);
//       final extractor = PdfTextExtractor(document);
//       String text = extractor.extractText();
//       document.dispose();
//       return text;
//     } catch (e) {
//       print('PDF error: $e');
//       return '';
//     }
//   }
//
//   Future<String> _extractTextFromImage(File file) async {
//     try {
//       final inputImage = InputImage.fromFile(file);
//       final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//       final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
//       return recognizedText.text;
//     } catch (e) {
//       print('Image OCR error: $e');
//       return '';
//     }
//   }
//
//   Future<int> _analyzeWithGemini(String reportText) async {
//     try {
//       final uri = Uri.parse('$_geminiEndpoint?key=$_geminiApiKey');
//       final body = jsonEncode({
//         'contents': [
//           {
//             'parts': [
//               {
//                 'text':
//                 'Here is a medical report. Please give a health score from 0 to 100 based on overall health status only. Report: $reportText'
//               }
//             ]
//           }
//         ]
//       });
//
//       final response = await http.post(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final text = data['candidates'][0]['content']['parts'][0]['text'];
//         final score = _extractScoreFromText(text);
//         return score;
//       } else {
//         print('Gemini error: ${response.body}');
//         return 0;
//       }
//     } catch (e) {
//       print('Gemini exception: $e');
//       return 0;
//     }
//   }
//
//   void reset() {
//     healthScore.value = 0;
//     status.value = 'No report uploaded yet.';
//   }
//
//   int _extractScoreFromText(String responseText) {
//     final regex = RegExp(r'(\d{1,3})');
//     final match = regex.firstMatch(responseText);
//     if (match != null) {
//       int value = int.parse(match.group(0)!);
//       return value.clamp(0, 100);
//     }
//     return 0;
//   }
// }
//
// class ReportScoreScreen extends StatelessWidget {
//   ReportScoreScreen({super.key});
//   final ReportScoreController controller = Get.put(ReportScoreController());
//
//   Color _getProgressColor(int score) {
//     if (score >= 75) return Colors.green.shade600;
//     if (score >= 40) return Colors.orange.shade600;
//     return Colors.red.shade600;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         title: const Text(
//           'Health Report Analysis',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded, color: Colors.white),
//             onPressed: () {
//               controller.reset();
//               Get.snackbar(
//                 'Refreshed',
//                 'Health score reset successfully.',
//                 snackPosition: SnackPosition.BOTTOM,
//                 backgroundColor: AppTheme.successColor.withOpacity(0.9),
//                 colorText: Colors.white,
//                 duration: const Duration(seconds: 2),
//                 borderRadius: 12,
//                 margin: const EdgeInsets.all(16),
//               );
//             },
//             tooltip: 'Reset',
//           ),
//         ],
//       ),
//       body: Obx(
//             () => Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.grey.shade100, Colors.white],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             child: Center(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 20),
//                     Text(
//                       'Your Health Score',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w700,
//                         color: AppTheme.textPrimary,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Upload your medical report to get a comprehensive health score.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: AppTheme.textSecondary,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     Card(
//                       elevation: 8,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           gradient: LinearGradient(
//                             colors: [Colors.white, Colors.grey.shade50],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(28),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.insert_drive_file_rounded,
//                                 size: 70,
//                                 color: AppTheme.primaryColor.withOpacity(0.9),
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 controller.status.value,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                   color: AppTheme.textSecondary,
//                                 ),
//                               ),
//                               const SizedBox(height: 32),
//                               if (controller.healthScore.value > 0)
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 1200),
//                                   curve: Curves.easeInOut,
//                                   child: CircularPercentIndicator(
//                                     radius: 120.0,
//                                     lineWidth: 16.0,
//                                     animation: true,
//                                     animationDuration: 1500,
//                                     percent: controller.healthScore.value / 100,
//                                     center: Text(
//                                       "${controller.healthScore.value}%",
//                                       style: const TextStyle(
//                                         fontSize: 32,
//                                         fontWeight: FontWeight.bold,
//                                         color: AppTheme.textPrimary,
//                                       ),
//                                     ),
//                                     progressColor: _getProgressColor(controller.healthScore.value),
//                                     backgroundColor: Colors.grey.shade200,
//                                     circularStrokeCap: CircularStrokeCap.round,
//                                     arcType: ArcType.FULL,
//                                   ),
//                                 ),
//                               const SizedBox(height: 32),
//                               controller.isLoading.value
//                                   ? CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
//                               )
//                                   : ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                                   backgroundColor: AppTheme.primaryColor,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   elevation: 5,
//                                   shadowColor: AppTheme.primaryColor.withOpacity(0.4),
//                                 ),
//                                 onPressed: controller.pickReport,
//                                 icon: const Icon(Icons.upload_file, size: 24),
//                                 label: const Text(
//                                   "Upload Report",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'Supported formats: PDF, PNG, JPG, JPEG',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppTheme.textSecondary.withOpacity(0.7),
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../theme/app_theme.dart';

class ReportScoreController extends GetxController {
  // Observables
  final isLoading = false.obs;
  final healthScore = 0.obs;
  final status = 'No report uploaded yet.'.obs;
  final isRecommendationsExpanded = false.obs;
  final recommendations = <Map<String, String>>[].obs;

  // Gemini API configuration
  static const _geminiApiKey = 'AIzaSyAV7w2enmsaCZa-JpMRraglmWHlDbqs1Dg';
  static const _geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // Medical keywords for validation
  static const _medicalKeywords = [
    'diagnosis',
    'blood',
    'pressure',
    'cholesterol',
    'glucose',
    'heart',
    'liver',
    'kidney',
    'thyroid',
    'patient',
    'test',
    'report',
    'lab',
    'results',
    'medical',
  ];

  /// Picks a file (PDF or image) and processes it to generate a health score and recommendations.
  Future<void> pickReport() async {
    isLoading.value = true;
    status.value = 'Processing report...';
    healthScore.value = 0;
    recommendations.clear();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      String text = '';

      if (file.path.endsWith('.pdf')) {
        text = await _extractTextFromPdf(file);
      } else {
        text = await _extractTextFromImage(file);
      }

      if (text.isNotEmpty) {
        if (_isMedicalReport(text)) {
          final analysis = await _analyzeWithGemini(text);
          healthScore.value = analysis['score'] ?? 0;
          recommendations.assignAll(analysis['recommendations'] ?? []);
          status.value = 'Health score and recommendations generated successfully!';
          isRecommendationsExpanded.value = true;
        } else {
          status.value = 'No medical information found in the file.';
          Get.snackbar(
            'Invalid Report',
            'The uploaded file does not contain valid medical information.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600.withOpacity(0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        }
      } else {
        status.value = 'Unable to extract text from the file.';
      }
    } else {
      status.value = 'No file selected.';
    }

    isLoading.value = false;
  }

  /// Extracts text from a PDF file using Syncfusion PDF library.
  Future<String> _extractTextFromPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      print('PDF error: $e');
      return '';
    }
  }

  /// Extracts text from an image using Google ML Kit Text Recognition.
  Future<String> _extractTextFromImage(File file) async {
    try {
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text;
      textRecognizer.close();
      return text;
    } catch (e) {
      print('Image OCR error: $e');
      return '';
    }
  }

  /// Analyzes the report text using Gemini API to get a health score and recommendations.
  Future<Map<String, dynamic>> _analyzeWithGemini(String reportText) async {
    try {
      final uri = Uri.parse('$_geminiEndpoint?key=$_geminiApiKey');
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
Analyze the following medical report and provide:
1. A health score from 0 to 100 based on overall health status.
2. Three specific, actionable health recommendations tailored to the report, each with a title and description.
Return the response in JSON format with fields "score" (integer) and "recommendations" (array of objects with "title" and "description").
Report: $reportText
'''
              },
            ],
          },
        ],
      });

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return _parseGeminiResponse(text);
      } else {
        print('Gemini error: ${response.body}');
        return {'score': 0, 'recommendations': []};
      }
    } catch (e) {
      print('Gemini exception: $e');
      return {'score': 0, 'recommendations': []};
    }
  }

  /// Parses the Gemini API response to extract score and recommendations.
  Map<String, dynamic> _parseGeminiResponse(String responseText) {
    try {
      final cleanedText = responseText.replaceAll(RegExp(r'```json|```'), '').trim();
      final jsonData = jsonDecode(cleanedText);
      final score = (jsonData['score'] as num?)?.toInt() ?? 0;
      final recommendations = (jsonData['recommendations'] as List<dynamic>?)
          ?.map((item) => {
        'title': item['title']?.toString() ?? 'Recommendation',
        'description': item['description']?.toString() ?? 'Follow this recommendation to improve your health.',
      })
          .toList() ??
          [];
      return {
        'score': score.clamp(0, 100),
        'recommendations': recommendations,
      };
    } catch (e) {
      print('Parsing error: $e');
      return {'score': 0, 'recommendations': []};
    }
  }

  /// Checks if the extracted text contains medical-related information.
  bool _isMedicalReport(String text) {
    final lowerText = text.toLowerCase();
    return _medicalKeywords.any((keyword) => lowerText.contains(keyword));
  }

  /// Resets the controller state to initial values.
  void reset() {
    healthScore.value = 0;
    status.value = 'No report uploaded yet.';
    isRecommendationsExpanded.value = false;
    recommendations.clear();
  }

  /// Returns the list of recommendations.
  List<Map<String, String>> getHealthRecommendations(int score) {
    return recommendations;
  }

  /// Returns the score category based on the health score.
  String getScoreCategory(int score) {
    if (score >= 75) return 'High';
    if (score >= 40) return 'Moderate';
    return 'Low';
  }
}

class ReportScoreScreen extends StatelessWidget {
  ReportScoreScreen({super.key});

  final ReportScoreController controller = Get.put(ReportScoreController());

  Color _getProgressColor(int score) {
    if (score >= 75) return Colors.green.shade600;
    if (score >= 40) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Health Report Analysis',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              controller.reset();
              Get.snackbar(
                'Refreshed',
                'Health score and recommendations reset successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.successColor.withOpacity(0.9),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
              );
            },
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Obx(
            () => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Your Health Score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your medical report to get a comprehensive health score and recommendations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insert_drive_file_rounded,
                                size: 70,
                                color: AppTheme.primaryColor.withOpacity(0.9),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.status.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (controller.healthScore.value > 0)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 1200),
                                      curve: Curves.easeInOut,
                                      child: CircularPercentIndicator(
                                        radius: 120.0,
                                        lineWidth: 16.0,
                                        animation: true,
                                        animationDuration: 1500,
                                        percent: controller.healthScore.value / 100,
                                        center: Text(
                                          "${controller.healthScore.value}%",
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        progressColor: _getProgressColor(controller.healthScore.value),
                                        backgroundColor: Colors.grey.shade200,
                                        circularStrokeCap: CircularStrokeCap.round,
                                        arcType: ArcType.FULL,
                                      ),
                                    ),
                                    Positioned(
                                      top: 145,
                                      right: 80,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getProgressColor(controller.healthScore.value)
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _getProgressColor(controller.healthScore.value)
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          controller.getScoreCategory(controller.healthScore.value),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _getProgressColor(controller.healthScore.value),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  controller.isLoading.value
                                      ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryColor,
                                    ),
                                  )
                                      : ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                      shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                                    ),
                                    onPressed: controller.pickReport,
                                    icon: const Icon(Icons.upload_file, size: 24),
                                    label: const Text(
                                      'Upload Report',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (controller.healthScore.value > 0) ...[
                      const SizedBox(height: 32),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                title: Text(
                                  'Health Improvement Tips',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    controller.isRecommendationsExpanded.value
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    controller.isRecommendationsExpanded.toggle();
                                  },
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: controller.isRecommendationsExpanded.value
                                    ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    children: controller
                                        .getHealthRecommendations(controller.healthScore.value)
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) => _RecommendationItem(
                                        index: entry.key,
                                        title: entry.value['title']!,
                                        description: entry.value['description']!,
                                        color: _getProgressColor(controller.healthScore.value),
                                        onTap: () {
                                          Get.snackbar(
                                            entry.value['title']!,
                                            'More details on this recommendation will be available soon.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor:
                                            AppTheme.primaryColor.withOpacity(0.9),
                                            colorText: Colors.white,
                                            duration: const Duration(seconds: 2),
                                            borderRadius: 12,
                                            margin: const EdgeInsets.all(16),
                                          );
                                        },
                                      ),
                                    )
                                        .toList(),
                                  ),
                                )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Supported formats: PDF, PNG, JPG, JPEG',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RecommendationItem({
    required this.index,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}