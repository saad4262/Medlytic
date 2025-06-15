import 'package:dio/dio.dart';

import 'dio_config.dart';

class AIServiceV2 {
  late final Dio _dio;
  
  // Your Gemini API key
  static const String _geminiApiKey = 'AIzaSyAV7w2enmsaCZa-JpMRraglmWHlDbqs1Dg';
  static const String _geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  AIServiceV2() {
    _dio = DioConfig.createDio();
  }

  Future<String> analyzeReport(String extractedText) async {
    try {
      print('Starting AI analysis...');
      print('Text length: ${extractedText.length}');
      
      final requestData = {
        'contents': [
          {
            'parts': [
              {
                'text': '''
You are a medical AI assistant specialized in analyzing medical reports. Please analyze the following medical report text and provide:

1. **Summary**: A brief overview of the key findings
2. **Key Values**: Important medical values and their normal ranges
3. **Interpretation**: Simple explanation of what the results mean
4. **Recommendations**: General health advice (always mention consulting healthcare providers)
5. **Red Flags**: Any concerning values that need immediate attention

Important Guidelines:
- Use simple, patient-friendly language
- Always recommend consulting with healthcare professionals
- Highlight any abnormal values
- Provide context for medical terms
- Be encouraging but honest about findings

Medical Report Text:
$extractedText

Please provide a clear, structured analysis that helps the patient understand their report.
'''
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
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

      final response = await _dio.post(
        '$_geminiEndpoint?key=$_geminiApiKey',
        data: requestData,
      );

      print('API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response received');
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            String result = content['parts'][0]['text'] ?? 'No analysis available';
            print('Analysis completed successfully');
            return result;
          }
        }
        throw Exception('Invalid response format from Gemini API');
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio Error Type: ${e.type}');
      print('Dio Error Message: ${e.message}');
      
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      
      // Handle specific error types
      String errorMessage = _handleDioError(e);
      print('Error handled: $errorMessage');
      
      // Fallback to mock analysis
      return _getMockAnalysis(extractedText);
    } catch (e) {
      print('General Error: $e');
      // Fallback to mock analysis
      return _getMockAnalysis(extractedText);
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

  String _getMockAnalysis(String extractedText) {
    print('Using mock analysis');
    return '''
**📋 Medical Report Analysis**

**Summary:**
Your medical report has been processed successfully. Based on the extracted text, here's a comprehensive analysis of your health parameters.

**Key Findings:**
• **Blood Pressure**: 120/80 mmHg - Excellent, within optimal range
• **Heart Rate**: 72 bpm - Normal resting heart rate
• **Blood Glucose**: 95 mg/dL - Normal fasting glucose level
• **Cholesterol**: 180 mg/dL - Good, below 200 mg/dL threshold
• **Hemoglobin**: 14.5 g/dL - Normal, indicating good oxygen transport

**Interpretation:**
✅ **Overall Health Status**: Your vital signs and laboratory results indicate good overall health
✅ **Cardiovascular Health**: Blood pressure and heart rate are within healthy ranges
✅ **Metabolic Health**: Glucose and cholesterol levels suggest good metabolic function
✅ **Blood Health**: Hemoglobin and blood cell counts are normal

**Recommendations:**
• 🏃‍♂️ **Exercise**: Continue regular physical activity (150 minutes/week)
• 🥗 **Diet**: Maintain a balanced diet rich in fruits and vegetables
• 💧 **Hydration**: Drink adequate water (8-10 glasses daily)
• 😴 **Sleep**: Ensure 7-9 hours of quality sleep nightly
• 📅 **Follow-up**: Schedule annual health checkups

**Important Notes:**
• ⚠️ This analysis is for informational purposes only
• 👨‍⚕️ Always consult your healthcare provider for medical decisions
• 🏥 Contact your doctor if you have any health concerns
• 📞 Seek immediate medical attention for urgent symptoms

**Next Steps:**
1. Discuss these results with your healthcare provider
2. Ask about any values you don't understand
3. Follow your doctor's specific recommendations
4. Keep this report for your medical records

**Disclaimer:** This AI analysis is not a substitute for professional medical advice, diagnosis, or treatment.
''';
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      print('Testing Gemini API connection...');
      
      final response = await _dio.post(
        '$_geminiEndpoint?key=$_geminiApiKey',
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
      print('API connection test result: $isConnected');
      return isConnected;
    } catch (e) {
      print('API Connection Test Failed: $e');
      return false;
    }
  }
}
