// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';
//
// class FileService {
//   static Future<File?> pickPdfFile() async {
//     try {
//       print('📄 Starting PDF file selection...');
//
//       // Method 1: Try standard file picker
//       try {
//         FilePickerResult? result = await FilePicker.platform.pickFiles(
//           type: FileType.custom,
//           allowedExtensions: ['pdf'],
//           allowMultiple: false,
//         );
//
//         if (result != null && result.files.isNotEmpty) {
//           PlatformFile file = result.files.first;
//
//           if (file.path != null) {
//             File selectedFile = File(file.path!);
//             if (await selectedFile.exists()) {
//               print('✅ PDF selected via method 1: ${file.name}');
//               return selectedFile;
//             }
//           }
//
//           // If path is null, try to copy from bytes
//           if (file.bytes != null) {
//             return await _createFileFromBytes(file.bytes!, file.name);
//           }
//         }
//       } catch (e) {
//         print('⚠️ Method 1 failed: $e');
//       }
//
//       // Method 2: Try with any file type and filter
//       try {
//         FilePickerResult? result = await FilePicker.platform.pickFiles(
//           type: FileType.any,
//           allowMultiple: false,
//         );
//
//         if (result != null && result.files.isNotEmpty) {
//           PlatformFile file = result.files.first;
//
//           // Check if it's a PDF
//           if (!file.name.toLowerCase().endsWith('.pdf')) {
//             throw Exception('Please select a PDF file only');
//           }
//
//           if (file.path != null) {
//             File selectedFile = File(file.path!);
//             if (await selectedFile.exists()) {
//               print('✅ PDF selected via method 2: ${file.name}');
//               return selectedFile;
//             }
//           }
//
//           // Try bytes method
//           if (file.bytes != null) {
//             return await _createFileFromBytes(file.bytes!, file.name);
//           }
//         }
//       } catch (e) {
//         print('⚠️ Method 2 failed: $e');
//       }
//
//       // Method 3: Try with media type
//       try {
//         FilePickerResult? result = await FilePicker.platform.pickFiles(
//           type: FileType.media,
//           allowMultiple: false,
//         );
//
//         if (result != null && result.files.isNotEmpty) {
//           PlatformFile file = result.files.first;
//
//           if (file.name.toLowerCase().endsWith('.pdf')) {
//             if (file.path != null) {
//               File selectedFile = File(file.path!);
//               if (await selectedFile.exists()) {
//                 print('✅ PDF selected via method 3: ${file.name}');
//                 return selectedFile;
//               }
//             }
//
//             if (file.bytes != null) {
//               return await _createFileFromBytes(file.bytes!, file.name);
//             }
//           }
//         }
//       } catch (e) {
//         print('⚠️ Method 3 failed: $e');
//       }
//
//       print('❌ All PDF selection methods failed');
//       return null;
//     } catch (e) {
//       print('❌ PDF file selection error: $e');
//       return null;
//     }
//   }
//
//   static Future<File> _createFileFromBytes(Uint8List bytes, String fileName) async {
//     try {
//       print('📄 Creating file from bytes: $fileName');
//
//       // Get temporary directory
//       Directory tempDir = await getTemporaryDirectory();
//       String tempPath = '${tempDir.path}/$fileName';
//
//       // Create file from bytes
//       File tempFile = File(tempPath);
//       await tempFile.writeAsBytes(bytes);
//
//       print('✅ File created from bytes: $tempPath');
//       return tempFile;
//     } catch (e) {
//       print('❌ Error creating file from bytes: $e');
//       rethrow;
//     }
//   }
//
//   static Future<bool> validatePdfFile(File file) async {
//     try {
//       // Check if file exists
//       if (!await file.exists()) {
//         print('❌ File does not exist');
//         return false;
//       }
//
//       // Check file size (max 10MB)
//       int fileSizeInBytes = await file.length();
//       double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
//
//       print('📊 File validation:');
//       print('   Size: ${fileSizeInMB.toStringAsFixed(2)} MB');
//       print('   Path: ${file.path}');
//
//       if (fileSizeInMB > 10) {
//         print('❌ File too large: ${fileSizeInMB.toStringAsFixed(2)} MB');
//         return false;
//       }
//
//       // Check if it's actually a PDF by reading first few bytes
//       try {
//         List<int> bytes = await file.readAsBytes();
//         if (bytes.length >= 4) {
//           String header = String.fromCharCodes(bytes.take(4));
//           if (header == '%PDF') {
//             print('✅ Valid PDF file confirmed');
//             return true;
//           }
//         }
//       } catch (e) {
//         print('⚠️ Could not validate PDF header: $e');
//         // Still return true if we can't read the header
//         return true;
//       }
//
//       print('✅ File validation passed');
//       return true;
//     } catch (e) {
//       print('❌ File validation error: $e');
//       return false;
//     }
//   }
// }


