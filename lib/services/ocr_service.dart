// import 'dart:io';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:medlytic/services/pdf_service.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
//
// class OCRService {
//   final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
//
//   Future<String> extractText(File file, bool isPdf) async {
//     try {
//       print('🔍 Starting text extraction for file: ${file.path}');
//       print('📁 File exists: ${await file.exists()}');
//       print('📏 File size: ${await file.length()} bytes');
//       print('📄 Is PDF: $isPdf');
//
//       if (isPdf) {
//         print('📄 Processing PDF file...');
//         return await _extractTextFromPdf(file);
//       } else {
//         print('🖼️ Processing image file...');
//         return await _extractTextFromImage(file);
//       }
//     } catch (e) {
//       print('❌ OCR Error: $e');
//       // Only return sample text for images, not PDFs
//       if (!isPdf) {
//         throw Exception('OCR failed: ${e.toString()}');
//       } else {
//         return 'Error processing PDF file. Please try again or use an image instead.';
//       }
//     }
//   }
//
//   // Future<String> _extractTextFromImage(File imageFile) async {
//   //   try {
//   //     print('🔄 Processing image file: ${imageFile.path}');
//   //     print('📏 File size: ${await imageFile.length()} bytes');
//   //
//   //     final InputImage inputImage = InputImage.fromFile(imageFile);
//   //     final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
//   //
//   //     List<String> extractedLines = [];
//   //
//   //     // Extract text from all blocks and lines
//   //     for (TextBlock block in recognizedText.blocks) {
//   //       for (TextLine line in block.lines) {
//   //         String lineText = line.text.trim();
//   //         if (lineText.isNotEmpty && lineText.length > 2) {
//   //           extractedLines.add(lineText);
//   //         }
//   //       }
//   //     }
//   //
//   //     // Join all extracted text
//   //     String extractedText = extractedLines.join('\n');
//   //
//   //     print('📝 Raw extracted text length: ${extractedText.length}');
//   //     print('📋 Number of lines extracted: ${extractedLines.length}');
//   //
//   //     if (extractedText.trim().isEmpty) {
//   //       print('⚠️ No text extracted from image');
//   //       throw Exception('No readable text found in the image. Please ensure the image is clear and contains readable text.');
//   //     }
//   //
//   //     // Validate that we have meaningful content
//   //     if (extractedText.length < 20) {
//   //       print('⚠️ Very little text extracted: ${extractedText.length} characters');
//   //       throw Exception('Very little text could be extracted. Please use a clearer image with more readable content.');
//   //     }
//   //
//   //     print('✅ Image text extraction successful: ${extractedText.length} characters');
//   //     return extractedText;
//   //   } catch (e) {
//   //     print('❌ Image OCR Error: $e');
//   //     throw Exception('Failed to extract text from image: ${e.toString()}');
//   //   }
//   // }
//
//
//   // Future<String> _extractTextFromPdf(File pdfFile) async {
//   //   try {
//   //     print('📄 Processing PDF file: ${pdfFile.path}');
//   //     print('📏 File size: ${await pdfFile.length()} bytes');
//   //
//   //     // Use the dedicated PDF service
//   //     String extractedText = await PdfService.extractTextFromPdf(pdfFile);
//   //
//   //     if (extractedText.isNotEmpty && extractedText.length > 50) {
//   //       print('✅ PDF text extraction successful: ${extractedText.length} characters');
//   //       return extractedText;
//   //     } else {
//   //       print('⚠️ Limited text extracted from PDF');
//   //       throw Exception('Could not extract sufficient readable text from PDF. The PDF may contain scanned images or be password protected.');
//   //     }
//   //   } catch (e) {
//   //     print('❌ PDF OCR Error: $e');
//   //     throw Exception('Failed to process PDF file: ${e.toString()}');
//   //   }
//   // }
//
//   Future<String> _extractTextFromPdf(File pdfFile) async {
//     try {
//       print('📄 Processing PDF file: ${pdfFile.path}');
//
//       // Use Syncfusion directly instead of PdfService
//       final List<int> bytes = await pdfFile.readAsBytes();
//       final PdfDocument document = PdfDocument(inputBytes: bytes);
//
//       PdfTextExtractor extractor = PdfTextExtractor(document);
//       String extractedText = extractor.extractText();
//       document.dispose();
//
//       print('✅ PDF text extraction successful: ${extractedText.length} characters');
//       print('📄 First 300 chars: ${extractedText.substring(0, extractedText.length > 300 ? 300 : extractedText.length)}...');
//
//       if (extractedText.isNotEmpty && extractedText.length > 50) {
//         return extractedText;
//       } else {
//         throw Exception('Could not extract sufficient readable text from PDF.');
//       }
//     } catch (e) {
//       print('❌ PDF OCR Error: $e');
//       throw Exception('Failed to process PDF file: ${e.toString()}');
//     }
//   }
//   void dispose() {
//     _textRecognizer.close();
//   }
// }


