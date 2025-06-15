import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medlytic/screens/profile_screen.dart';

import 'dart:io';

import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/firebase_controller.dart';
import '../services/file_service.dart';
import '../services/ocr_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/language_selector.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_upload_card.dart';
import '../widgets/status_indicator.dart';
import 'analysis_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final AppController controller = Get.find<AppController>();
  final AuthController authController = Get.find<AuthController>();
  final FirebaseController firebaseController = Get.find<FirebaseController>();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _selectImageFile() async {
    try {
      final source = await Get.bottomSheet(
        Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                String title = controller.currentLanguage.value == 'ur'
                    ? 'تصویر کا ذریعہ منتخب کریں'
                    : 'Select Image Source';
                return Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      bool isUrdu = controller.currentLanguage.value == 'ur';
                      return PremiumUploadCard(
                        icon: Icons.camera_alt_rounded,
                        title: isUrdu ? 'کیمرا' : 'Camera',
                        subtitle: isUrdu ? 'تصویر لیں' : 'Take a photo',
                        iconColor: AppTheme.primaryColor,
                        onTap: () => Get.back(result: ImageSource.camera),
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() {
                      bool isUrdu = controller.currentLanguage.value == 'ur';
                      return PremiumUploadCard(
                        icon: Icons.photo_library_rounded,
                        title: isUrdu ? 'گیلری' : 'Gallery',
                        subtitle: isUrdu ? 'گیلری سے منتخب کریں' : 'Choose from gallery',
                        iconColor: AppTheme.accentColor,
                        onTap: () => Get.back(result: ImageSource.gallery),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );

      if (source != null) {
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );

        if (image != null) {
          File file = File(image.path);
          String fileName = image.name;
          await controller.uploadReport(file, fileName, false);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
      );
    }
  }

  Future<void> _selectPdfFile() async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(() {
              bool isUrdu = controller.currentLanguage.value == 'ur';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    isUrdu ? 'فائل پکر کھولا جا رہا ہے...' : 'Opening file picker...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        barrierDismissible: false,
      );

      File? selectedFile = await FileService.pickPdfFile();
      Get.back(); // Close file picker dialog

      if (selectedFile == null) {
        String message = controller.currentLanguage.value == 'ur'
            ? 'براہ کرم جاری رکھنے کے لیے PDF فائل منتخب کریں'
            : 'Please select a PDF file to continue';

        Get.snackbar(
          'No File Selected',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.warningColor.withOpacity(0.1),
          colorText: AppTheme.warningColor,
        );
        return;
      }

      // Show processing dialog
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(() {
              bool isUrdu = controller.currentLanguage.value == 'ur';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isUrdu ? 'PDF کا تجزیہ ہو رہا ہے...' : 'Analyzing PDF content...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUrdu ? 'طبی مواد کی تصدیق' : 'Validating medical content',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        barrierDismissible: false,
      );

      // STEP 1: Debug PDF extraction first
      await FileService.debugPdfExtraction(selectedFile);

      // STEP 2: Validate PDF file
      bool isValid = await FileService.validatePdfFile(selectedFile);
      if (!isValid) {
        Get.back(); // Close processing dialog
        String message = controller.currentLanguage.value == 'ur'
            ? 'براہ کرم 10MB سے کم کی درست PDF فائل منتخب کریں'
            : 'Please select a valid PDF file under 10MB';

        Get.snackbar(
          'Invalid File',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
          colorText: AppTheme.errorColor,
        );
        return;
      }

      OCRService ocrService = OCRService();
      String? extractedText = await ocrService.extractText(selectedFile, true);
      ocrService.dispose();
      // STEP 3: Extract text from PDF (using your FileService)
      // String? extractedText = await OCRService.extractTextFromPdf(selectedFile);

      if (extractedText == null || extractedText.trim().isEmpty) {
        Get.back(); // Close processing dialog
        await _showExtractionFailedDialog();
        return;
      }

      // STEP 4: VALIDATE HEALTH CONTENT - THIS IS WHERE WE USE IT!
      bool isHealthRelated = await _validateHealthContent(extractedText);
      Get.back(); // Close processing dialog

      if (!isHealthRelated) {
        await _showNonMedicalContentDialog(extractedText);
        return;
      }

      // STEP 5: Success - proceed with upload
      String fileName = selectedFile.path.split('/').last;
      int fileSizeInBytes = await selectedFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      String message = controller.currentLanguage.value == 'ur'
          ? 'طبی رپورٹ تصدیق شدہ: $fileName (${fileSizeInMB.toStringAsFixed(2)} MB)'
          : 'Medical report validated: $fileName (${fileSizeInMB.toStringAsFixed(2)} MB)';

      Get.snackbar(
        'Medical Report Validated',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor.withOpacity(0.1),
        colorText: AppTheme.successColor,
      );

      // Upload the validated medical report
      await controller.uploadReport(selectedFile, fileName, true);

    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();

      String message = controller.currentLanguage.value == 'ur'
          ? 'PDF فائل پروسیسنگ میں خرابی: $e'
          : 'PDF processing error: $e';

      Get.snackbar(
        'PDF Processing Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withOpacity(0.1),
        colorText: AppTheme.errorColor,
      );
    }
  }

  Future<void> _showExtractionFailedDialog() async {
    bool isUrdu = controller.currentLanguage.value == 'ur';

    await Get.dialog(
      AlertDialog(
        title: Text(isUrdu ? 'متن نہیں نکالا جا سکا' : 'Text Extraction Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUrdu
                  ? 'PDF سے پڑھنے کے قابل متن نہیں نکالا جا سکا۔'
                  : 'Could not extract readable text from the PDF.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              isUrdu ? 'ممکنہ وجوہات:' : 'Possible reasons:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isUrdu
                  ? '• یہ تصویری PDF ہے (اسکین شدہ)\n• PDF محفوظ یا خراب ہے\n• متن غیر معیاری انکوڈنگ میں ہے'
                  : '• This is an image-based PDF (scanned)\n• PDF is protected or corrupted\n• Text uses unsupported encoding',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isUrdu ? 'ٹھیک ہے' : 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNonMedicalContentDialog(String extractedText) async {
    bool isUrdu = controller.currentLanguage.value == 'ur';

    await Get.dialog(
      AlertDialog(
        title: Text(isUrdu ? 'غیر طبی مواد' : 'Non-Medical Content'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isUrdu
                    ? 'یہ دستاویز طبی رپورٹ نہیں لگتی۔'
                    : 'This document doesn\'t appear to be a medical report.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                isUrdu ? 'مواد کا نمونہ:' : 'Content preview:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  extractedText.length > 200
                      ? '${extractedText.substring(0, 200)}...'
                      : extractedText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isUrdu
                    ? 'براہ کرم طبی رپورٹ (لیب ٹیسٹ، خون کی جانچ، وغیرہ) اپ لوڈ کریں۔'
                    : 'Please upload a medical report (lab tests, blood work, etc.).',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isUrdu ? 'ٹھیک ہے' : 'OK'),
          ),
        ],
      ),
    );
  }

  // Future<void> _selectPdfFile() async {
  //   try {
  //     Get.dialog(
  //       Center(
  //         child: Container(
  //           padding: const EdgeInsets.all(24),
  //           decoration: BoxDecoration(
  //             color: AppTheme.surfaceColor,
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: Obx(() {
  //             bool isUrdu = controller.currentLanguage.value == 'ur';
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const CircularProgressIndicator(),
  //                 const SizedBox(height: 16),
  //                 Text(
  //                   isUrdu ? 'فائل پکر کھولا جا رہا ہے...' : 'Opening file picker...',
  //                   style: const TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             );
  //           }),
  //         ),
  //       ),
  //       barrierDismissible: false,
  //     );
  //
  //     File? selectedFile = await FileService.pickPdfFile();
  //     Get.back();
  //
  //     if (selectedFile == null) {
  //       String message = controller.currentLanguage.value == 'ur'
  //           ? 'براہ کرم جاری رکھنے کے لیے PDF فائل منتخب کریں'
  //           : 'Please select a PDF file to continue';
  //
  //       Get.snackbar(
  //         'No File Selected',
  //         message,
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppTheme.warningColor.withOpacity(0.1),
  //         colorText: AppTheme.warningColor,
  //       );
  //       return;
  //     }
  //     await FileService.debugPdfExtraction(selectedFile);
  //     bool isValid = await FileService.validatePdfFile(selectedFile);
  //
  //     if (!isValid) {
  //       String message = controller.currentLanguage.value == 'ur'
  //           ? 'براہ کرم 10MB سے کم کی درست PDF فائل منتخب کریں'
  //           : 'Please select a valid PDF file under 10MB';
  //
  //       Get.snackbar(
  //         'Invalid File',
  //         message,
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: AppTheme.errorColor.withOpacity(0.1),
  //         colorText: AppTheme.errorColor,
  //       );
  //       return;
  //     }
  //
  //     String fileName = selectedFile.path.split('/').last;
  //     int fileSizeInBytes = await selectedFile.length();
  //     double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
  //
  //     String message = controller.currentLanguage.value == 'ur'
  //         ? 'فائل: $fileName (${fileSizeInMB.toStringAsFixed(2)} MB)'
  //         : 'File: $fileName (${fileSizeInMB.toStringAsFixed(2)} MB)';
  //
  //     Get.snackbar(
  //       'PDF Selected',
  //       message,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: AppTheme.successColor.withOpacity(0.1),
  //       colorText: AppTheme.successColor,
  //     );
  //
  //     await controller.uploadReport(selectedFile, fileName, true);
  //
  //   } catch (e) {
  //     if (Get.isDialogOpen ?? false) Get.back();
  //
  //     String message = controller.currentLanguage.value == 'ur'
  //         ? 'PDF فائل منتخب کرنے میں ناکامی۔ براہ کرم دوبارہ کوشش کریں۔'
  //         : 'Failed to select PDF file. Please try again.';
  //
  //     Get.snackbar(
  //       'PDF Selection Error',
  //       message,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: AppTheme.errorColor.withOpacity(0.1),
  //       colorText: AppTheme.errorColor,
  //     );
  //   }
  // }

  void _refreshForNewUpload() {
    // Clear current report data
    controller.clearReport();

    // Show success message
    String message = controller.currentLanguage.value == 'ur'
        ? 'آپ اب نئی طبی رپورٹ اپ لوڈ کر سکتے ہیں'
        : 'You can now upload a new medical report';

    Get.snackbar(
      'Ready for New Upload',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor.withOpacity(0.1),
      colorText: AppTheme.successColor,
      duration: const Duration(seconds: 2),
    );
  }


  Future<bool> _validateHealthContent(String text) async {
    String lowerText = text.toLowerCase();

    List<String> healthKeywords = [
      // Basic medical terms
      'health', 'medical', 'patient', 'doctor', 'physician', 'hospital', 'clinic',

      // Tests and procedures
      'blood', 'test', 'lab', 'laboratory', 'diagnosis', 'treatment', 'examination',
      'medication', 'prescription', 'therapy', 'surgery', 'biopsy', 'screening',

      // Body systems and organs
      'heart', 'kidney', 'liver', 'lung', 'brain', 'bone', 'muscle', 'skin',

      // Common medical values and units
      'glucose', 'cholesterol', 'hemoglobin', 'pressure', 'mg/dl', 'mmhg', 'bpm',
      'g/dl', 'ml', 'units', 'normal', 'abnormal', 'high', 'low', 'elevated',

      // Report-specific terms
      'report', 'result', 'analysis', 'findings', 'specimen', 'sample',
      'urine', 'serum', 'plasma', 'count', 'level', 'range', 'reference',

      // Common medical conditions
      'diabetes', 'hypertension', 'infection', 'fever', 'pain', 'inflammation',

      // Document identifiers
      'date', 'name', 'age', 'gender', 'weight', 'height', 'temperature'
    ];

    int matchCount = 0;
    for (String keyword in healthKeywords) {
      if (lowerText.contains(keyword)) {
        matchCount++;
      }
    }

    print('🔍 Health keywords found: $matchCount');

    // LOWERED threshold from 3 to 1
    return matchCount >= 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medlytic',
                            style: TextStyle(color: Colors.black,fontSize: 34,fontWeight: FontWeight.bold),

                            // style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            //   background: Paint()
                            //     ..shader = AppTheme.primaryGradient.createShader(
                            //       const Rect.fromLTWH(0, 0, 200, 70),
                            //     ),
                            // ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            bool isUrdu = controller.currentLanguage.value == 'ur';
                            String welcomeText = isUrdu
                                ? 'خوش آمدید، ${authController.userModel.value?.displayName ?? 'صارف'}!'
                                : 'Welcome, ${authController.userModel.value?.displayName ?? 'User'}!';

                            return Text(
                              welcomeText,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Language selector
                        const LanguageSelector(),
                        const SizedBox(width: 12),

                        // Refresh button
                        // Obx(() {
                        //   if (controller.extractedText.value.isNotEmpty ||
                        //       controller.analysisResult.value.isNotEmpty) {
                        //     return Container(
                        //       margin: const EdgeInsets.only(right: 12),
                        //       decoration: BoxDecoration(
                        //         color: AppTheme.surfaceColor,
                        //         borderRadius: BorderRadius.circular(12),
                        //         boxShadow: AppTheme.cardShadow,
                        //       ),
                        //       child: IconButton(
                        //         icon: const Icon(Icons.refresh_rounded),
                        //         onPressed: _refreshForNewUpload,
                        //         color: AppTheme.accentColor,
                        //         tooltip: controller.currentLanguage.value == 'ur'
                        //             ? 'نئی رپورٹ اپ لوڈ کریں'
                        //             : 'Upload New Report',
                        //       ),
                        //     );
                        //   }
                        //   return const SizedBox.shrink();
                        // }),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: InkWell(
                            onTap: () => Get.to(() => ProfileScreen()),
                            child: CircleAvatar(

                                backgroundImage: AssetImage('assets/images/saad-img.jpg'),
                                // onPressed: () => Get.to(() => ProfileScreen()),
                                // color: AppTheme.primaryColor,
                              ),
                          ),
                          ),

                      ],
                    ),
                  ],
                ),

                // const SizedBox(height: 24),

                // Status indicators
                // Row(
                //   children: [
                //     Obx(() {
                //       bool isUrdu = controller.currentLanguage.value == 'ur';
                //       return StatusIndicator(
                //         isConnected: controller.apiConnectionStatus.value,
                //         connectedText: isUrdu ? 'AI جڑا ہوا' : 'AI Connected',
                //         disconnectedText: isUrdu ? 'آف لائن موڈ' : 'Offline Mode',
                //         connectedIcon: Icons.psychology_rounded,
                //         disconnectedIcon: Icons.psychology_outlined,
                //       );
                //     }),
                //     const SizedBox(width: 12),
                //     Obx(() {
                //       bool isUrdu = controller.currentLanguage.value == 'ur';
                //       return StatusIndicator(
                //         isConnected: firebaseController.isFirebaseConnected.value,
                //         connectedText: isUrdu ? 'کلاؤڈ سنک' : 'Cloud Sync',
                //         disconnectedText: isUrdu ? 'صرف مقامی' : 'Local Only',
                //         connectedIcon: Icons.cloud_done_rounded,
                //         disconnectedIcon: Icons.cloud_off_rounded,
                //       );
                //     }),
                //   ],
                // ),

                const SizedBox(height: 32),

                // Upload section
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.upload_file_rounded,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Obx(() {
                            bool isUrdu = controller.currentLanguage.value == 'ur';
                            return Text(
                              isUrdu ? 'طبی رپورٹ اپ لوڈ کریں' : 'Upload Medical Report',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        bool isUrdu = controller.currentLanguage.value == 'ur';
                        return Text(
                          isUrdu
                              ? 'AI سے بہتر بصیرت اور تجزیہ حاصل کرنے کے لیے اپنی طبی رپورٹ اپ لوڈ کریں'
                              : 'Upload your medical report to get AI-powered insights and analysis',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              bool isUrdu = controller.currentLanguage.value == 'ur';
                              return PremiumUploadCard(
                                icon: Icons.image_rounded,
                                title: isUrdu ? 'تصویری رپورٹ' : 'Image Report',
                                subtitle: isUrdu ? 'JPG, PNG فارمیٹس' : 'JPG, PNG formats',
                                iconColor: AppTheme.primaryColor,
                                onTap: _selectImageFile,
                              );
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() {
                              bool isUrdu = controller.currentLanguage.value == 'ur';
                              return PremiumUploadCard(
                                icon: Icons.picture_as_pdf_rounded,
                                title: isUrdu ? 'PDF رپورٹ' : 'PDF Report',
                                subtitle: isUrdu ? 'PDF دستاویزات' : 'PDF documents',
                                iconColor: AppTheme.errorColor,
                                onTap: _selectPdfFile,
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Upload progress
                Obx(() {
                  if (firebaseController.isUploading.value) {
                    return PremiumCard(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
                      child: Column(
                        children: [

                          Row(
                            children: [
                              const Icon(
                                Icons.cloud_upload_rounded,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Obx(() {
                                bool isUrdu = controller.currentLanguage.value == 'ur';
                                return Text(
                                  isUrdu ? 'اپ لوڈ ہو رہا ہے...' : 'Uploading...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                );
                              }),
                              const Spacer(),
                              Text(
                                '${(firebaseController.uploadProgress.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: firebaseController.uploadProgress.value,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Processing and extracted text
                Obx(() {
                  if (controller.isLoading.value && !firebaseController.isUploading.value) {
                    return PremiumCard(
                      backgroundColor: AppTheme.accentColor.withOpacity(0.05),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                          ),
                          const SizedBox(height: 16),
                          Obx(() {
                            bool isUrdu = controller.currentLanguage.value == 'ur';
                            return Text(
                              isUrdu ? 'آپ کی رپورٹ پر کام ہو رہا ہے...' : 'Processing your report...',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.accentColor,
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }

                  if (controller.extractedText.value.isNotEmpty) {
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
                                  Icons.text_snippet_rounded,
                                  color: AppTheme.accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Obx(() {
                                bool isUrdu = controller.currentLanguage.value == 'ur';
                                return Text(
                                  isUrdu ? 'نکالا گیا متن' : 'Extracted Text',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                );
                              }),
                              const SizedBox(width: 40),

                              Obx(() {
                                if (controller.extractedText.value.isNotEmpty ||
                                    controller.analysisResult.value.isNotEmpty) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: AppTheme.cardShadow,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.refresh_rounded),
                                      onPressed: _refreshForNewUpload,
                                      color: AppTheme.accentColor,
                                      tooltip: controller.currentLanguage.value == 'ur'
                                          ? 'نئی رپورٹ اپ لوڈ کریں'
                                          : 'Upload New Report',
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),

                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              controller.extractedText.value,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            bool isUrdu = controller.currentLanguage.value == 'ur';
                            return PremiumButton(
                              text: isUrdu ? 'رپورٹ کا تجزیہ کریں' : 'Analyze Report',
                              icon: Icons.analytics_rounded,
                              onPressed: () {
                                controller.analyzeReport().then((_) {
                                  Get.to(() => AnalysisScreen());
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 24),

                // Quick actions
                PremiumCard(
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
                              Icons.history_rounded,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Obx(() {
                            bool isUrdu = controller.currentLanguage.value == 'ur';
                            return Text(
                              isUrdu ? 'فوری اعمال' : 'Quick Actions',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        bool isUrdu = controller.currentLanguage.value == 'ur';
                        return PremiumButton(
                          text: isUrdu ? 'رپورٹ کی تاریخ دیکھیں' : 'View Report History',
                          icon: Icons.history_rounded,
                          isPrimary: false,
                          onPressed: () => Get.to(() => HistoryScreen()),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
