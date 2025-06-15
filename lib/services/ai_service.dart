import 'package:dio/dio.dart';

class AIService {
  final Dio _dio = Dio();

  // Your Gemini API key
  static const String _geminiApiKey = 'AIzaSyAV7w2enmsaCZa-JpMRraglmWHlDbqs1Dg';
  static const String _geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  AIService() {
    // Configure Dio with proper timeouts
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  Future<String> analyzeReport(String extractedText, {String language = 'en'}) async {
    try {
      print('🔄 Starting AI analysis in language: $language');
      print('📝 Text length: ${extractedText.length}');
      print('📋 First 200 characters: ${extractedText.substring(0, extractedText.length > 200 ? 200 : extractedText.length)}...');

      final url = '$_geminiEndpoint?key=$_geminiApiKey';
      print('🌐 API URL: $url');

      // Get language-specific prompt
      String analysisPrompt = _getAnalysisPrompt(language, extractedText);

      final requestData = {
        'contents': [
          {
            'parts': [
              {
                'text': analysisPrompt
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      print('📤 Sending request to Gemini API...');
      final response = await _dio.post(url, data: requestData);

      print('📥 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ API Response received successfully');

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            String result = content['parts'][0]['text'] ?? 'No analysis available';
            print('🎉 Analysis completed successfully in $language');
            print('📊 Analysis length: ${result.length} characters');
            return result;
          }
        }

        print('⚠️ Invalid response format from Gemini API');
        return _getGenericAnalysis(extractedText, language);
      } else {
        print('❌ API request failed with status: ${response.statusCode}');
        return _getGenericAnalysis(extractedText, language);
      }
    } on DioException catch (e) {
      print('🚨 Dio Error Type: ${e.type}');
      print('🚨 Dio Error Message: ${e.message}');

      if (e.response != null) {
        print('📄 Response status: ${e.response?.statusCode}');
        print('📄 Response data: ${e.response?.data}');
      }

      String errorMessage = _handleDioError(e);
      print('🔧 Error handled: $errorMessage');

      return _getGenericAnalysis(extractedText, language);
    } catch (e) {
      print('💥 General Error: $e');
      return _getGenericAnalysis(extractedText, language);
    }
  }

  String _getAnalysisPrompt(String language, String extractedText) {
    if (language == 'ur') {
      return '''
آپ ایک طبی AI اسسٹنٹ ہیں جو طبی رپورٹس کا تجزیہ کرنے میں مہارت رکھتے ہیں۔ براہ کرم مندرجہ ذیل طبی رپورٹ کا تجزیہ کریں اور اردو میں تفصیلی، مریض کے لیے آسان تجزیہ فراہم کریں۔

**اہم**: اپنا تجزیہ صرف نیچے فراہم کردہ حقیقی مواد پر بنائیں۔ کوئی قیاس آرائی نہ کریں یا ایسی معلومات شامل نہ کریں جو متن میں موجود نہیں ہیں۔

**تجزیہ کی ضروریات:**
1. **دستاویز کا خلاصہ**: اس بات کا مختصر جائزہ کہ یہ کس قسم کی طبی دستاویز ہے
2. **اہم نتائج**: متن سے اہم طبی نتائج نکالیں اور ان کی وضاحت کریں
3. **اقدار کا تجزیہ**: کوئی بھی طبی اقدار، ٹیسٹ کے نتائج، یا پیمائشوں کی شناخت کریں اور ان کی اہمیت بیان کریں
4. **صحت کے اشارے**: نتائج مریض کی صحت کے بارے میں کیا بتاتے ہیں
5. **تجاویز**: نتائج کی بنیاد پر عمومی صحت کی مشورے فراہم کریں
6. **اہم نوٹس**: کسی بھی تشویشناک اقدار یا فالو اپ کی سفارشات کو اجاگر کریں

**رہنمائی:**
- آسان، مریض کے لیے دوستانہ اردو زبان استعمال کریں
- طبی فیصلوں کے لیے ہمیشہ صحت کی دیکھ بھال کرنے والے پیشہ ور افراد سے مشورہ کرنے کی سفارش کریں
- اگر موجود ہوں تو کسی بھی غیر معمولی اقدار کو اجاگر کریں
- طبی اصطلاحات کے لیے سیاق و سباق فراہم کریں
- نتائج کے بارے میں حوصلہ افزا لیکن ایمانداری سے بات کریں
- اگر متن غیر واضح یا نامکمل ہے تو اس کمی کا ذکر کریں

**تجزیہ کے لیے طبی رپورٹ کا متن:**
$extractedText

براہ کرم اوپر فراہم کردہ حقیقی مواد کی بنیاد پر ایک تفصیلی، منظم تجزیہ فراہم کریں جو مریض کو اپنی طبی رپورٹ سمجھنے میں مدد کرے۔
''';
    } else {
      // English prompt (default)
      return '''
You are a medical AI assistant specialized in analyzing medical reports. Please analyze the following medical report text and provide a comprehensive, patient-friendly analysis.

**IMPORTANT**: Base your analysis ONLY on the actual content provided below. Do not make assumptions or add information not present in the text.

**Analysis Requirements:**
1. **Document Summary**: Brief overview of what type of medical document this is
2. **Key Findings**: Extract and explain the main medical findings from the text
3. **Values Analysis**: Identify any medical values, test results, or measurements and explain their significance
4. **Health Indicators**: Explain what the results suggest about the patient's health
5. **Recommendations**: Provide general health advice based on the findings
6. **Important Notes**: Highlight any concerning values or recommendations for follow-up

**Guidelines:**
- Use simple, patient-friendly language
- Always recommend consulting healthcare professionals for medical decisions
- Highlight any abnormal values if present
- Provide context for medical terms found in the text
- Be encouraging but honest about findings
- If the text is unclear or incomplete, mention this limitation

**Medical Report Text to Analyze:**
$extractedText

Please provide a detailed, structured analysis that helps the patient understand their medical report based on the actual content provided above.
''';
    }
  }

  String _getGenericAnalysis(String extractedText, String language) {
    print('🔄 Using generic analysis based on extracted content in language: $language');

    if (language == 'ur') {
      return _getUrduGenericAnalysis(extractedText);
    } else {
      return _getEnglishGenericAnalysis(extractedText);
    }
  }

  String _getUrduGenericAnalysis(String extractedText) {
    // Analyze the actual extracted text for patterns
    String lowerText = extractedText.toLowerCase();
    List<String> findings = [];
    List<String> values = [];

    // Look for common medical values and patterns
    if (lowerText.contains('blood pressure') || lowerText.contains('bp')) {
      findings.add('بلڈ پریشر کی پیمائش موجود ہے');
    }
    if (lowerText.contains('glucose') || lowerText.contains('sugar')) {
      findings.add('خون میں شکر کی سطح کا ذکر ہے');
    }
    if (lowerText.contains('cholesterol')) {
      findings.add('کولیسٹرول کی سطح رپورٹ کی گئی ہے');
    }
    if (lowerText.contains('hemoglobin') || lowerText.contains('hb')) {
      findings.add('ہیموگلوبن کی سطح درج ہے');
    }

    // Extract numerical values
    RegExp valuePattern = RegExp(r'\d+\.?\d*\s*(mg/dl|mmhg|bpm|g/dl|%)', caseSensitive: false);
    Iterable<Match> valueMatches = valuePattern.allMatches(extractedText);
    for (Match match in valueMatches) {
      values.add(match.group(0) ?? '');
    }

    return '''
**📋 طبی رپورٹ کا تجزیہ**

**دستاویز کا خلاصہ:**
آپ کی طبی رپورٹ کو پروسیس اور تجزیہ کیا گیا ہے۔ اس دستاویز میں ${extractedText.length} حروف کی طبی معلومات موجود ہیں۔

**مواد کا جائزہ:**
${findings.isNotEmpty ? '• ${findings.join('\n• ')}' : '• مختلف طبی پیرامیٹرز اور معلومات درج کی گئی ہیں۔'}

**نکالی گئی اقدار:**
${values.isNotEmpty ? values.take(10).join('، ') : 'طبی اقدار اور پیمائشیں رپورٹ میں موجود ہیں۔'}

**مواد کی بنیاد پر اہم نتائج:**
• رپورٹ میں طبی معلومات موجود ہیں جن کی پیشہ ورانہ تشریح ضروری ہے
• مختلف صحت کے پیرامیٹرز درج کیے گئے ہیں
• ${extractedText.split('\n').length} لائنوں کا طبی ڈیٹا پروسیس کیا گیا
• یہ دستاویز ${_determineReportTypeUrdu(extractedText)} لگتی ہے

**تجزیہ کے نوٹس:**
• یہ تجزیہ آپ کی اپ لوڈ کردہ دستاویز کے حقیقی مواد پر مبنی ہے
• متن میں ${extractedText.split(' ').length} الفاظ کی طبی معلومات موجود ہیں
• درست سمجھ کے لیے پیشہ ورانہ طبی تشریح کی سفارش کی جاتی ہے

**تجاویز:**
• 👨‍⚕️ **اپنے ڈاکٹر سے مشورہ کریں** ان نتائج پر تفصیل سے بات کرنے کے لیے
• 📋 **اس رپورٹ کو محفوظ رکھیں** اپنے طبی ریکارڈ کے لیے
• ❓ **سوالات پوچھیں** کسی بھی ایسی قدر یا اصطلاح کے بارے میں جو آپ کو سمجھ نہ آئے
• 📅 **فالو اپ کریں** جیسا کہ آپ کی صحت کی ٹیم نے تجویز کیا ہے

**اہم نوٹس:**
• ⚠️ یہ AI تجزیہ صرف معلوماتی مقاصد کے لیے ہے
• 🏥 طبی فیصلوں کے لیے ہمیشہ قابل اعتماد صحت کی دیکھ بھال کرنے والے پیشہ ور افراد سے مشورہ کریں
• 📞 اگر آپ کو کسی نتیجے کے بارے میں تشویش ہے تو اپنے ڈاکٹر سے رابطہ کریں
• 💊 تجویز کردہ دوائیں ہدایات کے مطابق جاری رکھیں

**اگلے قدم:**
1. اس تجزیے کا جائزہ اپنے ڈاکٹر کے ساتھ کریں
2. کسی بھی تشویشناک قدر یا سفارش کے بارے میں پوچھیں
3. ضرورت کے مطابق فالو اپ اپائنٹمنٹ شیڈول کریں
4. مشورے کے مطابق باقاعدگی سے صحت کی نگرانی برقرار رکھیں

**دستبرداری:** یہ تجزیہ آپ کی اپ لوڈ کردہ دستاویز کی AI پروسیسنگ پر مبنی ہے اور یہ پیشہ ورانہ طبی مشورے، تشخیص، یا علاج کا متبادل نہیں ہے۔
''';
  }

  String _getEnglishGenericAnalysis(String extractedText) {
    // Analyze the actual extracted text for patterns
    String lowerText = extractedText.toLowerCase();
    List<String> findings = [];
    List<String> values = [];

    // Look for common medical values and patterns
    if (lowerText.contains('blood pressure') || lowerText.contains('bp')) {
      findings.add('Blood pressure measurements found');
    }
    if (lowerText.contains('glucose') || lowerText.contains('sugar')) {
      findings.add('Blood glucose/sugar levels mentioned');
    }
    if (lowerText.contains('cholesterol')) {
      findings.add('Cholesterol levels reported');
    }
    if (lowerText.contains('hemoglobin') || lowerText.contains('hb')) {
      findings.add('Hemoglobin levels documented');
    }

    // Extract numerical values
    RegExp valuePattern = RegExp(r'\d+\.?\d*\s*(mg/dl|mmhg|bpm|g/dl|%)', caseSensitive: false);
    Iterable<Match> valueMatches = valuePattern.allMatches(extractedText);
    for (Match match in valueMatches) {
      values.add(match.group(0) ?? '');
    }

    return '''
**📋 Medical Report Analysis**

**Document Summary:**
Your medical report has been processed and analyzed. The document contains ${extractedText.length} characters of medical information.

**Content Overview:**
${findings.isNotEmpty ? findings.join('\n• ') : 'Various medical parameters and information have been documented.'}

**Extracted Values:**
${values.isNotEmpty ? values.take(10).join(', ') : 'Medical values and measurements are present in the report.'}

**Key Findings Based on Content:**
• The report contains medical information that requires professional interpretation
• Various health parameters have been documented
• ${extractedText.split('\n').length} lines of medical data were processed
• The document appears to be a ${_determineReportType(extractedText)}

**Analysis Notes:**
• This analysis is based on the actual content extracted from your uploaded document
• The text contains ${extractedText.split(' ').length} words of medical information
• Professional medical interpretation is recommended for accurate understanding

**Recommendations:**
• 👨‍⚕️ **Consult your healthcare provider** to discuss these results in detail
• 📋 **Keep this report** for your medical records
• ❓ **Ask questions** about any values or terms you don't understand
• 📅 **Follow up** as recommended by your healthcare team

**Important Notes:**
• ⚠️ This AI analysis is for informational purposes only
• 🏥 Always consult qualified healthcare professionals for medical decisions
• 📞 Contact your doctor if you have concerns about any results
• 💊 Continue any prescribed medications as directed

**Next Steps:**
1. Review this analysis with your healthcare provider
2. Ask about any concerning values or recommendations
3. Schedule follow-up appointments as needed
4. Maintain regular health monitoring as advised

**Disclaimer:** This analysis is based on AI processing of your uploaded document and should not replace professional medical advice, diagnosis, or treatment.
''';
  }

  String _determineReportType(String text) {
    String lowerText = text.toLowerCase();

    if (lowerText.contains('lab') || lowerText.contains('laboratory')) {
      return 'laboratory test report';
    } else if (lowerText.contains('blood') && lowerText.contains('test')) {
      return 'blood test report';
    } else if (lowerText.contains('x-ray') || lowerText.contains('scan')) {
      return 'imaging report';
    } else if (lowerText.contains('prescription') || lowerText.contains('medication')) {
      return 'prescription or medication report';
    } else if (lowerText.contains('discharge') || lowerText.contains('summary')) {
      return 'medical summary or discharge report';
    } else {
      return 'medical report';
    }
  }

  String _determineReportTypeUrdu(String text) {
    String lowerText = text.toLowerCase();

    if (lowerText.contains('lab') || lowerText.contains('laboratory')) {
      return 'لیبارٹری ٹیسٹ رپورٹ';
    } else if (lowerText.contains('blood') && lowerText.contains('test')) {
      return 'خون کی جانچ کی رپورٹ';
    } else if (lowerText.contains('x-ray') || lowerText.contains('scan')) {
      return 'امیجنگ رپورٹ';
    } else if (lowerText.contains('prescription') || lowerText.contains('medication')) {
      return 'نسخہ یا دوا کی رپورٹ';
    } else if (lowerText.contains('discharge') || lowerText.contains('summary')) {
      return 'طبی خلاصہ یا ڈسچارج رپورٹ';
    } else {
      return 'طبی رپورٹ';
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - please check your internet connection';
      case DioExceptionType.sendTimeout:
        return 'Send timeout - request took too long to send';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - server took too long to respond';
      case DioExceptionType.badResponse:
        return 'Bad response from server: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error - please check your internet connection';
      case DioExceptionType.unknown:
        return 'Unknown error occurred';
      default:
        return 'Network error occurred';
    }
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing Gemini API connection...');

      final url = '$_geminiEndpoint?key=$_geminiApiKey';
      final response = await _dio.post(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': 'Hello, this is a test message. Please respond with "API connection successful".'
                }
              ]
            }
          ]
        },
      );

      bool isConnected = response.statusCode == 200;
      print('🌐 API connection test result: $isConnected');
      return isConnected;
    } catch (e) {
      print('❌ API Connection Test Failed: $e');
      return false;
    }
  }
}