import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart' as mlkit;
import 'package:medlytic/services/pdf_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class OCRService {
  final mlkit.TextRecognizer _textRecognizer = mlkit.GoogleMlKit.vision.textRecognizer();

  Future<String> extractText(File file, bool isPdf) async {
    try {
      print('🔍 Starting text extraction for file: ${file.path}');
      print('📁 File exists: ${await file.exists()}');
      print('📏 File size: ${await file.length()} bytes');
      print('📄 Is PDF: $isPdf');

      if (isPdf) {
        print('📄 Processing PDF file...');
        return await extractTextFromPdf(file);
      } else {
        print('🖼️ Processing image file...');
        return await _extractTextFromImage(file);
      }
    } catch (e) {
      print('❌ OCR Error: $e');
      if (!isPdf) {
        throw Exception('OCR failed: ${e.toString()}');
      } else {
        return 'Error processing PDF file. Please try again or use an image instead.';
      }
    }
  }

  Future<String> _extractTextFromImage(File imageFile) async {
    try {
      print('🔄 Processing image file: ${imageFile.path}');
      print('📏 File size: ${await imageFile.length()} bytes');

      final mlkit.InputImage inputImage = mlkit.InputImage.fromFile(imageFile);
      final mlkit.RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      List<String> extractedLines = [];

      // Extract text from all blocks and lines - using mlkit prefix
      for (mlkit.TextBlock block in recognizedText.blocks) {
        for (mlkit.TextLine line in block.lines) {
          String lineText = line.text.trim();
          if (lineText.isNotEmpty && lineText.length > 2) {
            extractedLines.add(lineText);
          }
        }
      }

      String extractedText = extractedLines.join('\n');

      print('📝 Raw extracted text length: ${extractedText.length}');
      print('📋 Number of lines extracted: ${extractedLines.length}');

      if (extractedText.trim().isEmpty) {
        print('⚠️ No text extracted from image');
        throw Exception('No readable text found in the image. Please ensure the image is clear and contains readable text.');
      }

      if (extractedText.length < 20) {
        print('⚠️ Very little text extracted: ${extractedText.length} characters');
        throw Exception('Very little text could be extracted. Please use a clearer image with more readable content.');
      }

      print('✅ Image text extraction successful: ${extractedText.length} characters');
      return extractedText;
    } catch (e) {
      print('❌ Image OCR Error: $e');
      throw Exception('Failed to extract text from image: ${e.toString()}');
    }
  }

  Future<String> extractTextFromPdf(File pdfFile) async {
    print('📄 Processing PDF file: ${pdfFile.path}');

    // Method 1: Try Syncfusion (works for text-based PDFs)
    try {
      String syncfusionText = await _trySyncfusionExtraction(pdfFile);
      if (syncfusionText.isNotEmpty && syncfusionText.length > 20) {
        print('✅ Syncfusion extraction successful');
        return syncfusionText;
      }
    } catch (e) {
      print('⚠️ Syncfusion failed: $e');
    }

    // Method 2: Try basic byte analysis (for simple PDFs)
    try {
      String basicText = await _tryBasicPdfExtraction(pdfFile);
      if (basicText.isNotEmpty && basicText.length > 20) {
        print('✅ Basic extraction successful');
        return basicText;
      }
    } catch (e) {
      print('⚠️ Basic extraction failed: $e');
    }

    // Method 3: Check if it's a scanned PDF and suggest image upload
    bool isScannedPdf = await _isScannedPdf(pdfFile);
    if (isScannedPdf) {
      throw Exception('This appears to be a scanned PDF (image-based). Please use the "Image Report" option instead for better text recognition.');
    }

    // Final fallback
    throw Exception('Could not extract text from this PDF. Please try:\n1. Use "Image Report" option\n2. Convert PDF to image first\n3. Use a different PDF file');
  }

  Future<String> _trySyncfusionExtraction(File pdfFile) async {
    final List<int> bytes = await pdfFile.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    PdfTextExtractor extractor = PdfTextExtractor(document);
    String extractedText = extractor.extractText();
    document.dispose();

    return extractedText.trim();
  }

  Future<String> _tryBasicPdfExtraction(File pdfFile) async {
    final List<int> bytes = await pdfFile.readAsBytes();
    String content = String.fromCharCodes(bytes);

    // Look for readable text patterns in PDF
    List<String> foundText = [];

    // Method 1: Look for text in parentheses (common PDF text format)
    RegExp textPattern = RegExp(r'$$([^)]+)$$', multiLine: true);
    Iterable<Match> matches = textPattern.allMatches(content);

    for (Match match in matches) {
      String text = match.group(1) ?? '';
      if (_isReadableText(text)) {
        foundText.add(text);
      }
    }

    // Method 2: Look for medical keywords directly in bytes
    List<String> medicalTerms = ['patient', 'blood', 'test', 'result', 'glucose', 'pressure', 'cholesterol', 'hemoglobin'];
    for (String term in medicalTerms) {
      if (content.toLowerCase().contains(term.toLowerCase())) {
        // Extract surrounding context
        int index = content.toLowerCase().indexOf(term.toLowerCase());
        if (index > 0) {
          String context = content.substring(
              (index - 50).clamp(0, content.length),
              (index + 100).clamp(0, content.length)
          );
          foundText.add(context.replaceAll(RegExp(r'[^\w\s\.\,\:\-$$$$]'), ' '));
        }
      }
    }

    return foundText.join(' ').trim();
  }

  Future<bool> _isScannedPdf(File pdfFile) async {
    try {
      final List<int> bytes = await pdfFile.readAsBytes();
      String content = String.fromCharCodes(bytes);

      // Check for image indicators in PDF
      bool hasImages = content.contains('/Image') ||
          content.contains('/DCTDecode') ||
          content.contains('/FlateDecode');

      // Check for lack of text content
      bool hasMinimalText = !content.contains('(') || content.split('(').length < 5;

      return hasImages && hasMinimalText;
    } catch (e) {
      return false;
    }
  }

  bool _isReadableText(String text) {
    if (text.length < 3) return false;

    // Check if text contains readable characters
    bool hasLetters = RegExp(r'[a-zA-Z]').hasMatch(text);
    bool hasNumbers = RegExp(r'[0-9]').hasMatch(text);
    bool notTooManySymbols = text.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '').length < text.length * 0.5;

    return hasLetters && notTooManySymbols;
  }
  void dispose() {
    _textRecognizer.close();
  }
}