import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:medlytic/services/pdf_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileService {


  // Add this method to your FileService class for debugging
  static Future<void> debugPdfExtraction(File file) async {
    try {
      print('🔍 DEBUG: Starting PDF analysis...');

      // Method 1: Check with Syncfusion (what you should be using)
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      PdfTextExtractor extractor = PdfTextExtractor(document);
      String syncfusionText = extractor.extractText();
      document.dispose();

      print('📄 SYNCFUSION EXTRACTED TEXT:');
      print('Length: ${syncfusionText.length}');
      print('Content: ${syncfusionText.substring(0, syncfusionText.length > 500 ? 500 : syncfusionText.length)}');
      print('---END SYNCFUSION---');

      // Method 2: Check what PdfService extracts
      String pdfServiceText = await PdfService.extractTextFromPdf(file);
      print('📄 PDFSERVICE EXTRACTED TEXT:');
      print('Length: ${pdfServiceText.length}');
      print('Content: ${pdfServiceText.substring(0, pdfServiceText.length > 500 ? 500 : pdfServiceText.length)}');
      print('---END PDFSERVICE---');

      // Check which one has actual medical content
      print('🔍 SYNCFUSION has medical keywords: ${_hasAnyMedicalKeywords(syncfusionText)}');
      print('🔍 PDFSERVICE has medical keywords: ${_hasAnyMedicalKeywords(pdfServiceText)}');

    } catch (e) {
      print('❌ DEBUG ERROR: $e');
    }
  }

  static bool _hasAnyMedicalKeywords(String text) {
    List<String> keywords = ['blood', 'glucose', 'cholesterol', 'pressure', 'test', 'lab', 'patient', 'doctor', 'medical', 'report', 'normal', 'abnormal'];
    String lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword));
  }

  static Future<File?> pickPdfFile() async {
    try {
      print('📄 Starting PDF file selection...');

      File? selectedFile;

      // Method 1
      selectedFile = await _tryPickFile(FileType.custom, ['pdf']);
      if (selectedFile != null) {
        return await _validateAndAnalyze(selectedFile);
      }

      // Method 2
      selectedFile = await _tryPickFile(FileType.any);
      if (selectedFile != null && selectedFile.path.toLowerCase().endsWith('.pdf')) {
        return await _validateAndAnalyze(selectedFile);
      }

      // Method 3
      selectedFile = await _tryPickFile(FileType.media);
      if (selectedFile != null && selectedFile.path.toLowerCase().endsWith('.pdf')) {
        return await _validateAndAnalyze(selectedFile);
      }

      print('❌ All PDF selection methods failed');
      return null;
    } catch (e) {
      print('❌ PDF file selection error: $e');
      return null;
    }
  }

  static Future<File?> _tryPickFile(FileType type, [List<String>? extensions]) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: extensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.path != null) {
          File selectedFile = File(file.path!);
          if (await selectedFile.exists()) {
            print('✅ PDF selected: ${file.name}');
            return selectedFile;
          }
        }

        if (file.bytes != null) {
          return await _createFileFromBytes(file.bytes!, file.name);
        }
      }
    } catch (e) {
      print('⚠️ Pick file failed: $e');
    }
    return null;
  }

  static Future<File> _createFileFromBytes(Uint8List bytes, String fileName) async {
    try {
      print('📄 Creating file from bytes: $fileName');

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$fileName';

      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);

      print('✅ File created from bytes: $tempPath');
      return tempFile;
    } catch (e) {
      print('❌ Error creating file from bytes: $e');
      rethrow;
    }
  }

  static Future<bool> validatePdfFile(File file) async {
    try {
      if (!await file.exists()) {
        print('❌ File does not exist');
        return false;
      }

      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      print('📊 File validation:');
      print('   Size: ${fileSizeInMB.toStringAsFixed(2)} MB');
      print('   Path: ${file.path}');

      if (fileSizeInMB > 10) {
        print('❌ File too large: ${fileSizeInMB.toStringAsFixed(2)} MB');
        return false;
      }

      List<int> bytes = await file.readAsBytes();
      if (bytes.length >= 4) {
        String header = String.fromCharCodes(bytes.take(4));
        if (header == '%PDF') {
          print('✅ Valid PDF file confirmed');
          return true;
        }
      }

      print('⚠️ Could not confirm PDF header, but continuing');
      return true;
    } catch (e) {
      print('❌ File validation error: $e');
      return false;
    }
  }

  static Future<File?> _validateAndAnalyze(File file) async {
    bool isValid = await validatePdfFile(file);
    if (!isValid) return null;

    await analyzePdfForHealthTerms(file);
    return file;
  }

  // static Future<void> analyzePdfForHealthTerms(File file) async {
  //   try {
  //     print('🔍 Extracting text from PDF...');
  //     final List<int> bytes = await file.readAsBytes();
  //     final PdfDocument document = PdfDocument(inputBytes: bytes);
  //
  //     PdfTextExtractor extractor = PdfTextExtractor(document);
  //     String text = extractor.extractText();
  //     document.dispose();
  //
  //     print("📄 Extracted Text Length: ${text.length}");
  //     print("📄 First 300 chars: ${text.substring(0, text.length > 300 ? 300 : text.length)}...");
  //
  //     // Expanded medical keyword list
  //     List<String> medicalKeywords = [
  //       'health', 'medical', 'patient', 'doctor', 'hospital', 'clinic',
  //       'blood', 'test', 'lab', 'laboratory', 'diagnosis', 'treatment',
  //       'medication', 'prescription', 'therapy', 'surgery', 'examination',
  //       'glucose', 'cholesterol', 'hemoglobin', 'pressure', 'heart',
  //       'kidney', 'liver', 'mg/dl', 'mmhg', 'bpm', 'normal', 'abnormal',
  //       'report', 'result', 'analysis', 'findings', 'specimen', 'urine',
  //       'serum', 'plasma', 'count', 'level', 'range', 'reference',"Biopsy"
  //     ];
  //
  //     String lowerText = text.toLowerCase();
  //     int matchCount = 0;
  //     List<String> foundKeywords = [];
  //
  //     for (String keyword in medicalKeywords) {
  //       if (lowerText.contains(keyword)) {
  //         matchCount++;
  //         foundKeywords.add(keyword);
  //       }
  //     }
  //
  //     print('🔍 Medical keywords found: $matchCount');
  //     print('📋 Found keywords: ${foundKeywords.take(10).join(', ')}');
  //
  //     if (matchCount >= 2) {  // Lowered from 3 to 2
  //       print('✅ Health-related content found');
  //     } else {
  //       print('❌ No sufficient health-related content found');
  //     }
  //   } catch (e) {
  //     print('❌ Failed to extract/analyze PDF content: $e');
  //   }
  // }

  static Future<void> analyzePdfForHealthTerms(File file) async {
    try {
      print('🔍 Extracting text from PDF...');
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      PdfTextExtractor extractor = PdfTextExtractor(document);
      String text = extractor.extractText();
      document.dispose();

      print("📄 Extracted Text Length: ${text.length}");
      print("📄 First 500 chars: ${text.substring(0, text.length > 500 ? 500 : text.length)}...");

      // COMPREHENSIVE medical keyword list
      List<String> medicalKeywords = [
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
        'date', 'name', 'age', 'gender', 'weight', 'height', 'temperature',
        'pulse', 'collected', 'received', 'tested', 'interpreted'
      ];

      String lowerText = text.toLowerCase();
      int matchCount = 0;
      List<String> foundKeywords = [];

      for (String keyword in medicalKeywords) {
        if (lowerText.contains(keyword)) {
          matchCount++;
          foundKeywords.add(keyword);
        }
      }

      print('🔍 Medical keywords found: $matchCount');
      print('📋 Found keywords: ${foundKeywords.take(15).join(', ')}');

      // LOWERED threshold - only need 1 medical keyword
      if (matchCount >= 1) {
        print('✅ Health-related content found');
      } else {
        print('❌ No health-related content found');
        print('📄 Full text for debugging: $text'); // Debug output
      }
    } catch (e) {
      print('❌ Failed to extract/analyze PDF content: $e');
    }
  }

}
