import 'package:get/get.dart';

import 'dart:io';
import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';
import 'auth_controller.dart';
import 'firebase_controller.dart';

class AppController extends GetxController {
  final FirebaseController _firebaseController = Get.find<FirebaseController>();
  final AuthController _authController = Get.find<AuthController>();
  final OCRService _ocrService = OCRService();
  final AIService _aiService = AIService();

  // Observable variables
  var isLoading = false.obs;
  var extractedText = ''.obs;
  var analysisResult = ''.obs;
  var selectedFile = Rx<File?>(null);
  var reportHistory = <ReportModel>[].obs;
  var currentReport = Rx<ReportModel?>(null);
  var apiConnectionStatus = false.obs;
  var currentFileType = ''.obs;
  var currentLanguage = 'en'.obs; // Default to English

  @override
  void onInit() {
    super.onInit();
    print('🚀 Initializing AppController...');
    loadReportHistory();
    testApiConnection();
  }

  // Set language for analysis and voice
  void setLanguage(String language) {
    currentLanguage.value = language;
    print('🌐 Language set to: $language');
  }

  // Test API connection on app start
  Future<void> testApiConnection() async {
    try {
      print('🔍 Testing API connection...');
      apiConnectionStatus.value = await _aiService.testConnection();

      if (apiConnectionStatus.value) {
        print('✅ API connected successfully');
        Get.snackbar(
          'API Connected',
          'Gemini AI is ready for medical analysis',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('⚠️ API connection failed, using offline mode');
        Get.snackbar(
          'Offline Mode',
          'Using demo analysis - all features available',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ API connection test error: $e');
      apiConnectionStatus.value = false;
    }
  }

  // Load user's report history
  void loadReportHistory() {
    if (_authController.isLoggedIn) {
      print('📋 Loading report history...');
      _firebaseController.getUserReports().listen((reports) {
        reportHistory.value = reports;
        print('📊 Loaded ${reports.length} reports');
      });
    }
  }

  // Upload and process report
  Future<void> uploadReport(File file, String fileName, bool isPdf) async {
    try {
      print('📤 Starting upload process for: $fileName');
      print('📄 File type: ${isPdf ? 'PDF' : 'Image'}');
      print('📏 File size: ${await file.length()} bytes');

      isLoading.value = true;
      selectedFile.value = file;
      currentFileType.value = isPdf ? 'pdf' : 'image';

      // Clear previous results
      extractedText.value = '';
      analysisResult.value = '';

      // Upload file to Firebase Storage (or mock)
      String? fileUrl = await _firebaseController.uploadFile(
          file,
          fileName,
          isPdf ? 'pdf' : 'image'
      );

      if (fileUrl == null) {
        throw Exception('Failed to upload file to storage');
      }

      print('✅ File uploaded successfully: $fileUrl');

      // Extract text using OCR
      print('🔍 Starting text extraction...');
      print('📄 Processing ${isPdf ? 'PDF' : 'Image'} file...');

      try {
        String extractedTextResult = await _ocrService.extractText(file, isPdf);

        if (extractedTextResult.isEmpty) {
          throw Exception('No text could be extracted from the ${isPdf ? 'PDF' : 'image'}');
        }

        // Validate extracted text quality
        if (extractedTextResult.length < 10) {
          throw Exception('Very little text was extracted. Please use a clearer ${isPdf ? 'PDF' : 'image'} with more readable content.');
        }

        extractedText.value = extractedTextResult;
        print('✅ Text extraction completed: ${extractedTextResult.length} characters');
        print('📝 First 200 chars: ${extractedTextResult.substring(0, extractedTextResult.length > 200 ? 200 : extractedTextResult.length)}...');

        // Create report model with actual extracted text
        currentReport.value = ReportModel(
          id: '',
          userId: _authController.currentUserId,
          fileName: fileName,
          fileUrl: fileUrl,
          extractedText: extractedTextResult,
          analysisResult: '',
          createdAt: DateTime.now(),
          fileType: isPdf ? 'pdf' : 'image',
        );

        Get.snackbar(
          'Success',
          '${isPdf ? 'PDF' : 'Image'} uploaded and text extracted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 3),
        );

      } catch (extractionError) {
        print('❌ Text extraction failed: $extractionError');
        Get.snackbar(
          'Extraction Error',
          'Failed to extract text from ${isPdf ? 'PDF' : 'image'}: ${extractionError.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange.shade800,
          duration: const Duration(seconds: 5),
        );
        throw extractionError;
      }

    } catch (e) {
      print('❌ Upload error: $e');
      Get.snackbar(
        'Upload Error',
        'Failed to process ${isPdf ? 'PDF' : 'image'}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Analyze report using AI with language support
  Future<void> analyzeReport() async {
    if (currentReport.value == null || extractedText.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No report content available for analysis',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      print('🤖 Starting AI analysis in language: ${currentLanguage.value}');
      print('📄 Analyzing ${currentFileType.value} content...');
      print('📝 Text length: ${extractedText.value.length} characters');
      print('📋 First 100 chars: ${extractedText.value.substring(0, extractedText.value.length > 100 ? 100 : extractedText.value.length)}...');

      isLoading.value = true;

      // Show progress message
      String progressMessage = currentLanguage.value == 'ur'
          ? 'AI آپ کی ${currentFileType.value} طبی رپورٹ کا تجزیہ کر رہا ہے...'
          : 'AI is analyzing your ${currentFileType.value} medical report...';

      Get.snackbar(
        'Analyzing',
        progressMessage,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Get AI analysis with language parameter
      String analysis = await _aiService.analyzeReport(
          extractedText.value,
          language: currentLanguage.value
      );

      if (analysis.isEmpty) {
        throw Exception('AI analysis returned empty result');
      }

      analysisResult.value = analysis;

      // Update current report with analysis
      currentReport.value = ReportModel(
        id: currentReport.value!.id,
        userId: currentReport.value!.userId,
        fileName: currentReport.value!.fileName,
        fileUrl: currentReport.value!.fileUrl,
        extractedText: currentReport.value!.extractedText,
        analysisResult: analysis,
        createdAt: currentReport.value!.createdAt,
        fileType: currentReport.value!.fileType,
      );

      print('✅ AI analysis completed for ${currentFileType.value} in ${currentLanguage.value}');
      print('📊 Analysis length: ${analysis.length} characters');

      String successMessage = currentLanguage.value == 'ur'
          ? 'آپ کی ${currentFileType.value} طبی رپورٹ کا تجزیہ کامیابی سے مکمل ہو گیا'
          : 'Your ${currentFileType.value} medical report has been analyzed successfully';

      Get.snackbar(
        'Analysis Complete',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      print('❌ Analysis error: $e');
      String errorMessage = currentLanguage.value == 'ur'
          ? '${currentFileType.value} رپورٹ کا تجزیہ ناکام: ${e.toString()}'
          : 'Failed to analyze ${currentFileType.value} report: ${e.toString()}';

      Get.snackbar(
        'Analysis Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Save report to history
  Future<void> saveReportToHistory() async {
    if (currentReport.value == null) return;

    try {
      print('💾 Saving ${currentFileType.value} report to history...');
      String? reportId = await _firebaseController.saveReport(currentReport.value!);

      if (reportId != null) {
        print('✅ ${currentFileType.value} report saved with ID: $reportId');
        String successMessage = currentLanguage.value == 'ur'
            ? '${currentFileType.value.toUpperCase()} رپورٹ تاریخ میں محفوظ ہو گئی'
            : '${currentFileType.value.toUpperCase()} report saved to history';

        Get.snackbar(
          'Success',
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Save error: $e');
      String errorMessage = currentLanguage.value == 'ur'
          ? '${currentFileType.value} رپورٹ محفوظ کرنے میں ناکامی: $e'
          : 'Failed to save ${currentFileType.value} report: $e';

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Clear current report
  void clearReport() {
    print('🗑️ Clearing current report');
    selectedFile.value = null;
    extractedText.value = '';
    analysisResult.value = '';
    currentReport.value = null;
    currentFileType.value = '';
  }

  // Delete report from history
  Future<void> deleteReport(ReportModel report) async {
    print('🗑️ Deleting ${report.fileType} report: ${report.fileName}');
    await _firebaseController.deleteReport(report.id, report.fileUrl);
  }
}
